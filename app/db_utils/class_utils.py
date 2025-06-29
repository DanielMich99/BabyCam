from sqlalchemy.orm import Session
from app.models.class_model import ClassObject
from app.models.detection_result_model import DetectionResult
from app.schemas.model_update_schema import ClassItem

def insert_new_classes(db: Session, baby_profile_id: int, new_classes: list[ClassItem], model_type: str):
    current_count = db.query(ClassObject).filter_by(baby_profile_id=baby_profile_id, camera_type=model_type).count()

    for idx, item in enumerate(new_classes):
        new_class = ClassObject(
            name=item.name,
            risk_level=item.risk_level,
            model_index=current_count + idx,
            camera_type=model_type,
            baby_profile_id=baby_profile_id
        )
        db.add(new_class)
    db.commit()

def delete_db_classes(db: Session, baby_profile_id: int, deleted_classes: list[str], model_type: str):
    # שלב 1: מחיקת detection_results שמשויכים לקלאסים שיימחקו
    class_ids_to_delete = db.query(ClassObject.id).filter(
        ClassObject.baby_profile_id == baby_profile_id,
        ClassObject.camera_type == model_type,
        ClassObject.name.in_(deleted_classes)
    ).subquery()

    db.query(DetectionResult).filter(
        DetectionResult.class_id.in_(class_ids_to_delete)
    ).delete(synchronize_session=False)

    # שלב 2: מחיקת הקלאסים עצמם
    db.query(ClassObject).filter(
        ClassObject.baby_profile_id == baby_profile_id,
        ClassObject.camera_type == model_type,
        ClassObject.name.in_(deleted_classes)
    ).delete(synchronize_session=False)

    db.commit()

    # שלב 3: עדכון אינדקסים
    remaining_classes = db.query(ClassObject).filter_by(
        baby_profile_id=baby_profile_id, camera_type=model_type
    ).order_by(ClassObject.model_index.asc()).all()

    for idx, cls in enumerate(remaining_classes):
        cls.model_index = idx

    db.commit()

def update_db_classes(db: Session, baby_profile_id: int, updated_classes: list[ClassItem], model_type: str):
    for item in updated_classes:
        db_class = db.query(ClassObject).filter_by(
            baby_profile_id=baby_profile_id,
            camera_type=model_type,
            name=item.name
        ).first()
        if db_class:
            db_class.risk_level = item.risk_level
    db.commit()
