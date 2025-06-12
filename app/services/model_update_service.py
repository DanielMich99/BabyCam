import os
import shutil
from app.schemas.model_update_schema import ModelUpdateRequest
from app.utils.dataset_utils import update_dataset_yaml, rebuild_training_folders, remap_labels_to_new_indexes
from app.utils.file_utils import delete_class_data, add_class_data, append_to_class_data
from app.db_utils.class_utils import update_db_classes, insert_new_classes, delete_db_classes
from app.utils.upload_to_drive import zip_dataset, cleanup_zip, upload_to_drive
from app.services import training_monitor_service
from app.models.user_model import User
import requests
import time
from pydrive.auth import GoogleAuth
from pydrive.drive import GoogleDrive

'''def should_train_or_finetune(request) -> str:
    # אימון מלא אם יש קלאסים חדשים או שנמחקו
    if request.new_classes or request.deleted_classes:
        return "finetune"

    # Fine-tune רק אם יש תמונות/labels בקלאסים מעודכנים
    has_training_files = any(
        item.files.images or item.files.labels
        for item in request.updated_classes
    )

    if has_training_files:
        return "finetune"

    # אחרת – רק risk_level השתנה → אין צורך לאמן
    return "none" '''
    
def should_train_or_finetune(request):
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

def train_model_remotely(baby_profile_id: int, camera_type: str, strategy: str):
    if strategy == "none":
        return {"message": "No training required."}

    # Step 1: Create zip
    zip_path = zip_dataset(baby_profile_id, camera_type)

    # Step 2: Upload to Google Drive
    upload_to_drive(zip_path, baby_profile_id, camera_type)

    # Step 3: clean zip
    cleanup_zip(baby_profile_id, camera_type)

    # Step 4: Trigger Cloud Run job via Cloud Function
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

def process_model_update(request: ModelUpdateRequest, current_user: User, db):
    model_folder = os.path.join("uploads", "training_data", str(request.baby_profile_id), request.model_type.replace("_model", ""))
    
    
    # 1. Delete
    for class_name in request.deleted_classes:
        delete_class_data(model_folder, class_name)
    delete_db_classes(db, request.baby_profile_id, request.deleted_classes, request.model_type.replace("_model", ""))
    
    # 2. Add
    for item in request.new_classes:
        add_class_data(model_folder, item, request.baby_profile_id, request.model_type)
    insert_new_classes(db, request.baby_profile_id, request.new_classes, request.model_type.replace("_model", ""))
    
    # 3. Update
    for item in request.updated_classes:
        append_to_class_data(model_folder, item, request.baby_profile_id, request.model_type)
    update_db_classes(db, request.baby_profile_id, request.updated_classes, request.model_type.replace("_model", ""))

    # ניקוי תיקיית temp אחרי סיום טיפול בקבצים
    shutil.rmtree(os.path.join("uploads", "temp"), ignore_errors=True)
    os.makedirs(os.path.join("uploads", "temp"), exist_ok=True)
    
    # 4. Update YAML & Folders
    if request.deleted_classes or request.new_classes:
        class_mapping = update_dataset_yaml(db, model_folder, request.baby_profile_id, request.model_type.replace("_model", ""))
        remap_labels_to_new_indexes(class_mapping, model_folder)
        #sync_model_indexes_to_classes(db, request.baby_profile_id, request.model_type.replace("_model", ""), class_mapping)
        
    rebuild_training_folders(model_folder)

    # קביעת אסטרטגיית אימון
    strategy = should_train_or_finetune(request)

    # טריגר לאימון אם צריך
    train_result = train_model_remotely(request.baby_profile_id, request.model_type.replace("_model", ""), strategy)
    
    if strategy != "none":
        # user = db.query(User).filter_by(id=request.baby_profile_id).first()
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