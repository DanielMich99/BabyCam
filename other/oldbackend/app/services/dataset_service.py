import os
import random
import shutil
import yaml

def create_dataset_yaml(user_id: int, camera_type: str, train_split: float = 0.8):
    """
    Create a dataset.yaml file for a user's specific camera type.
    
    Args:
        user_id (int): The user's ID.
        camera_type (str): 'head_camera' or 'static_camera'
        train_split (float): Ratio of train data (default 80% train / 20% val)
    """

    base_dir = f"uploads/training_data/{user_id}/{camera_type}"
    objects_dir = os.path.join(base_dir, "objects")
    scenes_dir = os.path.join(base_dir, "scenes")
    images_dir = os.path.join(base_dir, "images")
    labels_dir = os.path.join(base_dir, "labels")

    # הכין תיקייה לאיחוד כל התמונות
    os.makedirs(images_dir, exist_ok=True)

    # אסוף את כל התמונות מכל המקורות
    all_images = []

    if camera_type == "head_camera":
        relevant_folder = objects_dir
        if os.path.exists(relevant_folder):
            for root, _, files in os.walk(relevant_folder):
                for file in files:
                    if file.lower().endswith(('.jpg', '.jpeg', '.png')):
                        full_path = os.path.join(root, file)
                        all_images.append(full_path)

    else:  # static_camera - חפש רק בframes_*
        if os.path.exists(scenes_dir):
            for root, _, files in os.walk(scenes_dir):
                if os.path.basename(root).startswith("frames_"):
                    for file in files:
                        if file.lower().endswith(('.jpg', '.jpeg', '.png')):
                            full_path = os.path.join(root, file)
                            all_images.append(full_path)

    if not all_images:
        raise ValueError(f"No images found for user {user_id} and camera type {camera_type}")

    # ערבב את התמונות
    random.shuffle(all_images)

    # חלק ל-train ול-val
    train_size = int(len(all_images) * train_split)
    train_images = all_images[:train_size]
    val_images = all_images[train_size:]

    # צור תיקיות
    train_dir = os.path.join(images_dir, "train")
    val_dir = os.path.join(images_dir, "val")
    label_train_dir = os.path.join(labels_dir, "train")
    label_val_dir = os.path.join(labels_dir, "val")

    os.makedirs(train_dir, exist_ok=True)
    os.makedirs(val_dir, exist_ok=True)
    os.makedirs(label_train_dir, exist_ok=True)
    os.makedirs(label_val_dir, exist_ok=True)

    # העתק את התמונות וקבצי התוויות התואמים לתיקיות המתאימות
    for img_path in train_images:
        img_filename = os.path.basename(img_path)
        shutil.copy(img_path, train_dir)

        label_filename = os.path.splitext(img_filename)[0] + ".txt"
        label_path = os.path.join(labels_dir, label_filename)
        if os.path.exists(label_path):
            shutil.copy(label_path, label_train_dir)

    for img_path in val_images:
        img_filename = os.path.basename(img_path)
        shutil.copy(img_path, val_dir)

        label_filename = os.path.splitext(img_filename)[0] + ".txt"
        label_path = os.path.join(labels_dir, label_filename)
        if os.path.exists(label_path):
            shutil.copy(label_path, label_val_dir)

    # בנה names - לפי תקיית objects (רק ב-head_camera)
    class_names = []
    if camera_type == "head_camera" and os.path.exists(objects_dir):
        class_names = [d for d in os.listdir(objects_dir) if os.path.isdir(os.path.join(objects_dir, d))]

    names_dict = {i: name for i, name in enumerate(class_names)}

    dataset_dict = {
        "train": "images/train",
        "val": "images/val",
        "names": names_dict
    }

    dataset_dict.pop("path", None)
    # כתוב קובץ YAML
    dataset_yaml_path = os.path.join(base_dir, "dataset.yaml")
    with open(dataset_yaml_path, 'w') as f:
        yaml.dump(dataset_dict, f)

    print(f"Created dataset.yaml at {dataset_yaml_path}")

    return dataset_yaml_path

# דוגמה להרצה
# create_dataset_yaml(user_id=123, camera_type="static_camera")
