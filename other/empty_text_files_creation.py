import os

def create_empty_test_files(target_dir: str, count: int):
    os.makedirs(target_dir, exist_ok=True)
    for i in range(count):
        file_path = os.path.join(target_dir, f"candy_head_camera_{i}.txt")
        with open(file_path, 'w') as f:
            pass  # יוצר קובץ ריק
    print(f"{count} empty test files created in: {target_dir}")

# דוגמה לשימוש:
create_empty_test_files("C:\\Users\\Daniel Michaelshvili\\Desktop\\labels_temp", 117)
