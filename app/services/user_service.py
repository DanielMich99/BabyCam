from sqlalchemy.orm import Session
from app.models.user_model import User
from app.schemas import user_schema
from app.utils.hashing import hash_password

# יצירה
def create_user(db: Session, user_data: user_schema.UserCreate):
    hashed_pw = hash_password(user_data.password)
    db_user = User(
        username=user_data.username,
        email=user_data.email,
        hashed_password=hashed_pw
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

# שליפה לפי ID
def get_user_by_id(db: Session, user_id: int):
    return db.query(User).filter(User.id == user_id).first()

# עדכון
def update_user(db: Session, user_id: int, update_data: user_schema.UserUpdate):
    db_user = db.query(User).filter(User.id == user_id).first()
    if db_user is None:
        return None

    update_dict = update_data.dict(exclude_unset=True)

    if "password" in update_dict and update_dict["password"] is not None:
        update_dict["hashed_password"] = hash_password(update_dict.pop("password"))

    for key, value in update_dict.items():
        setattr(db_user, key, value)

    db.commit()
    db.refresh(db_user)
    return db_user

# מחיקה
def delete_user(db: Session, user_id: int):
    db_user = db.query(User).filter(User.id == user_id).first()
    if db_user is None:
        return None

    db.delete(db_user)
    db.commit()
    return db_user
