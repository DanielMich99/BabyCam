from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.services import training_monitor_service
from app.routes.auth_routes import router as auth_router
from app.routes.file_routes import router as file_router
from app.routes.user_routes import router as user_router
from app.routes.camera_routes import router as camera_router
from app.routes.alert_routes import router as alert_router
from app.routes.detection_routes import router as detection_router
from app.routes.class_routes import router as class_router
from app.routes.baby_profile_routes import router as baby_profile_router
from app.routes.dangerous_objects_routes import router as dangerous_objects_router
from app.routes import training_data_routes
from app.routes.model_update_routes import router as model_update_router
from app.routes import upload_temp_routes
from app.routes.camera_connection_route import router as camera_router
from app.routes.monitoring_routes import router as monitoring_router
from app.routes import baby_profile_routes
from app.routes import detection_result_routes
from app.routes import streams_routes
from app.routes import realtime_routes
from app.routes import class_routes
from database.init_db import init_db
import sys
import os
from fastapi.openapi.utils import get_openapi

sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))

app = FastAPI()

training_monitor_service.start_monitoring_thread()

def custom_openapi():
    if app.openapi_schema:
        return app.openapi_schema

    openapi_schema = get_openapi(
        title="BabyCam API",
        version="1.0",
        description="Backend secured API for BabyCam project",
        routes=app.routes,
    )
    openapi_schema["components"]["securitySchemes"] = {
        "BearerAuth": {
            "type": "http",
            "scheme": "bearer",
            "bearerFormat": "JWT",
        }
    }
    for path in openapi_schema["paths"].values():
        for method in path.values():
            method["security"] = [{"BearerAuth": []}]
    app.openapi_schema = openapi_schema
    return app.openapi_schema

app.openapi = custom_openapi

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

# אתחול מסד הנתונים
init_db()

# חיבור הנתיבים מהתיקייה `app/routes/`
app.include_router(auth_router, prefix="/auth", tags=["Authentication"])
#app.include_router(file_router, prefix="/files", tags=["File Management"])
app.include_router(user_router)
#app.include_router(camera_router, prefix="/camera", tags=["Camera"])
#app.include_router(alert_router, prefix="/alerts", tags=["Alerts"])
#app.include_router(detection_router, prefix="/detection", tags=["Detection"])
#app.include_router(baby_profile_router, prefix="/baby_profile", tags=["Baby Profile"])
#app.include_router(dangerous_objects_router, prefix="/dangerous_objects", tags=["Dangerous Objects"])
#app.include_router(training_data_routes.router)
app.include_router(model_update_router, tags=["Model Update"])
app.include_router(upload_temp_routes.router)
app.include_router(camera_router, tags=["Cameras Managment"])
app.include_router(monitoring_router, tags=["Detection System Managment"])
app.include_router(baby_profile_routes.router)
app.include_router(detection_result_routes.router)
app.include_router(streams_routes.router, prefix="/api/streaming", tags=["Streaming"])
app.include_router(realtime_routes.router)
app.include_router(class_routes.router)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
