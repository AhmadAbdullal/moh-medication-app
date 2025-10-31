"""Background job stubs for daily synchronization operations."""

import logging
from typing import List

import httpx
from celery import Celery

from app.core.config import get_settings
from app.db.session import SessionLocal
from app.models.drug import DrugLocalKuwait, DrugMaster
from app.models.provenance import Provenance
from app.services import DailyMedClient, OpenFDAClient, RxNormClient

settings = get_settings()
LOGGER = logging.getLogger(__name__)

celery_app = Celery(
    "moh_medication",
    broker="redis://localhost:6379/0",
    backend="redis://localhost:6379/1",
)
celery_app.conf.update(task_default_queue=f"{settings.app_name.lower().replace(' ', '-')}-daily")


@celery_app.task(name="drugs.sync_external_sources")
def sync_external_sources(limit: int = 25) -> str:
    """Attempt to reconcile unmatched Kuwait drugs against public data sources."""

    synced = 0
    with SessionLocal() as session:
        local_drugs = (
            session.query(DrugLocalKuwait)
            .filter(DrugLocalKuwait.matched_drug_id.is_(None))
            .order_by(DrugLocalKuwait.extracted_at.asc())
            .limit(limit)
            .all()
        )
        if not local_drugs:
            return "No unmatched drugs to sync"

        with RxNormClient() as rx_client, DailyMedClient() as dm_client, OpenFDAClient() as fda_client:
            for local in local_drugs:
                candidate_name = local.trade_name_ar or local.generic_name
                if not candidate_name:
                    continue

                try:
                    lookup = rx_client.find_rxcui_by_string(candidate_name)
                except httpx.HTTPError as exc:  # pragma: no cover - network failure guard
                    LOGGER.warning("RxNorm lookup failed for %s: %s", candidate_name, exc)
                    continue

                rxcui = RxNormClient.extract_first_rxcui(lookup)
                if not rxcui:
                    continue

                try:
                    properties = rx_client.get_rx_concept_properties(rxcui)
                except httpx.HTTPError as exc:  # pragma: no cover - network failure guard
                    LOGGER.warning("RxNorm properties lookup failed for %s: %s", rxcui, exc)
                    continue

                master = rx_client.normalize_properties_to_drug(properties)
                existing = (
                    session.query(DrugMaster)
                    .filter(DrugMaster.rx_cui == master.rx_cui)
                    .first()
                )
                if existing:
                    existing.trade_name_en = existing.trade_name_en or master.trade_name_en
                    existing.generic_name = existing.generic_name or master.generic_name
                    existing.dosage_form = existing.dosage_form or master.dosage_form
                    existing.strength = existing.strength or master.strength
                    master = existing
                else:
                    session.add(master)
                    session.flush()

                local.matched_drug_id = master.id
                provenance_entries: List[Provenance] = [
                    rx_client.create_provenance("drug_master", properties),
                ]

                spl = dm_client.safe_get_spl(master.trade_name_en or candidate_name)
                if spl:
                    provenance_entries.append(dm_client.create_provenance("drug_master", spl))

                for prov in (
                    fda_client.safe_label_lookup(master.trade_name_en or candidate_name),
                    fda_client.safe_enforcement_lookup(master.trade_name_en or candidate_name),
                    fda_client.safe_ndc_lookup(master.trade_name_en or candidate_name),
                ):
                    if prov:
                        provenance_entries.append(prov)

                for provenance in provenance_entries:
                    provenance.entity_id = master.id
                    session.add(provenance)

                synced += 1

        session.commit()

    return f"Synced {synced} drug records"


@celery_app.task(name="drugs.sync_kuwait_catalog")
def sync_kuwait_catalog() -> str:
    """Placeholder task that will eventually synchronize Kuwait drug data."""
    LOGGER.info("Scheduled sync_kuwait_catalog placeholder execution")
    return "sync scheduled"
