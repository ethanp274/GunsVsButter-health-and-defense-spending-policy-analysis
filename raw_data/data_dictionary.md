# Data Dictionary

Project: Harry Rourke's MGHL thesis

Prepared by: Ethan Phillips

Date: 28 June 2026

## Purpose

This folder contains the raw country-level source files used in the project. Most files are in wide format with one row per country and one column per year.

## File Inventory

| File | Contents | Source / notes |
| --- | --- | --- |
| `defence_spending_pct_gdp.csv` | Military expenditure as a share of GDP | SIPRI Military Expenditure Database; 173 countries; 1949-2025. |
| `defence_spending_pct_gov_spending.csv` | Military expenditure as a share of general government spending | SIPRI Military Expenditure Database. |
| `health_spending_pct_gdp.csv` | Domestic general government health expenditure as a share of GDP | WHO Global Health Expenditure Database, accessed via World Bank. |
| `health_spending_pct_gov_spending.csv` | Domestic general government health expenditure as a share of general government spending | WHO Global Health Expenditure Database, accessed via World Bank. |
| `annual_gdp.csv` | GDP in current US dollars | OECD National Accounts data, accessed via World Bank. |
| `gdp_per_capita.csv` | GDP per capita in current US dollars | OECD National Accounts data, accessed via World Bank. |
| `oecd_europe_health_systems.csv` | Country list, health system type, and regional cluster | OECD country list plus published typologies. |

## Standard Conventions

- Country-level tables use one row per country or country group.
- Year columns are named with four-digit years in ascending order.
- Identifier columns vary by source, but usually include country name and country code.
- Missing values are represented by empty cells in most files.
- In the SIPRI defence files, `xxx` and `...` also mean missing data.

## Health System Metadata

- Country list: OECD European region member states.
- Health system type sources:
  - https://doi.org/10.1186/s12913-024-11743-0
  - https://doi.org/10.1016/j.jval.2019.11.001
  - https://pubmed.ncbi.nlm.nih.gov/28900351/
- Regional cluster source:
  - https://doi.org/10.1186/s12913-018-3323-3
- Some regional cluster assignments include limited extrapolation based on geography.

## Processing Note

The analysis script reshapes the year columns from wide to long format and standardizes missing-value markers before analysis.
