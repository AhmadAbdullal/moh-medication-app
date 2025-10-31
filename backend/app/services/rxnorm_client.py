"""Client for interacting with the public RxNorm REST API."""

from __future__ import annotations

import json
import logging
from datetime import datetime
from operator import attrgetter
from typing import Any, Dict, Iterable, Optional

import httpx
from cachetools import TTLCache, cachedmethod

from app.models.drug import DrugMaster
from app.models.provenance import Provenance

LOGGER = logging.getLogger(__name__)


class RxNormClient:
    """Thin wrapper around the RxNorm REST API with response normalization helpers."""

    def __init__(
        self,
        base_url: str = "https://rxnav.nlm.nih.gov/REST",
        timeout: float = 10.0,
        cache_ttl_seconds: int = 3600,
    ) -> None:
        self.base_url = base_url.rstrip("/")
        self._client = httpx.Client(
            base_url=self.base_url,
            timeout=timeout,
            headers={"User-Agent": "moh-medication-app/1.0"},
        )
        self._cache: TTLCache = TTLCache(maxsize=512, ttl=cache_ttl_seconds)

    def close(self) -> None:
        self._client.close()

    def __enter__(self) -> "RxNormClient":
        return self

    def __exit__(self, exc_type, exc, tb) -> None:  # type: ignore[override]
        self.close()

    def _get(self, path: str, params: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        response = self._client.get(path, params=params)
        response.raise_for_status()
        return response.json()

    @cachedmethod(attrgetter("_cache"))
    def find_rxcui_by_string(self, drug_name: str) -> Dict[str, Any]:
        return self._get("/rxcui", params={"name": drug_name})

    @cachedmethod(attrgetter("_cache"))
    def get_drugs(self, drug_name: str) -> Dict[str, Any]:
        return self._get("/drugs", params={"name": drug_name})

    @cachedmethod(attrgetter("_cache"))
    def get_approximate_match(self, term: str, max_entries: int = 20) -> Dict[str, Any]:
        return self._get("/approximateTerm", params={"term": term, "maxEntries": max_entries})

    @cachedmethod(attrgetter("_cache"))
    def get_rx_concept_properties(self, rxcui: str) -> Dict[str, Any]:
        return self._get(f"/rxcui/{rxcui}/properties")

    @cachedmethod(attrgetter("_cache"))
    def get_all_related_info(self, rxcui: str) -> Dict[str, Any]:
        return self._get(f"/rxcui/{rxcui}/allrelated")

    @cachedmethod(attrgetter("_cache"))
    def get_ndcs(self, rxcui: str) -> Dict[str, Any]:
        return self._get(f"/rxcui/{rxcui}/ndcs")

    @cachedmethod(attrgetter("_cache"))
    def get_ndc_properties(self, ndc: str) -> Dict[str, Any]:
        return self._get("/ndcproperties", params={"id": ndc})

    @cachedmethod(attrgetter("_cache"))
    def get_spelling_suggestions(self, name: str) -> Dict[str, Any]:
        return self._get("/spellingsuggestions", params={"name": name})

    @cachedmethod(attrgetter("_cache"))
    def get_rxnorm_version(self) -> Dict[str, Any]:
        return self._get("/version")

    @cachedmethod(attrgetter("_cache"))
    def find_rxcui_by_id(self, idtype: str, identifier: str) -> Dict[str, Any]:
        return self._get("/rxcui", params={"idtype": idtype, "id": identifier})

    @cachedmethod(attrgetter("_cache"))
    def get_all_properties(self, rxcui: str) -> Dict[str, Any]:
        return self._get(f"/rxcui/{rxcui}/allProperties")

    @cachedmethod(attrgetter("_cache"))
    def get_related_by_type(self, rxcui: str, tty: str) -> Dict[str, Any]:
        return self._get(f"/rxcui/{rxcui}/related", params={"tty": tty})

    # Normalization helpers -------------------------------------------------

    def normalize_properties_to_drug(self, properties: Dict[str, Any]) -> DrugMaster:
        props = properties.get("properties", {}) if properties else {}
        trade_name_en = props.get("name")
        generic_name = props.get("synonym") or props.get("tty")
        dosage_form = props.get("tty")
        strength = props.get("strength") or props.get("fullName")
        rx_cui = props.get("rxcui")
        drug = DrugMaster(
            rx_cui=rx_cui,
            trade_name_en=trade_name_en,
            trade_name_ar=None,
            generic_name=generic_name,
            strength=strength,
            dosage_form=dosage_form,
            source="rxnorm",
            source_url=f"{self.base_url}/rxcui/{rx_cui}" if rx_cui else None,
            source_version=self._extract_version_string(),
            verified_status="unverified",
        )
        return drug

    def create_provenance(self, entity_type: str, payload: Dict[str, Any]) -> Provenance:
        notes = json.dumps(payload, ensure_ascii=False)
        return Provenance(
            entity_type=entity_type,
            entity_id=None,
            source="rxnorm",
            fetched_at=datetime.utcnow(),
            notes=notes,
        )

    def _extract_version_string(self) -> Optional[str]:
        try:
            version = self.get_rxnorm_version()
            return version.get("version", {}).get("rxnormVersion")
        except httpx.HTTPError as exc:  # pragma: no cover - network failure guard
            LOGGER.warning("Unable to fetch RxNorm version: %s", exc)
        return None

    @staticmethod
    def extract_first_rxcui(result: Dict[str, Any]) -> Optional[str]:
        id_group = result.get("idGroup", {}) if result else {}
        ids: Iterable[str] = id_group.get("rxnormId", [])
        for identifier in ids:
            if identifier:
                return identifier
        return None
