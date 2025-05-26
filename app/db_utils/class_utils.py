from sqlalchemy.orm import Session
from app.models.class_model import ClassObject
from app.schemas.model_update_schema import ClassItem

def insert_new_classes(db: Session, baby_profile_id: int, new_classes: list[ClassItem], camera_type: str):
    for item in new_classes:
        class_obj = ClassObject(
            name=item.name,
            risk_level=item.risk_level,
            baby_profile_id=baby_profile_id,
            camera_type=camera_type
        )
        db.add(class_obj)
    db.commit()

def delete_db_classes(db: Session, baby_profile_id: int, class_names: list[str]):
    db.query(ClassObject).filter(
        ClassObject.baby_profile_id == baby_profile_id,
        ClassObject.name.in_(class_names)
    ).delete(synchronize_session=False)
    db.commit()

def update_db_classes(db: Session, baby_profile_id: int, camera_type: str, updated_classes: list[ClassItem]):
    for item in updated_classes:
        existing_class = db.query(ClassObject).filter_by(
            baby_profile_id=baby_profile_id,
            camera_type=camera_type,
            name=item.name
        ).first()
        if existing_class:
            existing_class.risk_level = item.risk_level
    db.commit()

def sync_model_indexes_to_classes(db: Session, baby_profile_id: int, camera_type: str, name_to_index: dict[str, int]):
    existing_classes = db.query(ClassObject).filter_by(
        baby_profile_id=baby_profile_id,
        camera_type=camera_type
    ).all()

    for cls in existing_classes:
        if cls.name in name_to_index:
            cls.model_index = name_to_index[cls.name]

    db.commit()
