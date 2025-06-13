import os

def list_txt_files_with_quotes(folder_path: str):
    if not os.path.isdir(folder_path):
        print("Invalid folder path.")
        return

    txt_files = [f'"{filename}"' for filename in os.listdir(folder_path) if filename.endswith(".txt")]
    print(", ".join(txt_files))
    print()
    img_files = [f'"{filename}"' for filename in os.listdir(folder_path) if filename.endswith(".jpg")]
    print(", ".join(img_files))

# דוגמה לשימוש:
list_txt_files_with_quotes("C:\\Users\\Daniel Michaelshvili\\Desktop\\captured_frames_candy")