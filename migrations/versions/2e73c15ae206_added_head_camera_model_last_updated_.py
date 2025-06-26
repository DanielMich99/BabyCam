"""added 'head_camera_model_last_updated_time' and 'static_camera_model_last_updated_time' columns to 'baby_profiles' table.

Revision ID: 2e73c15ae206
Revises: acbaa41dcae6
Create Date: 2025-06-25 21:15:14.686564
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '2e73c15ae206'
down_revision: Union[str, None] = 'acbaa41dcae6'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    # Add columns with a temporary default value to avoid NOT NULL violation
    op.add_column('baby_profiles', sa.Column(
        'head_camera_on',
        sa.Boolean(),
        nullable=False,
        server_default=sa.text('false')
    ))
    op.add_column('baby_profiles', sa.Column(
        'static_camera_on',
        sa.Boolean(),
        nullable=False,
        server_default=sa.text('false')
    ))

    # Remove default if not needed going forward
    op.alter_column('baby_profiles', 'head_camera_on', server_default=None)
    op.alter_column('baby_profiles', 'static_camera_on', server_default=None)


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_column('baby_profiles', 'static_camera_on')
    op.drop_column('baby_profiles', 'head_camera_on')
