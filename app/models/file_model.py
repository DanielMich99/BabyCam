from sqlalchemy import Column, String, Integer, ForeignKey
from app.models.base import Base

class File(Base):
    __tablename__ = "files"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    filename = Column(String, nullable=False)
    path = Column(String, nullable=False)
