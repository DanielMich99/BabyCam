from sqlalchemy.orm import Session
from fastapi import HTTPException
from typing import List

from app.models.baby_profile_model import BabyProfile
from app.utils.ai_helper import get_ai_response


def suggest_classes_for_baby_profile(
    db: Session, user_id: int, baby_profile_id: int, camera_type: str
) -> List[str]:
    """Fetches baby profile, sends details to ChatGPT and returns suggested classes."""
    profile = db.query(BabyProfile).filter_by(id=baby_profile_id, user_id=user_id).first()
    if not profile:
        raise HTTPException(status_code=403, detail="Access denied to baby profile")

    prompt = (
    f"You are a safety expert assisting in object detection for infant safety monitoring.\n"
    f"The goal is to generate a list of dangerous objects relevant to the following baby:\n"
    f"- Name: {profile.name}\n"
    f"- Age: {profile.age} months\n"
    f"- Gender: {profile.gender}\n"
    f"- Weight: {profile.weight} kg\n"
    f"- Height: {profile.height} cm\n"
    f"- Medical condition: {profile.medical_condition or 'None'}\n\n"

    f"Camera type is one of two:\n"
    f"- 'static_camera': A fixed-position camera that monitors the entire room from a distance (e.g. mounted on a wall or shelf). "
    f"Best suited for detecting environmental hazards like stairs, heaters, or dangerous furniture.\n"
    f"- 'head_camera': A wearable camera attached to the baby's head, capturing close-up, eye-level views of the baby's surroundings. "
    f"Ideal for detecting small nearby objects like toys, pills, or wires that the baby may reach or interact with directly.\n"
    f"The current camera type is: {camera_type}.\n\n"

    "When using 'static_camera', class names should describe not just the object, but also the baby's relation to the danger. For example:\n"
    "- \"baby climbing stairs\"\n"
    "- \"baby near open window\"\n"
    "- \"baby reaching heater\"\n"
    "These class names should reflect potential interactions between the baby and the hazard, as seen from a distant, wide-angle view.\n\n"

    "Based on the baby's profile and the camera type, return a short newline-separated list of object detection class names "
    "that should be prioritized to identify potentially hazardous items. Do not include any explanation or extra text—just the class names."
    )

    classes = get_ai_response(prompt)
    return [c.strip() for c in classes if c.strip()]