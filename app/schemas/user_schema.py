from pydantic import BaseModel, EmailStr
from typing import Optional

class UserBase(BaseModel):
    username: str
    email: EmailStr

class UserCreate(UserBase):
    password: str  # הסיסמה תגיע כרגיל, תדע שהיא לא hashed כאן

class UserUpdate(BaseModel):
    username: Optional[str] = None
    email: Optional[EmailStr] = None
    password: Optional[str] = None
    fcm_token: Optional[str] = None

class UserOut(UserBase):
    id: int
    fcm_token: Optional[str] = None

    class Config:
        from_attrributes = True
