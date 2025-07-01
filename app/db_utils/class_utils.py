from sqlalchemy.orm import Session
from app.models.class_model import ClassObject
from app.models.detection_result_model import DetectionResult
from app.schemas.model_update_schema import ClassItem

# Inserts new class entries for a given baby profile and camera type.
# Each new class is assigned a model_index based on current class count.
def insert_new_classes(db: Session, baby_profile_id: int, new_classes: list[ClassItem], model_type: str):
    current_count = db.query(ClassObject).filter_by(baby_profile_id=baby_profile_id, camera_type=model_type).count()

    for idx, item in enumerate(new_classes):
        new_class = ClassObject(
            name=item.name,
            risk_level=item.risk_level,
            model_index=current_count + idx,  # Assign model index after existing classes
            camera_type=model_type,
            baby_profile_id=baby_profile_id
        )
        db.add(new_class)
    db.commit()

# Deletes the specified class names for a given baby profile and camera type.
# Also removes all detection results associated with those classes and reorders remaining model_index values.
def delete_db_classes(db: Session, baby_profile_id: int, deleted_classes: list[str], model_type: str):
    # Step 1: Delete detection results tied to the classes being deleted
    class_ids_to_delete = db.query(ClassObject.id).filter(
        ClassObject.baby_profile_id == baby_profile_id,
        ClassObject.camera_type == model_type,
        ClassObject.name.in_(deleted_classes)
    ).subquery()

    db.query(DetectionResult).filter(
        DetectionResult.class_id.in_(class_ids_to_delete)
    ).delete(synchronize_session=False)

    # Step 2: Delete the class entries themselves
    db.query(ClassObject).filter(
        ClassObject.baby_profile_id == baby_profile_id,
        ClassObject.camera_type == model_type,
        ClassObject.name.in_(deleted_classes)
    ).delete(synchronize_session=False)

    db.commit()

    # Step 3: Reassign model_index to remaining classes
    remaining_classes = db.query(ClassObject).filter_by(
        baby_profile_id=baby_profile_id, camera_type=model_type
    ).order_by(ClassObject.model_index.asc()).all()

    for idx, cls in enumerate(remaining_classes):
        cls.model_index = idx  # Reindex remaining classes sequentially

    db.commit()

# Updates risk_level for existing classes that match by name, profile, and camera type.
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
