from sqlalchemy.orm import declarative_base

# Create a base class for all SQLAlchemy models
Base = declarative_base()

# Import all models so Alembic can detect and include them in migrations
from app.models import (
    user_model,
    baby_profile_model,
    detection_result_model,
    class_model
)