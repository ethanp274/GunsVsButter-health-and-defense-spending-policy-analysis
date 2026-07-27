# Data Dictionary

Project: Harry Rourke's MGHL thesis

Prepared by: Ethan Phillips

Date: 9 July 2026

## Purpose

This folder contains the raw country-level source files used in the project. Most files are wide country-year panels with one row per geography and one column per year. `health_spend_and_outcomes_by_year.csv` is a stacked panel with one row per country-indicator combination.

## File Inventory

| File | Shape | Contents | Source / notes |
| --- | --- | --- | --- |
| `annual_gdp.csv` | 266 rows x 70 cols | GDP in current US$ | World Bank/OECD national accounts data. Metadata columns: `country`, `code`, `var`, `var-code`; year columns run from 1960 to 2025. |
| `defence_spending_pct_gov_spending.csv` | 194 rows x 40 cols | Military expenditure as a share of general government spending | SIPRI Military Expenditure Database; wide format with `country`, `code`, and year columns from 1988 to 2025. |
| `gdp_per_capita.csv` | 266 rows x 70 cols | GDP per capita in current US$ | World Bank/OECD national accounts data. Metadata columns: `country`, `code`, `indicator`, `var_code`; year columns run from 1960 to 2025. |
| `health_spend_and_outcomes_by_year.csv` | 222 rows x 29 cols | Health expenditure and outcome indicators by country/year | World Bank Health, Nutrition and Population Statistics. The file contains 3 metadata rows plus 217 usable country-indicator rows covering 31 countries x 7 indicators. The `variable` column identifies the indicator; year columns run from 1999 to 2024. |
| `oecd_europe_health_systems.csv` | 31 rows x 3 cols | Country list, health system type, and regional cluster | OECD European country list plus published typologies. Columns: `country`, `code`, `system`. |

## Standard Conventions

- Country-level tables use one row per country or country group, except `health_spend_and_outcomes_by_year.csv`, which is stacked by indicator.
- Year columns are named with four-digit years in ascending order.
- Identifier columns vary by source, but commonly include `country`, `code`, `var`, `var-code`, `indicator`, and `variable`.
- Missing values are blank in most files.
- In the SIPRI files, `xxx` and `...` also mean missing data.
- In the World Bank health file, `..` also means missing data.

## Health Indicator Notes

- `health_pct_gge`: health expenditure as a share of general government expenditure.
- `hosp_beds_per_thou`: hospital beds per 1,000 people.
- `life_exp`: life expectancy at birth.
- `mds_per_thou`: medical doctors per 1,000 people.
- `nurses_per_thou`: nurses and midwives per 1,000 people.
- `oop_pct`: out-of-pocket health expenditure as a share of current health expenditure.
- `uhc_idx`: universal health coverage service coverage index.
- The metadata rows at the top of the file should be ignored in analysis.

## Processing Note

The analysis script reshapes the year columns from wide to long format and standardizes missing-value markers before analysis.
