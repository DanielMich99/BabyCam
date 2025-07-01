import os
import shutil
from sqlalchemy.orm import Session

from app.schemas.model_update_schema import ModelUpdateRequest
from app.utils.dataset_utils import update_dataset_yaml, rebuild_training_folders, remap_labels_to_new_indexes
from app.utils.file_utils import delete_class_data, add_class_data, append_to_class_data
from app.db_utils.class_utils import update_db_classes, insert_new_classes, delete_db_classes
from app.utils.upload_to_drive import zip_dataset, cleanup_zip, upload_to_drive
from app.services import training_monitor_service
from app.models.user_model import User
from app.models.class_model import ClassObject
from app.models.baby_profile_model import BabyProfile
import requests


# Determine training strategy based on which kinds of changes were submitted
def should_train_or_finetune(request: ModelUpdateRequest) -> str:
    if request.deleted_classes:
        return "retrain"

    has_new_data = bool(request.new_classes)
    has_updated_data = any(
        item.files.images or item.files.labels
        for item in request.updated_classes
    )

    print(has_new_data)
    print(has_updated_data)

    if has_new_data or has_updated_data:
        return "finetune"

    return "none"


# Trigger training by zipping the dataset, uploading to Drive, and calling Cloud Function
def train_model_remotely(baby_profile_id: int, camera_type: str, strategy: str):
    if strategy == "none":
        return {"message": "No training required."}

    # Step 1: Zip dataset
    zip_path = zip_dataset(baby_profile_id, camera_type)

    # Step 2: Upload to Google Drive
    upload_to_drive(zip_path, baby_profile_id, camera_type)

    # Step 3: Clean up local zip
    cleanup_zip(baby_profile_id, camera_type)

    # Step 4: Call remote Cloud Function to start training job
    endpoint = "https://us-central1-babycam-colab-deploy.cloudfunctions.net/trigger_colab_training"
    payload = {
        "user_id": baby_profile_id,
        "camera_type": camera_type,
        "fine_tune": (strategy == "finetune")
    }

    try:
        res = requests.post(endpoint, json=payload, timeout=10)
        res.raise_for_status()
        return res.json()
    except Exception as e:
        return {"error": str(e)}


# Handle full model update process including file ops, DB ops, and training trigger
def process_model_update(request: ModelUpdateRequest, current_user: User, db: Session):
    model_folder = os.path.join("uploads", "training_data", str(request.baby_profile_id), request.model_type.replace("_model", ""))

    # 1. Delete classes
    for class_name in request.deleted_classes:
        delete_class_data(model_folder, class_name)
    delete_db_classes(db, request.baby_profile_id, request.deleted_classes, request.model_type.replace("_model", ""))

    # 2. Add new classes
    for item in request.new_classes:
        add_class_data(model_folder, item, request.baby_profile_id, request.model_type)
    insert_new_classes(db, request.baby_profile_id, request.new_classes, request.model_type.replace("_model", ""))

    # 3. Append data to existing classes
    for item in request.updated_classes:
        append_to_class_data(model_folder, item, request.baby_profile_id, request.model_type)
    update_db_classes(db, request.baby_profile_id, request.updated_classes, request.model_type.replace("_model", ""))

    # 4. Clean and rebuild temp directory
    shutil.rmtree(os.path.join("uploads", "temp"), ignore_errors=True)
    os.makedirs(os.path.join("uploads", "temp"), exist_ok=True)

    # 5. Update dataset.yaml and remap label indexes
    if request.deleted_classes or request.new_classes:
        class_mapping = update_dataset_yaml(db, model_folder, request.baby_profile_id, request.model_type.replace("_model", ""))
        remap_labels_to_new_indexes(class_mapping, model_folder)

    # 6. Rebuild folder structure (images/train/val, labels/train/val, etc.)
    rebuild_training_folders(model_folder)

    # 7. Decide whether to train or finetune
    strategy = should_train_or_finetune(request)

    # 8. If no classes left, clear model folder and timestamps
    remaining_classes = db.query(ClassObject).filter_by(
        baby_profile_id=request.baby_profile_id,
        camera_type=request.model_type.replace("_model", "")
    ).all()

    if not remaining_classes:
        profile = db.query(BabyProfile).filter(BabyProfile.id == request.baby_profile_id).first()
        if profile:
            camera_type = request.model_type.replace("_model", "")
            if camera_type == "head_camera":
                profile.head_camera_model_last_updated_time = None
            else:
                profile.static_camera_model_last_updated_time = None
            db.commit()
        shutil.rmtree(model_folder, ignore_errors=True)
        strategy = "none"

    # 9. Trigger training job remotely if needed
    train_result = train_model_remotely(request.baby_profile_id, request.model_type.replace("_model", ""), strategy)

    # 10. Register this model as "awaiting training completion" if training was triggered
    if strategy != "none":
        training_monitor_service.register_pending_training(
            current_user.id,
            request.baby_profile_id,
            request.model_type.replace("_model", "")
        )

    return {
        "message": "Model update completed.",
        "training_strategy": strategy,
        "training_result": train_result
    }
