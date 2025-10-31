"""Client for interacting with the DailyMed public API."""

from __future__ import annotations

import json
import logging
from datetime import datetime
from operator import attrgetter
from typing import Any, Dict, Optional

import httpx
from cachetools import TTLCache, cachedmethod

from app.models.drug import DrugMaster
from app.models.provenance import Provenance

LOGGER = logging.getLogger(__name__)


class DailyMedClient:
    def __init__(
        self,
        base_url: str = "https://dailymed.nlm.nih.gov/dailymed/services/v2",
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

    def __enter__(self) -> "DailyMedClient":
        return self

    def __exit__(self, exc_type, exc, tb) -> None:  # type: ignore[override]
        self.close()

    def _get(self, path: str, params: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        response = self._client.get(path, params=params)
        response.raise_for_status()
        return response.json()

    @cachedmethod(attrgetter("_cache"))
    def list_drug_names(self) -> Dict[str, Any]:
        return self._get("/drugnames.json")

    @cachedmethod(attrgetter("_cache"))
    def get_spl_details(self, set_id: str) -> Dict[str, Any]:
        return self._get(f"/spls/{set_id}.json")

    @cachedmethod(attrgetter("_cache"))
    def search_spls(self, drug_name: str) -> Dict[str, Any]:
        return self._get("/spls.json", params={"drug_name": drug_name})

    # Normalization ---------------------------------------------------------

    def normalize_spl_to_drug(self, spl_response: Dict[str, Any]) -> DrugMaster:
        entries = spl_response.get("data") if spl_response else None
        entry: Dict[str, Any] = entries[0] if isinstance(entries, list) and entries else {}
        set_id = entry.get("setid")
        strength = entry.get("strength") or entry.get("active_ingredient_strength")
        drug = DrugMaster(
            rx_cui=None,
            trade_name_en=entry.get("title"),
            trade_name_ar=None,
            generic_name=entry.get("generic_name"),
            strength=strength,
            dosage_form=entry.get("dosage_form"),
            source="dailymed",
            source_url=f"{self.base_url}/spls/{set_id}.json" if set_id else None,
            source_version=str(entry.get("version")) if entry.get("version") else None,
            verified_status="unverified",
        )
        return drug

    def create_provenance(self, entity_type: str, spl_response: Dict[str, Any]) -> Provenance:
        entries = spl_response.get("data") if spl_response else None
        entry: Dict[str, Any] = entries[0] if isinstance(entries, list) and entries else {}
        set_id = entry.get("setid")
        notes_payload = {
            "indications_and_usage": entry.get("indications_and_usage"),
            "dosage_and_administration": entry.get("dosage_and_administration"),
            "warnings": entry.get("warnings"),
            "last_updated": entry.get("effective_time"),
            "source_url": f"{self.base_url}/spls/{set_id}.json" if set_id else None,
        }
        return Provenance(
            entity_type=entity_type,
            entity_id=None,
            source="dailymed",
            fetched_at=datetime.utcnow(),
            notes=json.dumps(notes_payload, ensure_ascii=False),
        )

    def safe_get_spl(self, drug_name: str) -> Optional[Dict[str, Any]]:
        try:
            search = self.search_spls(drug_name)
            entries = search.get("data") if search else None
            set_id = None
            if isinstance(entries, list) and entries:
                set_id = entries[0].get("setid")
            if not set_id:
                return None
            return self.get_spl_details(set_id)
        except httpx.HTTPError as exc:  # pragma: no cover - network failure guard
            LOGGER.warning("DailyMed lookup failed for %s: %s", drug_name, exc)
        return None
