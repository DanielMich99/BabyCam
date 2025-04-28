from logging.config import fileConfig
from sqlalchemy import engine_from_config, pool
from alembic import context
import os
import urllib.parse
from dotenv import load_dotenv

# טען משתני סביבה
load_dotenv()

# יצירת ה-DB URL בצורה בטוחה
password = urllib.parse.quote_plus(os.getenv("DB_PASSWORD"))
database_url = f"postgresql://{os.getenv('DB_USERNAME')}:{password}@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"

# קבלת קונפיג של Alembic
config = context.config

# קונפיגורציה של לוגים
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# יבוא ה-Base של המודלים
from app.models.base import Base
target_metadata = Base.metadata

def get_url():
    return database_url

def run_migrations_offline() -> None:
    """הרצת מיגרציות במצב אופליין"""
    context.configure(
        url=get_url(),
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )
    with context.begin_transaction():
        context.run_migrations()

def run_migrations_online() -> None:
    """הרצת מיגרציות במצב אונליין"""
    connectable = engine_from_config(
        {"sqlalchemy.url": get_url()},
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )
    with connectable.connect() as connection:
        context.configure(
            connection=connection, target_metadata=target_metadata
        )
        with context.begin_transaction():
            context.run_migrations()

if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
