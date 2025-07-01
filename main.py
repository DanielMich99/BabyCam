from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.services import training_monitor_service
from app.routes.auth_routes import router as auth_router
from app.routes.user_routes import router as user_router
from app.routes.model_update_routes import router as model_update_router
from app.routes import upload_temp_routes
from app.routes.camera_connection_route import router as camera_router
from app.routes.monitoring_routes import router as monitoring_router
from app.routes import baby_profile_routes
from app.routes import detection_result_routes
from app.routes import streams_routes
from app.routes import realtime_routes
from app.routes import class_routes
from app.routes import class_suggestion_routes
from database.init_db import init_db
import sys
import os
from fastapi.openapi.utils import get_openapi

# Ensure the current directory is added to the Python path
sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))

# Initialize FastAPI application
app = FastAPI()

# Start background thread for monitoring when model training finishes
training_monitor_service.start_monitoring_thread()

# Custom OpenAPI schema with JWT bearer authentication added
def custom_openapi():
    if app.openapi_schema:
        return app.openapi_schema

    openapi_schema = get_openapi(
        title="BabyCam API",
        version="1.0",
        description="Backend secured API for BabyCam project",
        routes=app.routes,
    )

    # Add JWT security scheme to OpenAPI
    openapi_schema["components"]["securitySchemes"] = {
        "BearerAuth": {
            "type": "http",
            "scheme": "bearer",
            "bearerFormat": "JWT",
        }
    }

    # Apply the security scheme globally to all endpoints
    for path in openapi_schema["paths"].values():
        for method in path.values():
            method["security"] = [{"BearerAuth": []}]
    
    app.openapi_schema = openapi_schema
    return app.openapi_schema

# Override the default OpenAPI schema generator
app.openapi = custom_openapi

# Enable Cross-Origin Resource Sharing (CORS) for all origins
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow requests from any origin
    allow_credentials=True,
    allow_methods=["*"],  # Allow all HTTP methods
    allow_headers=["*"],  # Allow all headers
)

# Initialize database (create tables if needed)
init_db()

# Include API routes from the routes directory
app.include_router(auth_router, prefix="/auth", tags=["Authentication"])
app.include_router(user_router)
app.include_router(model_update_router, tags=["Model Update"])
app.include_router(upload_temp_routes.router)
app.include_router(camera_router, tags=["Cameras Managment"])
app.include_router(monitoring_router, tags=["Detection System Managment"])
app.include_router(baby_profile_routes.router)
app.include_router(detection_result_routes.router)
app.include_router(streams_routes.router, prefix="/api/streaming", tags=["Streaming"])
app.include_router(realtime_routes.router)
app.include_router(class_routes.router)
app.include_router(class_suggestion_routes.router)

# Run the server manually (for development/testing)
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
