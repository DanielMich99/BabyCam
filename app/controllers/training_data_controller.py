from fastapi import UploadFile
from app.services import training_data_service
from fastapi import HTTPException
from app.services.video_processing_service import extract_frames

async def upload_training_image(user_id: int, object_name: str, image: UploadFile):
    try:
        path = training_data_service.save_image(user_id, object_name, image)
        return {"message": "Image uploaded successfully.", "path": path}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

async def upload_training_video(user_id: int, scene_name: str, video: UploadFile):
    try:
        # שלב 1: שמור את הסרטון
        video_path = training_data_service.save_video(user_id, scene_name, video)

        # שלב 2: הגדר נתיב שמירה לפריימים
        video_filename = os.path.splitext(os.path.basename(video_path))[0]
        frame_output_dir = os.path.join(
            os.path.dirname(video_path),
            f"frames_{video_filename}")

        # שלב 3: חילוץ פריימים
        extract_frames(video_path, frame_output_dir, frame_interval=15)

        return {
            "message": "Video uploaded and frames extracted successfully.",
            "video_path": video_path,
            "frames_dir": frame_output_dir
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
