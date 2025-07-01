from sqlalchemy import Column, Integer, String, ForeignKey, Boolean
from sqlalchemy.orm import relationship
from app.models.base import Base

# SQLAlchemy model representing a user in the system
class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)  # Unique user ID
    username = Column(String, unique=True, nullable=False)  # Unique username
    email = Column(String, unique=True, nullable=False)  # Unique email address
    hashed_password = Column(String, nullable=False)  # Hashed user password
    already_logged_in = Column(Boolean, default=False, nullable=False)  # Used for session state tracking

    # One-to-many relationship to FCM tokens for push notifications
    fcm_tokens = relationship("UserFCMToken", back_populates="user", cascade="all, delete-orphan")


# SQLAlchemy model representing a single FCM token associated with a user (for push notifications)
class UserFCMToken(Base):
    __tablename__ = "user_fcm_tokens"

    id = Column(Integer, primary_key=True, index=True)  # Unique token ID
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)  # Link to associated user
    token = Column(String, nullable=False, unique=True)  # FCM token value (must be unique per device)

    # Back reference to the user
    user = relationship("User", back_populates="fcm_tokens")
