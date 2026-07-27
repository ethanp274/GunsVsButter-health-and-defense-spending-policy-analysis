# Data Dictionary

Project: Harry Rourke's MGHL thesis

Prepared by: Ethan Phillips

Last updated: 27 July 2026

## Purpose

This folder contains the raw country-level source files used to study health and
defence spending. The processing script combines them into a 31-country panel
covering 2000-2024.

The CSV files are inputs to `code/01_data_processing.R`. Original source
workbooks and intermediate downloads are retained in `raw_data/sources/` for
provenance, but the processing script does not read them directly.

## File Inventory

| File | Shape | Years | Contents and source |
| --- | ---: | --- | --- |
| `IMF_debt_pct_gdp.csv` | 384 rows x 78 columns | 1950-2024 | IMF general government debt as a share of GDP. Metadata: `country`, `code`, `variable`. The file includes countries and aggregate geographies. |
| `OECD_mortality_per100k.csv` | 128 rows x 28 columns | 2000-2023 | OECD avoidable, preventable, and treatable mortality, measured as deaths per 100,000 inhabitants. Metadata: `country`, `code`, `variable`, `units`. |
| `SIPRI_defence_pct_gdp.csv` | 192 rows x 79 columns | 1949-2025 | SIPRI military expenditure as a share of GDP. Metadata: `country`, `code`. Rows without a three-letter country code are regional headings or aggregates. |
| `WHO_health_spend_and_outcomes.csv` | 279 rows x 40 columns | 1990-2025 | Nine health spending and outcome indicators for the 31 study countries. Metadata: `variable`, `var-code`, `country`, `code`. The indicators use World Bank codes and draw on WHO, World Bank, and related international sources. |
| `WorldBank_gdp.csv` | 266 rows x 70 columns | 1960-2025 | World Bank GDP in current US dollars. Metadata: `country`, `code`, `variable`, `variable-code`. The file includes countries and aggregate geographies; 2025 contains no observed values. |
| `WorldBank_gdp_per_capita.csv` | 266 rows x 69 columns | 1960-2024 | World Bank GDP per capita in current US dollars. Metadata: `country`, `code`, `variable`, `var-code`. The file includes countries and aggregate geographies. |
| `oecd_europe_health_systems.csv` | 31 rows x 3 columns | Not applicable | Authoritative study-country list and health-system classification. Columns: `country`, `code`, `system`. |

## Standard Conventions

- Year columns use four-digit names and the raw files are stored in wide format.
- `WHO_health_spend_and_outcomes.csv` and
  `OECD_mortality_per100k.csv` contain one row per country-indicator
  combination. The other time-series files contain one row per geography.
- Country matching uses trimmed three-letter codes. Country names in the clean
  dataset come from `oecd_europe_health_systems.csv`.
- Blank cells, `NA`, `xxx`, `...`, `..`, and `. .` are treated as missing.
- Missing observations remain missing. The pipeline does not impute or
  interpolate values.
- Health spending, defence spending, out-of-pocket spending, and government
  debt shares are stored as proportions. For example, `0.05` means 5%.
- The premature non-communicable disease mortality indicator is stored in
  percentage points. For example, `15` means 15%.
- GDP and GDP per capita are in current US dollars and are not adjusted for
  inflation.

## Study Countries and Health Systems

The processed panel is limited to the 31 countries in
`oecd_europe_health_systems.csv`.

- `BEV`: Beveridge-style health system.
- `BIS`: Bismarck-style health system.

The country list supplies the canonical `country`, `code`, and `system` fields
used in the processed dataset.

## WHO Health Indicator Mapping

| Raw `variable` | Clean column | Unit / treatment |
| --- | --- | --- |
| Domestic general government health expenditure (% of GDP) | `health_pct_gdp` | Proportion of GDP |
| Domestic general government health expenditure (% of general government expenditure) | Excluded | Superseded by the GDP-share measure |
| Hospital beds (per 1,000 people) | `hosp_beds_per_thou` | Beds per 1,000 people |
| Life expectancy at birth, total (years) | `life_exp` | Years |
| Physicians (per 1,000 people) | `mds_per_thou` | Physicians per 1,000 people |
| Nurses and midwives (per 1,000 people) | `nurses_per_thou` | Nurses and midwives per 1,000 people |
| Out-of-pocket expenditure (% of current health expenditure) | `oop_pct` | Proportion of current health expenditure |
| UHC service coverage index | `uhc_idx` | Index from 0 to 100 |
| Mortality from CVD, cancer, diabetes or CRD between exact ages 30 and 70 (%) | `premature_ncd_mortality_pct` | Percentage probability |

## OECD Mortality Indicator Mapping

| Raw `variable` | Clean column | Unit |
| --- | --- | --- |
| Avoidable mortality | `avoidable_mortality_per_100k` | Deaths per 100,000 inhabitants |
| Preventable mortality | `preventable_mortality_per_100k` | Deaths per 100,000 inhabitants |
| Treatable mortality | `treatable_mortality_per_100k` | Deaths per 100,000 inhabitants |

## Other Clean Variables

| Source | Clean column | Unit |
| --- | --- | --- |
| SIPRI defence spending | `defence_pct_gdp` | Proportion of GDP |
| IMF general government debt | `government_debt_pct_gdp` | Proportion of GDP |
| World Bank GDP | `gdp_current_usd` | Current US dollars |
| World Bank GDP per capita | `gdp_percap` | Current US dollars per person |

The processing script also calculates:

- `change_def_gdp`: relative year-on-year change in `defence_pct_gdp`.
- `change_health_gdp`: relative year-on-year change in `health_pct_gdp`.
- `change_debt_gdp`: relative year-on-year change in
  `government_debt_pct_gdp`.
- `health_def_ratio`: health spending as a share of GDP divided by defence
  spending as a share of GDP.

Changes are missing when either the current value or previous year's value is
missing, or when the previous value is not positive. The ratio is missing when
health or defence spending is missing or defence spending is not positive.

## Coverage Limitations

- The clean panel covers 2000-2024 even when a source has earlier or later
  years.
- Health spending as a share of GDP is broadly complete through 2023 but is
  available for only 3 of the 31 study countries in 2024.
- The OECD mortality file does not include Cyprus or Malta. Their OECD
  mortality fields therefore remain missing.
- Individual health outcomes have different reporting years and may contain
  gaps within the panel.

## Source Workbooks

The `raw_data/sources/` directory currently contains:

- `28062026 Health Spend and Outcomes.xlsx`
- `DATA Gov Debt IMF.xls`
- `DEFENCE GDP SIPRI DATA.xlsx`
- `OECD Avoidable mortality.xlsx`
- `Pre-2000 Health spend.xlsx`
- `World bank health spend and outcomes.xlsx`
