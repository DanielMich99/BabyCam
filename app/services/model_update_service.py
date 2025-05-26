import os
import shutil
from app.schemas.model_update_schema import ModelUpdateRequest
from app.utils.dataset_utils import update_dataset_yaml, rebuild_training_folders, remap_labels_to_new_indexes
from app.utils.file_utils import delete_class_data, add_class_data, append_to_class_data
from app.db_utils.class_utils import update_db_classes, insert_new_classes, delete_db_classes, sync_model_indexes_to_classes
from app.utils.upload_to_drive import zip_dataset, upload_to_drive
import requests
import time
from pydrive.auth import GoogleAuth
from pydrive.drive import GoogleDrive

def should_train_or_finetune(request) -> str:
    # אימון מלא אם יש קלאסים חדשים או שנמחקו
    if request.new_classes or request.deleted_classes:
        return "retrain"

    # Fine-tune רק אם יש תמונות/labels בקלאסים מעודכנים
    has_training_files = any(
        item.files.images or item.files.labels
        for item in request.updated_classes
    )

    if has_training_files:
        return "finetune"

    # אחרת – רק risk_level השתנה → אין צורך לאמן
    return "none"
    
def train_model_remotely(user_id: int, camera_type: str, strategy: str):
    if strategy == "none":
        return {"message": "No training required."}

    # Step 1: Create zip
    zip_path = zip_dataset(user_id, camera_type)

    # Step 2: Upload to Google Drive
    upload_to_drive(zip_path, user_id, camera_type)

    # Step 3: Trigger Cloud Run job via Cloud Function
    endpoint = "https://us-central1-babycam-colab-deploy.cloudfunctions.net/trigger_colab_training"
    payload = {
        "user_id": user_id,
        "camera_type": camera_type,
        "fine_tune": (strategy == "finetune")
    }

    try:
        res = requests.post(endpoint, json=payload, timeout=10)
        res.raise_for_status()
        return res.json()
    except Exception as e:
        return {"error": str(e)}

def wait_for_model_file(user_id: int, model_type: str, timeout_sec=600):
    gauth = GoogleAuth()
    gauth.LocalWebserverAuth()
    drive = GoogleDrive(gauth)

    start = time.time()
    file_name = f"{user_id}_{model_type}_model.pt"
    local_path = os.path.join("uploads", "training_data", str(user_id), model_type, file_name)

    # locate Drive path: babycam_data/<user_id>/<model_type>
    while time.time() - start < timeout_sec:
        # Step 1: חפש תיקיית base
        folders = drive.ListFile({'q': "mimeType='application/vnd.google-apps.folder' and trashed=false"}).GetList()
        root = next((f for f in folders if f['title'] == "babycam_data"), None)
        if not root:
            time.sleep(10)
            continue

        # Step 2: חפש תיקיית user_id
        profile_query = f"'{root['id']}' in parents and title = '{user_id}'"
        profiles = drive.ListFile({'q': profile_query}).GetList()
        if not profiles:
            time.sleep(10)
            continue

        # Step 3: חפש תיקיית model_type
        model_query = f"'{profiles[0]['id']}' in parents and title = '{model_type}'"
        models = drive.ListFile({'q': model_query}).GetList()
        if not models:
            time.sleep(10)
            continue

        # Step 4: חפש את הקובץ
        file_query = f"'{models[0]['id']}' in parents and title = '{file_name}' and trashed=false"
        results = drive.ListFile({'q': file_query}).GetList()
        if results:
            print(f"[DRIVE] Found {file_name}, downloading...")
            results[0].GetContentFile(local_path)
            return True

        print(f"[WAIT] Waiting for {file_name} in Drive...")
        time.sleep(10)

    raise TimeoutError("Timed out waiting for model file to appear in Drive.")

def process_model_update(request: ModelUpdateRequest, db):
    model_folder = os.path.join("uploads", "training_data", str(request.baby_profile_id), request.model_type.replace("_model", ""))
    
    # 1. Delete
    for class_name in request.deleted_classes:
        delete_class_data(model_folder, class_name)
    delete_db_classes(db, request.baby_profile_id, request.deleted_classes)
    
    # 2. Add
    for item in request.new_classes:
        add_class_data(model_folder, item, request.baby_profile_id, request.model_type)
    insert_new_classes(db, request.baby_profile_id, request.new_classes, request.model_type.replace("_model", ""))
    
    # 3. Update
    for item in request.updated_classes:
        append_to_class_data(model_folder, item, request.baby_profile_id, request.model_type)
    update_db_classes(db, request.baby_profile_id, request.model_type.replace("_model", ""), request.updated_classes)

    # ניקוי תיקיית temp אחרי סיום טיפול בקבצים
    shutil.rmtree(os.path.join("uploads", "temp"), ignore_errors=True)
    os.makedirs(os.path.join("uploads", "temp"), exist_ok=True)
    
    # 4. Update YAML & Folders
    if request.deleted_classes or request.new_classes:
        class_mapping = update_dataset_yaml(model_folder)
        remap_labels_to_new_indexes(class_mapping, model_folder)
        sync_model_indexes_to_classes(db, request.baby_profile_id, request.model_type, class_mapping)
        
    rebuild_training_folders(model_folder)

    # קביעת אסטרטגיית אימון
    strategy = should_train_or_finetune(request)

    # טריגר לאימון אם צריך
    train_result = train_model_remotely(request.baby_profile_id, request.model_type.replace("_model", ""), strategy)

    # המתן לקובץ .pt ויבא אותו למערכת הקבצים
    if strategy != "none":
        try:
            wait_for_model_file(request.baby_profile_id, request.model_type.replace("_model", ""))
        except TimeoutError as e:
            return {
                "message": "Model update completed, but model file download timed out.",
                "training_strategy": strategy,
                "training_result": train_result,
                "error": str(e)
            }
    
    return {
    "message": "Model update completed.",
    "training_strategy": strategy,
    "training_result": train_result
    }