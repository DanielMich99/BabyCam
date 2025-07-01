import os
import yaml
import random
import shutil
import glob
from sqlalchemy.orm import Session
from app.models.class_model import ClassObject

def update_dataset_yaml(db: Session, model_folder: str, baby_profile_id: int, model_type: str) -> dict:
    """
    Rewrites the dataset.yaml file with class index mappings.
    This file is required by YOLOv8 training.

    Returns:
        dict: A mapping from class name to index for relabeling label files.
    """
    db_classes = db.query(ClassObject).filter_by(
        baby_profile_id=baby_profile_id, camera_type=model_type
    ).order_by(ClassObject.model_index.asc()).all()

    name_to_index = {cls.name: cls.model_index for cls in db_classes}
    index_to_name = {v: k for k, v in name_to_index.items()}

    dataset_yaml = {
        'train': 'images/train',
        'val': 'images/val',
        'names': index_to_name  # YOLO expects index → class name mapping
    }

    yaml_path = os.path.join(model_folder, "dataset.yaml")
    with open(yaml_path, 'w') as f:
        yaml.dump(dataset_yaml, f)

    return name_to_index


def remap_labels_to_new_indexes(class_mapping: dict, model_folder: str):
    """
    Updates YOLO label files to reflect new class indexes.

    Args:
        class_mapping (dict): class_name → new_index mapping
        model_folder (str): Path to the model directory
    """
    objects_path = os.path.join(model_folder, "objects")

    for class_name, new_index in class_mapping.items():
        labels_dir = os.path.join(objects_path, class_name, "labels")
        if not os.path.exists(labels_dir):
            continue

        for label_file in os.listdir(labels_dir):
            label_path = os.path.join(labels_dir, label_file)
            with open(label_path, "r") as f:
                lines = f.readlines()

            new_lines = []
            for line in lines:
                parts = line.strip().split()
                if len(parts) != 5:
                    continue  # Skip malformed lines
                parts[0] = str(new_index)  # Update class index
                new_lines.append(" ".join(parts) + "\n")

            with open(label_path, "w") as f:
                f.writelines(new_lines)


def rebuild_training_folders(model_folder: str, val_split_ratio: float = 0.2):
    """
    Builds the YOLO training and validation folders.

    Args:
        model_folder (str): Path to the training model folder
        val_split_ratio (float): Ratio of validation data to total dataset
    """
    # Define target folders for images and labels
    image_train = os.path.join(model_folder, "images/train")
    image_val = os.path.join(model_folder, "images/val")
    label_train = os.path.join(model_folder, "labels/train")
    label_val = os.path.join(model_folder, "labels/val")

    # Clean up old folders and recreate them
    for folder in [image_train, image_val, label_train, label_val]:
        shutil.rmtree(folder, ignore_errors=True)
        os.makedirs(folder, exist_ok=True)

    # Collect all (image, label) pairs
    objects_path = os.path.join(model_folder, "objects")
    image_label_pairs = []

    for class_name in os.listdir(objects_path):
        class_path = os.path.join(objects_path, class_name)
        img_dir = os.path.join(class_path, "images")
        lbl_dir = os.path.join(class_path, "labels")

        if not os.path.exists(img_dir) or not os.path.exists(lbl_dir):
            continue

        for img_path in glob.glob(os.path.join(img_dir, "*")):
            filename = os.path.basename(img_path)
            label_path = os.path.join(lbl_dir, os.path.splitext(filename)[0] + ".txt")
            if os.path.exists(label_path):
                image_label_pairs.append((img_path, label_path))

    # Shuffle and split dataset into train and validation
    random.shuffle(image_label_pairs)
    split_index = int(len(image_label_pairs) * (1 - val_split_ratio))
    train_pairs = image_label_pairs[:split_index]
    val_pairs = image_label_pairs[split_index:]

    # Copy files into their respective folders
    for img, lbl in train_pairs:
        shutil.copy2(img, os.path.join(image_train, os.path.basename(img)))
        shutil.copy2(lbl, os.path.join(label_train, os.path.basename(lbl)))

    for img, lbl in val_pairs:
        shutil.copy2(img, os.path.join(image_val, os.path.basename(img)))
        shutil.copy2(lbl, os.path.join(label_val, os.path.basename(lbl)))
