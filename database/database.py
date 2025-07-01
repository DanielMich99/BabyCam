import os
import urllib.parse
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv
from app.models.base import Base  # Import only the declarative Base, models are imported elsewhere

# Load environment variables from .env file
load_dotenv()

# Encode the password in case it contains special characters
password = urllib.parse.quote_plus(os.getenv("DB_PASSWORD"))

# Construct the full database URL for PostgreSQL
DATABASE_URL = (
    f"postgresql://{os.getenv('DB_USERNAME')}:{password}@{os.getenv('DB_HOST')}:"
    f"{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
)

print("🔧 DATABASE_URL =", DATABASE_URL)

# Create the SQLAlchemy engine
engine = create_engine(DATABASE_URL)

# Create a configured "SessionLocal" class for database sessions
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Dependency that provides a database session to FastAPI routes/services
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Optional: This block can be used to auto-create tables if needed
if __name__ == "__main__":
    pass  # You could call Base.metadata.create_all(bind=engine) here if needed
