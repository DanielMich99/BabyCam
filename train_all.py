# train_all.py

from app.services.training_scheduler_service import process_all_users

if __name__ == "__main__":
    print("[INFO] Starting scheduled training process...")
    process_all_users()
    print("[DONE] Training check completed.")
