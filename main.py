from fastapi import FastAPI
from app.routes.auth_routes import router as auth_router
from app.routes.file_routes import router as file_router
from app.routes.user_routes import router as user_router
from app.routes.camera_routes import router as camera_router
from app.models.base import init_db
import sys
import os

sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))

app = FastAPI()

# אתחול מסד הנתונים
init_db()

# חיבור הנתיבים מהתיקייה `app/routes/`
app.include_router(auth_router, prefix="/auth", tags=["Authentication"])
app.include_router(file_router, prefix="/files", tags=["File Management"])
app.include_router(user_router, prefix="/users", tags=["User Management"])
app.include_router(camera_router, prefix="/camera", tags=["Camera"])

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
