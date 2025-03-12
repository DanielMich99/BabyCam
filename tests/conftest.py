import pytest
from httpx import AsyncClient
from main import app

@pytest.fixture
async def client():
    """Fixture גלובלי ליצירת client אסינכרוני שישמש בכל הבדיקות"""
    async with AsyncClient(app=app, base_url="http://test") as ac:
        yield ac
