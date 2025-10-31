"""Client for interacting with the openFDA drug API."""

from __future__ import annotations

import json
import logging
from datetime import datetime
from operator import attrgetter
from typing import Any, Dict, Optional

import httpx
from cachetools import TTLCache, cachedmethod

from app.models.provenance import Provenance

LOGGER = logging.getLogger(__name__)


class OpenFDAClient:
    def __init__(
        self,
        base_url: str = "https://api.fda.gov/drug",
        timeout: float = 10.0,
        cache_ttl_seconds: int = 3600,
    ) -> None:
        self.base_url = base_url.rstrip("/")
        self._client = httpx.Client(
            base_url=self.base_url,
            timeout=timeout,
            headers={"User-Agent": "moh-medication-app/1.0"},
        )
        self._cache: TTLCache = TTLCache(maxsize=256, ttl=cache_ttl_seconds)

    def close(self) -> None:
        self._client.close()

    def __enter__(self) -> "OpenFDAClient":
        return self

    def __exit__(self, exc_type, exc, tb) -> None:  # type: ignore[override]
        self.close()

    def _get(self, path: str, params: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        response = self._client.get(path, params=params)
        response.raise_for_status()
        return response.json()

    @cachedmethod(attrgetter("_cache"))
    def get_drug_label(self, drug_name: str, limit: int = 5) -> Dict[str, Any]:
        query = f"brand_name:{drug_name}"
        return self._get("/label.json", params={"search": query, "limit": limit})

    @cachedmethod(attrgetter("_cache"))
    def get_drug_enforcement(self, drug_name: str, limit: int = 5) -> Dict[str, Any]:
        query = f"product_description:{drug_name}"
        return self._get("/enforcement.json", params={"search": query, "limit": limit})

    @cachedmethod(attrgetter("_cache"))
    def get_ndc(self, drug_name: str, limit: int = 5) -> Dict[str, Any]:
        query = f"brand_name:{drug_name}"
        return self._get("/ndc.json", params={"search": query, "limit": limit})

    # Normalization ---------------------------------------------------------

    def create_label_provenance(self, entity_type: str, label_response: Dict[str, Any]) -> Optional[Provenance]:
        results = label_response.get("results") if label_response else None
        if not isinstance(results, list) or not results:
            return None
        payload = results[0]
        notes_payload = {
            "id": payload.get("id"),
            "warnings": payload.get("warnings"),
            "adverse_reactions": payload.get("adverse_reactions"),
            "boxed_warning": payload.get("boxed_warning"),
            "effective_time": payload.get("effective_time"),
        }
        return Provenance(
            entity_type=entity_type,
            entity_id=None,
            source="openfda",
            fetched_at=datetime.utcnow(),
            notes=json.dumps(notes_payload, ensure_ascii=False),
        )

    def create_enforcement_provenance(self, entity_type: str, enforcement_response: Dict[str, Any]) -> Optional[Provenance]:
        results = enforcement_response.get("results") if enforcement_response else None
        if not isinstance(results, list) or not results:
            return None
        payload = results[0]
        notes_payload = {
            "recall_number": payload.get("recall_number"),
            "status": payload.get("status"),
            "distribution_pattern": payload.get("distribution_pattern"),
            "reason_for_recall": payload.get("reason_for_recall"),
            "report_date": payload.get("report_date"),
        }
        return Provenance(
            entity_type=entity_type,
            entity_id=None,
            source="openfda",
            fetched_at=datetime.utcnow(),
            notes=json.dumps(notes_payload, ensure_ascii=False),
        )

    def create_ndc_provenance(self, entity_type: str, ndc_response: Dict[str, Any]) -> Optional[Provenance]:
        results = ndc_response.get("results") if ndc_response else None
        if not isinstance(results, list) or not results:
            return None
        payload = results[0]
        notes_payload = {
            "ndc": payload.get("product_ndc"),
            "generic_name": payload.get("generic_name"),
            "labeler_name": payload.get("labeler_name"),
            "marketing_start_date": payload.get("marketing_start_date"),
            "dosage_form": payload.get("dosage_form"),
        }
        return Provenance(
            entity_type=entity_type,
            entity_id=None,
            source="openfda",
            fetched_at=datetime.utcnow(),
            notes=json.dumps(notes_payload, ensure_ascii=False),
        )

    # Convenience wrappers --------------------------------------------------

    def safe_label_lookup(self, drug_name: str) -> Optional[Provenance]:
        try:
            label = self.get_drug_label(drug_name, limit=1)
            return self.create_label_provenance("drug_master", label)
        except httpx.HTTPError as exc:  # pragma: no cover - network failure guard
            LOGGER.warning("openFDA label lookup failed for %s: %s", drug_name, exc)
        return None

    def safe_enforcement_lookup(self, drug_name: str) -> Optional[Provenance]:
        try:
            enforcement = self.get_drug_enforcement(drug_name, limit=1)
            return self.create_enforcement_provenance("drug_master", enforcement)
        except httpx.HTTPError as exc:  # pragma: no cover - network failure guard
            LOGGER.warning("openFDA enforcement lookup failed for %s: %s", drug_name, exc)
        return None

    def safe_ndc_lookup(self, drug_name: str) -> Optional[Provenance]:
        try:
            ndc = self.get_ndc(drug_name, limit=1)
            return self.create_ndc_provenance("drug_master", ndc)
        except httpx.HTTPError as exc:  # pragma: no cover - network failure guard
            LOGGER.warning("openFDA NDC lookup failed for %s: %s", drug_name, exc)
        return None
