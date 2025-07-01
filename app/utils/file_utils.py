import os
import shutil
import re

# Delete the folder containing a specific class's data
def delete_class_data(base_path: str, class_name: str):
    class_path = os.path.join(base_path, "objects", class_name)
    if os.path.exists(class_path):
        shutil.rmtree(class_path)

# Helper to find the next available numeric index for renaming files
def _get_next_index(folder_path: str, prefix: str):
    existing_files = os.listdir(folder_path) if os.path.exists(folder_path) else []
    max_index = -1
    pattern = re.compile(rf"{prefix}_(\d+)\.")  # match prefix_#.<ext>

    for filename in existing_files:
        match = pattern.match(filename)
        if match:
            index = int(match.group(1))
            max_index = max(max_index, index)

    return max_index + 1

# Move and rename files from temp folder to the destination, ensuring unique names
def _save_and_rename_files(temp_folder: str, dest_folder: str, files: list[str], baby_profile_id: int, model_type: str, file_type: str, class_name: str):
    os.makedirs(dest_folder, exist_ok=True)
    prefix = f"{baby_profile_id}_{model_type}_{class_name}"
    next_index = _get_next_index(dest_folder, prefix)

    new_filenames = []

    for file in files:
        src = os.path.join(temp_folder, file)
        extension = os.path.splitext(file)[1]
        new_filename = f"{prefix}_{next_index}{extension}"  # e.g., 123_head_camera_knife_0.jpg
        dst = os.path.join(dest_folder, new_filename)
        shutil.move(src, dst)
        new_filenames.append(new_filename)
        next_index += 1

    return new_filenames

# Add a new class and move its associated image/label files into the dataset structure
def add_class_data(base_path: str, item, baby_profile_id: int, model_type: str):
    class_path = os.path.join(base_path, "objects", item.name)
    images_path = os.path.join(class_path, "images")
    labels_path = os.path.join(class_path, "labels")
    os.makedirs(images_path, exist_ok=True)
    os.makedirs(labels_path, exist_ok=True)

    temp_folder = os.path.join("uploads", "temp")

    # Move image and label files to the proper locations
    _save_and_rename_files(temp_folder, images_path, item.files.images, baby_profile_id, model_type, "image", item.name)
    _save_and_rename_files(temp_folder, labels_path, item.files.labels, baby_profile_id, model_type, "label", item.name)

# Append additional files to an existing class folder
def append_to_class_data(base_path: str, item, baby_profile_id: int, model_type: str):
    class_path = os.path.join(base_path, "objects", item.name)
    images_path = os.path.join(class_path, "images")
    labels_path = os.path.join(class_path, "labels")

    if not os.path.exists(images_path) or not os.path.exists(labels_path):
        raise FileNotFoundError(f"Class folder {item.name} not found.")

    temp_folder = os.path.join("uploads", "temp")

    # Move new image and label files to the existing class folders
    _save_and_rename_files(temp_folder, images_path, item.files.images, baby_profile_id, model_type, "image", item.name)
    _save_and_rename_files(temp_folder, labels_path, item.files.labels, baby_profile_id, model_type, "label", item.name)
