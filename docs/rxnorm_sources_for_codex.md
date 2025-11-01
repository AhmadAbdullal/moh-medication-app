# RxNorm & External Drug Data Sources

The backend integrates with the following public endpoints:

- **RxNorm (https://rxnav.nlm.nih.gov/REST)**
  - `/rxcui?name={drug_name}`
  - `/drugs?name={drug_name}`
  - `/approximateTerm?term={text}&maxEntries={n}`
  - `/rxcui/{rxcui}/properties`
  - `/rxcui/{rxcui}/allrelated`
  - `/rxcui/{rxcui}/ndcs`
  - `/ndcproperties?id={ndc}`
  - `/spellingsuggestions?name={text}`
  - `/version`
  - `/rxcui?idtype={idtype}&id={id}`
  - `/rxcui/{rxcui}/allProperties`
  - `/rxcui/{rxcui}/related?tty={tty}`

- **DailyMed (https://dailymed.nlm.nih.gov/dailymed/services/v2)** *(planned integration – connector not yet active)*
  - Target endpoints under review for phase two of the ingestion pipeline include:
    - `/drugnames.json`
    - `/spls/{setid}.json`
    - `/spls.json?drug_name={name}`
  - These endpoints will be activated once RxNorm ingestion is stable and DailyMed reconciliation rules are finalized.

- **openFDA (https://api.fda.gov/drug)** *(planned integration – connector not yet active)*
  - The future roadmap includes ingesting and linking the following resources:
    - `/label.json?search=brand_name:{drug_name}`
    - `/enforcement.json?search=product_description:{drug_name}`
    - `/ndc.json?search=brand_name:{drug_name}`
  - Activation is pending completion of the DailyMed workstream so that FDA labeling data can be cross-referenced with RxNorm identifiers.
