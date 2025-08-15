Here’s a complete README.md draft for your project based on your architecture document and what I know about your BabyCam backend:

BabyCam – Infant Safety Monitoring System
📌 Overview

BabyCam is an innovative system for monitoring infants near hazardous objects using smart cameras integrated with machine learning. The system sends real-time alerts to parents and enables live monitoring, hazard customization, and cloud-based history tracking.
It is designed to be easy-to-use, privacy-focused, and highly reliable, ensuring the safety and peace of mind of caregivers.

🚀 Features

Real-time Object Detection – Detects hazardous objects using YOLO-based ML models.

Multiple Camera Types – Supports both wearable head cameras and static cameras.

Live Streaming – View real-time camera feeds via mobile app.

Custom Hazard Management – Add, update, or remove objects to monitor.

Alert System – Sends push notifications when hazards are detected.

Cloud Integration – Training data, model files, and alerts stored and managed in the cloud.

User Profiles – Multiple baby profiles with separate camera and hazard configurations.

Connection Monitoring – Alerts when a camera disconnects.

🛠 Technologies Used
Backend

Language: Python

Framework: FastAPI (REST API + WebSockets)

Database: Firebase Realtime Database + PostgreSQL (SQLAlchemy ORM)

Cloud: Google Cloud Platform (Cloud Run, Cloud Functions, Google Drive integration)

Machine Learning: YOLOv8 for object detection

ESP32-CAM Streaming: Based on ESP32-CAM-MJPEG-Multiclient

Frontend

Framework: Flutter (Android, iOS, Web support)

Tools & Development

Git & GitHub for version control

GitHub Copilot

ChatGPT

Cursor – AI Code Editor

📱 User Stories (Examples)

Live Video Feed – As a parent, I want to watch my infant’s activities in real-time.

Real-time Alerts – As a parent, I want to receive immediate notifications when a hazard is detected.

Weekly Hazard Summary – As a parent, I want a report of recurring risks.

Custom Sensitivity – As a parent, I want to adjust hazard detection sensitivity per baby profile.

Camera Disconnection Alerts – As a parent, I want to be notified when a camera disconnects.

📂 Project Structure
babycam-backend/
│
├── app/
│   ├── controllers/      # Request handling logic
│   ├── models/           # SQLAlchemy ORM models
│   ├── routes/           # API route definitions
│   ├── schemas/          # Pydantic schemas for validation
│   ├── services/         # Business logic
│   ├── utils/            # File handling, dataset utils, Drive API
│   └── db_utils/         # Database query helpers
│
├── database/             # DB initialization & migrations
├── migrations/           # Alembic migration scripts
├── frontend/              # Flutter app
└── requirements.txt

⚙️ Installation & Setup
1️⃣ Backend
# Clone the repository
git clone https://github.com/<your-repo>.git
cd babycam-backend

# Create and activate virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run database migrations
alembic upgrade head

# Start FastAPI server
uvicorn main:app --reload

2️⃣ Frontend (Flutter)
cd frontend
flutter pub get
flutter run

📡 API Endpoints (Examples)
Method	Endpoint	Description
POST	/auth/login	Authenticate a user
POST	/baby-profile	Create a baby profile
POST	/model/update	Update hazard detection model
POST	/camera/connect	Wait for ESP32-CAM connection
POST	/camera/disconnect	Disconnect a camera
GET	/streaming/stream/{profile_id}/{camera_type}	Get live stream
GET	/detection-results/my	Get detection history
🔒 Privacy & Security

All communications secured via HTTPS.

User data encrypted in transit and at rest.

Role-based access control for sensitive operations.

👥 Authors

Gil Matzafi – Backend & Cloud Integration

Daniel Michaelshvili – Backend, ML Pipeline, & System Architecture

Supervisor: Dr. Ariel Roth
