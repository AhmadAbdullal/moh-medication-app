"""Initial database schema"""

from alembic import op
import sqlalchemy as sa


revision = "202402290001"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "users",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("email", sa.String(), nullable=True),
        sa.Column("phone_number", sa.String(), nullable=True),
        sa.Column("hashed_password", sa.String(), nullable=True),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.sql.expression.true()),
        sa.Column("is_superuser", sa.Boolean(), nullable=False, server_default=sa.sql.expression.false()),
        sa.Column("created_at", sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.UniqueConstraint("email"),
        sa.UniqueConstraint("phone_number"),
    )
    op.create_index("ix_users_id", "users", ["id"], unique=False)
    op.create_index("ix_users_email", "users", ["email"], unique=False)
    op.create_index("ix_users_phone_number", "users", ["phone_number"], unique=False)

    op.create_table(
        "patients",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("user_id", sa.Integer(), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("full_name", sa.String(), nullable=False),
        sa.Column("date_of_birth", sa.Date(), nullable=True),
        sa.Column("medical_record_number", sa.String(), nullable=True),
        sa.UniqueConstraint("medical_record_number"),
    )
    op.create_index("ix_patients_id", "patients", ["id"], unique=False)

    op.create_table(
        "drugs_master",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("rx_cui", sa.String(), nullable=True),
        sa.Column("trade_name_en", sa.String(), nullable=True),
        sa.Column("trade_name_ar", sa.String(), nullable=True),
        sa.Column("generic_name", sa.String(), nullable=True),
        sa.Column("strength", sa.String(), nullable=True),
        sa.Column("dosage_form", sa.String(), nullable=True),
        sa.Column("source", sa.String(), nullable=True),
        sa.Column("source_url", sa.String(), nullable=True),
        sa.Column("source_version", sa.String(), nullable=True),
        sa.Column("verified_status", sa.String(), nullable=False, server_default="unverified"),
        sa.Column("last_updated", sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.UniqueConstraint("rx_cui"),
    )
    op.create_index("ix_drugs_master_id", "drugs_master", ["id"], unique=False)
    op.create_index("ix_drugs_master_rx_cui", "drugs_master", ["rx_cui"], unique=False)

    op.create_table(
        "drugs_local_kuwait",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("moh_code", sa.String(), nullable=False),
        sa.Column("trade_name_ar", sa.String(), nullable=True),
        sa.Column("generic_name", sa.String(), nullable=True),
        sa.Column("strength", sa.String(), nullable=True),
        sa.Column("dosage_form", sa.String(), nullable=True),
        sa.Column("source_file", sa.String(), nullable=True),
        sa.Column("extracted_at", sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.Column("matched_drug_id", sa.Integer(), sa.ForeignKey("drugs_master.id", ondelete="SET NULL"), nullable=True),
        sa.Column("match_confidence", sa.Numeric(4, 3), nullable=True),
        sa.UniqueConstraint("moh_code"),
    )
    op.create_index("ix_drugs_local_kuwait_id", "drugs_local_kuwait", ["id"], unique=False)

    op.create_table(
        "drug_schedules",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("patient_id", sa.Integer(), sa.ForeignKey("patients.id", ondelete="CASCADE"), nullable=False),
        sa.Column("drug_id", sa.Integer(), sa.ForeignKey("drugs_local_kuwait.id", ondelete="CASCADE"), nullable=False),
        sa.Column("dosage", sa.String(), nullable=False),
        sa.Column("frequency", sa.String(), nullable=False),
        sa.Column("start_date", sa.Date(), nullable=False),
        sa.Column("end_date", sa.Date(), nullable=True),
        sa.Column("instructions", sa.String(), nullable=True),
        sa.Column("reminder_time", sa.Time(), nullable=True),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.sql.expression.true()),
    )
    op.create_index("ix_drug_schedules_id", "drug_schedules", ["id"], unique=False)

    op.create_table(
        "dose_logs",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("schedule_id", sa.Integer(), sa.ForeignKey("drug_schedules.id", ondelete="CASCADE"), nullable=False),
        sa.Column("taken_at", sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.Column("taken", sa.Boolean(), nullable=False, server_default=sa.sql.expression.true()),
        sa.Column("notes", sa.String(), nullable=True),
        sa.Column("recorded_at", sa.DateTime(), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_dose_logs_id", "dose_logs", ["id"], unique=False)

    op.create_table(
        "provenance",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("entity_type", sa.String(), nullable=False),
        sa.Column("entity_id", sa.Integer(), nullable=True),
        sa.Column("source", sa.String(), nullable=False),
        sa.Column("fetched_at", sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.Column("verified_by", sa.Integer(), sa.ForeignKey("users.id", ondelete="SET NULL"), nullable=True),
        sa.Column("notes", sa.Text(), nullable=True),
    )
    op.create_index("ix_provenance_id", "provenance", ["id"], unique=False)


def downgrade() -> None:
    op.drop_index("ix_provenance_id", table_name="provenance")
    op.drop_table("provenance")
    op.drop_index("ix_dose_logs_id", table_name="dose_logs")
    op.drop_table("dose_logs")
    op.drop_index("ix_drug_schedules_id", table_name="drug_schedules")
    op.drop_table("drug_schedules")
    op.drop_index("ix_drugs_local_kuwait_id", table_name="drugs_local_kuwait")
    op.drop_table("drugs_local_kuwait")
    op.drop_index("ix_drugs_master_rx_cui", table_name="drugs_master")
    op.drop_index("ix_drugs_master_id", table_name="drugs_master")
    op.drop_table("drugs_master")
    op.drop_index("ix_patients_id", table_name="patients")
    op.drop_table("patients")
    op.drop_index("ix_users_phone_number", table_name="users")
    op.drop_index("ix_users_email", table_name="users")
    op.drop_index("ix_users_id", table_name="users")
    op.drop_table("users")
