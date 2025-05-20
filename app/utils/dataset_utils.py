import os
import yaml
import random
import shutil
import glob

'''def update_dataset_yaml(model_folder: str) -> dict:
    """
    Rewrites dataset.yaml with updated class list from objects folder.
    Returns the mapping {class_name: index} for relabeling purposes.
    """
    objects_path = os.path.join(model_folder, "objects")
    class_names = sorted(
        [name for name in os.listdir(objects_path) if os.path.isdir(os.path.join(objects_path, name))]
    )

    name_to_index = {name: i for i, name in enumerate(class_names)}
    index_to_name = {i: name for name, i in name_to_index.items()}

    dataset_yaml = {
        'path': model_folder,
        'train': 'images/train',
        'val': 'images/val',
        'names': index_to_name
    }

    yaml_path = os.path.join(model_folder, "dataset.yaml")
    with open(yaml_path, 'w') as f:
        yaml.dump(dataset_yaml, f)

    return name_to_index  # {class_name: index}
'''
def update_dataset_yaml(model_folder: str) -> dict:
    """
    Rewrites dataset.yaml with updated class list from objects folder.
    Returns the mapping {class_name: index} for relabeling purposes.
    """
    objects_path = os.path.join(model_folder, "objects")
    class_names = sorted(
        [name for name in os.listdir(objects_path) if os.path.isdir(os.path.join(objects_path, name))]
    )

    name_to_index = {name: i for i, name in enumerate(class_names)}
    index_to_name = {i: name for name, i in name_to_index.items()}

    dataset_yaml = {
        'train': 'images/train',
        'val': 'images/val',
        'names': index_to_name
    }

    yaml_path = os.path.join(model_folder, "dataset.yaml")
    with open(yaml_path, 'w') as f:
        yaml.dump(dataset_yaml, f)

    return name_to_index

def remap_labels_to_new_indexes(class_mapping: dict, model_folder: str):
    """
    Rewrites all label files under objects/*/labels/ using new class index mapping.
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
                    continue  # לא שורה תקינה
                parts[0] = str(new_index)
                new_lines.append(" ".join(parts) + "\n")

            with open(label_path, "w") as f:
                f.writelines(new_lines)


def rebuild_training_folders(model_folder: str, val_split_ratio: float = 0.2):
    """
    Gathers all images and labels from all classes and organizes them into train/val folders.
    """
    # Define target folders
    image_train = os.path.join(model_folder, "images/train")
    image_val = os.path.join(model_folder, "images/val")
    label_train = os.path.join(model_folder, "labels/train")
    label_val = os.path.join(model_folder, "labels/val")

    # Clear existing folders
    for folder in [image_train, image_val, label_train, label_val]:
        shutil.rmtree(folder, ignore_errors=True)
        os.makedirs(folder, exist_ok=True)

    # Gather all image-label pairs from each class
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

    # Shuffle & split
    random.shuffle(image_label_pairs)
    split_index = int(len(image_label_pairs) * (1 - val_split_ratio))
    train_pairs = image_label_pairs[:split_index]
    val_pairs = image_label_pairs[split_index:]

    # Copy to respective folders
    for img, lbl in train_pairs:
        shutil.copy2(img, os.path.join(image_train, os.path.basename(img)))
        shutil.copy2(lbl, os.path.join(label_train, os.path.basename(lbl)))

    for img, lbl in val_pairs:
        shutil.copy2(img, os.path.join(image_val, os.path.basename(img)))
        shutil.copy2(lbl, os.path.join(label_val, os.path.basename(lbl)))
