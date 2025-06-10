import os
import cv2

def extract_frames(video_path: str, output_dir: str, frame_interval: int = 15):
    """
    Extract frames from a video every `frame_interval` frames.
    
    Args:
        video_path (str): Path to the input video.
        output_dir (str): Directory to save extracted frames.
        frame_interval (int): Number of frames to skip between each saved frame.
    """
    os.makedirs(output_dir, exist_ok=True)
    
    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        raise ValueError(f"Error opening video file {video_path}")

    frame_count = 0
    saved_count = 0

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        if frame_count % frame_interval == 0:
            frame_filename = os.path.join(output_dir, f"frame_{saved_count:04d}.jpg")
            cv2.imwrite(frame_filename, frame)
            saved_count += 1

        frame_count += 1

    cap.release()
    print(f"Extracted {saved_count} frames to {output_dir}")
