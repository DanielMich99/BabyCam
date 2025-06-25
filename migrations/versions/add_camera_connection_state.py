"""add camera connection state

Revision ID: add_camera_connection_state
Revises: c1e86434bdd4
Create Date: 2024-01-01 12:00:00.000000

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'add_camera_connection_state'
down_revision = 'c1e86434bdd4'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Add camera connection state columns
    op.add_column('baby_profiles', sa.Column('head_camera_on', sa.Boolean(), nullable=False, server_default='false'))
    op.add_column('baby_profiles', sa.Column('static_camera_on', sa.Boolean(), nullable=False, server_default='false'))


def downgrade() -> None:
    # Remove camera connection state columns
    op.drop_column('baby_profiles', 'head_camera_on')
    op.drop_column('baby_profiles', 'static_camera_on') 