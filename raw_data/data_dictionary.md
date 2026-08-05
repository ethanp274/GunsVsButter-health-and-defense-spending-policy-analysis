# Data Dictionary

Project: Harry Rourke's MGHL thesis
Prepared by: Ethan Phillips
Last updated: 5 August 2026

## Purpose

The current CSV inputs are combined by `code/01_data_processing.R` into a
31-country panel covering 2000-2025. Source values from 1999 are used only as
the prior-year input for the first retained year's changes and debt. The output
has one row per country-year from 2000 through 2025; source observations that
are unavailable remain `NA`.

The pipeline reads the current CSV files directly. Workbooks and Numbers files
are retained as provenance and are not read directly by the processing script.

## File inventory

| File | Current shape | Layout and contents |
| --- | ---: | --- |
| `IMF_debt_pct_gdp.csv` | 384 x 78 | Wide IMF general government debt as a share of GDP. |
| `OECD_beds_per_k.csv` | 1,225 x 40 | Long OECD hospital beds, per 1,000 people. |
| `OECD_gdp_per_cap.csv` | 1,132 x 44 | Long OECD GDP per capita in PPP-converted US dollars per person at current prices. |
| `OECD_health_spending_pct_gdp.csv` | 1,488 x 46 | Long OECD government/compulsory health spending as a percentage of GDP. |
| `OECD_md_consults_per_person.csv` | 957 x 56 | Long OECD medical-doctor consultations per person. |
| `OECD_mds_per_k.csv` | 1,089 x 40 | Long OECD practicing physicians, per 1,000 people. |
| `OECD_oop_pct_health_spend.csv` | 1,447 x 46 | Long OECD household out-of-pocket expenditure as a percentage of current health expenditure. |
| `OECD_rns_per_k.csv` | 1,046 x 40 | Long OECD practicing nurses, per 1,000 people. |
| `OECD_scans_per_k.csv` | 4,902 x 56 | Long OECD CT, MRI, and PET examinations, per 1,000 people, with multiple provider series. |
| `OECD_treat_mortality_per_100k.csv` | 1,048 x 44 | Long OECD treatable mortality, per 100,000 people. |
| `SIPRI_defence_pct_gdp.csv` | 192 x 79 | Wide SIPRI military expenditure as a share of GDP. |
| `oecd_europe_health_systems.csv` | 31 x 3 | Authoritative study-country list and health-system classification. |

## Standard conventions

- The processed panel is limited to the 31 countries in
  `oecd_europe_health_systems.csv` and years 2000-2025.
- Source years are read from 1999 through 2025 so that 2000 changes can be
  calculated from 1999-2000. The 1999 working row is not retained in the
  processed output.
- Country matching uses trimmed, upper-case three-letter codes. Country names
  and health-system classifications come from the study-country file.
- Blank cells, `NA`, `xxx`, `...`, `..`, and `. .` are treated as missing.
- Missing observations remain missing. The pipeline does not impute or
  interpolate values.
- Health spending, defence spending, out-of-pocket spending, and government
  debt are stored as proportions. For example, `0.05` means 5%.
- GDP per capita is stored in PPP-converted OECD US dollars per person at
  current prices.
- Other outcomes retain their source units.

## Study countries and health systems

- `BEV`: Beveridge-style health system.
- `BIS`: Bismarck-style health system.

The country list supplies the canonical `country`, `code`, and `system` fields
used in the processed dataset.

## Processed-variable mapping

| Source series | Clean column | Unit and treatment |
| --- | --- | --- |
| SIPRI military expenditure as percentage of GDP | `defence_pct_gdp` | Proportion of GDP; source is already stored as a proportion. |
| OECD government/compulsory health expenditure as percentage of GDP | `health_pct_gdp` | Proportion of GDP; source percentage divided by 100. |
| OECD GDP per capita, PPP converted | `gdp_percap` | PPP-converted US dollars per person at current prices. |
| IMF general government debt | `government_debt_pct_gdp` | Proportion of GDP; source is already stored as a proportion. |
| Previous-year IMF general government debt | `previous_government_debt_pct_gdp` | Current year's `t - 1` debt level; 2000 uses the 1999 source value. |
| OECD hospital beds | `hosp_beds_per_thou` | Beds per 1,000 people. |
| OECD practicing physicians | `mds_per_thou` | Physicians per 1,000 people. |
| OECD practicing nurses | `nurses_per_thou` | Nurses per 1,000 people. |
| OECD medical-doctor consultations | `doctor_consults_per_person` | Consultations per person. Descriptive panel variable; not currently modelled. |
| OECD household out-of-pocket expenditure | `oop_pct` | Proportion of current health expenditure; source percentage divided by 100. |
| OECD CT examinations, total provider | `ct_scans_per_thou` | Examinations per 1,000 people. Descriptive panel variable; not currently modelled. |
| OECD MRI examinations, total provider | `mri_scans_per_thou` | Examinations per 1,000 people. Descriptive panel variable; not currently modelled. |
| OECD PET examinations, total provider | `pet_scans_per_thou` | Examinations per 1,000 people. Descriptive panel variable; not currently modelled. |
| OECD treatable mortality | `treatable_mortality_per_100k` | Deaths per 100,000 people. |

Life expectancy, UHC service coverage, premature non-communicable disease
mortality, avoidable mortality, and preventable mortality are not included in
the revised processed dataset or analyses.

## Derived variables

The processing script also calculates:

- `change_def_gdp`: relative year-on-year change in `defence_pct_gdp`.
- `change_health_gdp`: relative year-on-year change in `health_pct_gdp`.
- `change_debt_gdp`: relative year-on-year change in
  `government_debt_pct_gdp`.
- `health_def_ratio`: health spending as a share of GDP divided by defence
  spending as a share of GDP.

The first retained change, for 2000, uses the 1999 source value. Subsequent
changes use the immediately preceding retained year. Changes are missing when
either the current value or previous year's value is missing, or when the
previous value is not positive. The ratio is missing when health or defence
spending is missing or defence spending is not positive.

Previous-year debt used for the main moderation analysis is stored explicitly
as `previous_government_debt_pct_gdp`, so its timing remains explicit relative
to the health-change outcome year.

## Coverage limitations

- The clean panel remains a complete 806-row country-year framework even when
  source indicators are unavailable.
- The 1999 source year is used only for first-year change and debt
  calculations; it is not included as a processed panel year.
- OECD indicator coverage differs across countries and years. GDP per capita,
  beds, nurses, scans, and treatable mortality therefore contain some `NA`
  values in the panel.
- Diagnostic-scan data contain separate CT, MRI, and PET series and multiple
  provider types. The processing script retains the total-provider series.

## Source provenance

Additional source workbooks and Numbers files are retained under
`raw_data/sources/` and `raw_data/updated_sources_040826/`. They document the
source downloads and exports used to create or update the current CSV inputs.
