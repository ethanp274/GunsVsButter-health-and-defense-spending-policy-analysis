# Health and Defence Spending

This repository builds and analyses a longitudinal country-year dataset on
health spending, defence spending, public debt, economic conditions, health
system characteristics, and health outcomes.

The study is associational. It examines whether changes in defence spending
are associated with changes in health spending, whether that association
differs by health-system type, and whether the level of public debt before a
health-spending decision moderates the association.

## Current research questions

### Primary question

How is the relative annual change in defence spending as a share of GDP
associated with the relative annual change in government health spending as a
share of GDP?

The main analysis also asks whether this association varies by:

- Beveridge (`BEV`) versus Bismarck (`BIS`) health-system type; and
- public debt in the year before the health-spending change outcome.

### Secondary questions

Is the balance between health and defence spending associated with measures of
health-system strength or health outcomes?

The primary secondary exposure is the log2 health-to-defence spending ratio,
decomposed into within-country and between-country components. Outcome levels
are used in the primary secondary models because most outcomes change slowly
or are observed intermittently. Change-on-change models are retained as
exploratory sensitivities.

## Current study design

The processing stage constructs a balanced framework of 30 countries and 26
years (2000-2025), with unavailable source observations retained as `NA`.
The primary analysis and standard descriptive outputs exclude 2020 and 2021;
an explicit main-model sensitivity includes them.
Source observations from 1999 are read only to calculate the first retained
year's changes and previous-year debt; 1999 is not included as an output row.
There is no imputation or interpolation.

The primary analysis:

- includes all countries in the authoritative study-country source, including
  Luxembourg; Iceland is absent from that source;
- excludes 2020 and 2021 from the primary analysis because of the exceptional
  effects of COVID-19 on spending, GDP, debt, and health measures; the years
  remain in the processed panel for the explicit main-model sensitivity;
- omits 2022 from the main model because its required previous-year debt value
  is from excluded 2021;
- otherwise uses available outcome years from 2000 through 2025 subject to
  complete-case requirements;
- uses Beveridge systems as the reference group;
- includes categorical year effects and a country random intercept;
- adjusts for centred log2 GDP per capita; and
- uses previous-year public debt, centred and scaled per 10 percentage points
  of GDP, as a moderator of defence-spending change.

The headline model is the fully adjusted mixed model:

```text
health spending change ~
  defence spending change * system type +
  defence spending change * previous-year debt level +
  log2 GDP per capita +
  categorical year effects +
  country random intercept
```

Relative health-spending change is expressed as a percentage change. Defence
change is scaled so its coefficient represents a 10% relative increase.

The main model sequence is five staged specifications: pooled, country
random-intercept, health-system moderation, debt moderation, and the fully
adjusted model above. The GEE is retained as a robustness check rather than a
headline main-model specification. Country fixed-effects models and GLS/AR(1)
specifications remain sensitivity analyses. A separate one-off optimizer and
convergence check was also run to confirm that the observed mixed-model
singularity was not an artefact of default `lme4` settings or a poorly chosen
optimisation path; it is not incorporated into the standard pipeline.

## Temporal alignment

In the contemporaneous main model, health-spending change, defence-spending
change, and GDP per capita are measured for outcome year `t`. Public debt is
measured in `t - 1`.

The 2000 change variables are calculated using source values from 1999 to
2000. The processed output still begins at 2000, and the previous-year debt
column allows the 2000 outcome to use debt from 1999 without retaining a 1999
panel row.

In lagged defence sensitivities, debt remains aligned to the health-spending
decision:

```text
health change at t ~ defence change at t - k + debt at t - 1
```

For example, if defence spending changes from 2001 to 2002 and health spending
changes from 2002 to 2003, the one-year lag model uses debt from 2002.

The sensitivity script tests one-, two-, and three-year defence lags. It also
tests exclusion of Greece, inclusion of COVID years 2020 and 2021 with the
corresponding 2022 debt alignment, NATO-only and OECD-only samples, alternative
debt specifications, country and residual structures, absolute changes,
cumulative changes, historical NATO membership, and influential observations.
A separate one-off optimizer-sensitivity analysis was used to check a range of
`lme4` optimizer choices, starting values, and convergence tolerances for
model-rigour purposes; this check is not part of the routine analysis
pipeline.

## Secondary outcomes

The current secondary analyses are restricted to:

- household out-of-pocket payments as a share of current health expenditure;
- nurses and midwives;
- physicians;
- hospital beds;
- treatable mortality.

The primary secondary models use within- and between-country components of the
log2 health-to-defence spending ratio, system type, log2 GDP per capita,
categorical year effects, and a country random intercept. Sensitivities examine
lagged ratios, annual ratio and outcome changes, alternative outcome scales,
lagged debt adjustment, and health and defence shares as separate exposures.

## Data

The authoritative data inventory, units, mappings, and limitations are in
[the raw-data dictionary](raw_data/data_dictionary.md).

The current source inputs are:

- `raw_data/SIPRI_defence_pct_gdp.csv`
- `raw_data/OECD_health_spending_pct_gdp.csv`
- `raw_data/WHO_missing_health_spending_pct_gdp.csv`
- `raw_data/OECD_gdp_per_cap_updated.csv`
- `raw_data/IMF_debt_pct_gdp.csv`
- `raw_data/OECD_beds_per_k.csv`
- `raw_data/20260731-WHO BEDS .csv`
- `raw_data/OECD_mds_per_k.csv`
- `raw_data/OECD_rns_per_k.csv`
- `raw_data/OECD_oop_pct_health_spend.csv`
- `raw_data/OECD_treat_mortality_per_100k.csv`
- `raw_data/oecd_europe_health_systems.csv`

GDP-share and percentage-share variables are stored as proportions: `0.05`
means 5%. This keeps the processed data on one consistent scale; the analysis
scripts rescale terms when reporting percentage-point or per-10-percentage-point
interpretations. Numeric output columns are rounded to no more than five
decimal places. GDP per capita is PPP-converted OECD US dollars per person at
current prices. Missing values remain missing.

Health spending uses OECD as the primary source. The WHO extract
`raw_data/WHO_missing_health_spending_pct_gdp.csv` is used only to fill
country-years where the OECD series is missing, and it never overwrites an
existing OECD observation. WHO hospital beds are converted from per 10,000 to
per 1,000 people and used only where the corresponding OECD value is missing;
both component values and the selected source are retained in the processed
panel. Consultation and diagnostic-scan extracts are retained only as
provenance and are not read by the current pipeline.

Other source workbooks and Numbers files under `raw_data/sources/` and
`raw_data/updated_sources_040826/` are retained for provenance but are not read
directly. Files under `deprecated/` are not pipeline inputs.

The primary out-of-pocket measure is the household out-of-pocket share of
current health expenditure. The workbook
`raw_data/updated_sources_040826/02082026-OECD OOP.xlsx`, which instead reports
out-of-pocket payments as a share of GDP, is retained as an optional alternative
source. The two measures have different denominators and must not be combined
or used to fill one another's missing observations.

## Data availability and citation

The dataset combines source series published by SIPRI, the OECD, the IMF, and
WHO. Original source organisations and their underlying series should be
cited alongside this repository. The raw extracts and provenance files are
included where available, but third-party licensing and redistribution terms
apply; this repository does not assert a blanket licence over those data.

This pipeline was edited with assistance from GPT-5.6 Luna (OpenAI) and MAI-Code-1.1-Flash (Microsoft).

The repository was last reviewed and the pipeline was last regenerated on
12 August 2026. Original source-download dates are not consistently recorded
in the current provenance files. A repository-level citation record and code
licence should be added before archival or public release.

## Running the pipeline

Run the complete workflow from the repository root:

```powershell
Rscript code/00_run_pipeline.R
```

The master script runs the core analysis workflow in a fresh R session and
stops if a stage fails. At startup, it checks the full package list below and
installs any missing packages from CRAN. The standard workflow includes the
five core stages below and intentionally excludes the one-off optimizer check
used only for model-diagnostics rigour:

1. `code/01_data_processing.R`
2. `code/02_analysis.R`
3. `code/03_sensitivity_analyses.R`
4. `code/04_visualisation.R`
5. `code/05_results_summary.R`

The auxiliary script `code/06_mixed_model_sensitivity.R` is a separate,
non-routine robustness check for optimizer and convergence settings. It is kept
outside the standard pipeline so future runs remain reproducible and
stable.

Required R packages are:

```r
install.packages(c(
  "broom",
  "broom.mixed",
  "commonmark",
  "dplyr",
  "geepack",
  "ggplot2",
  "lme4",
  "nlme",
  "readr",
  "readxl",
  "tidyr"
))
```

## Outputs

The processing stage writes:

- `processed_data/primary_analysis.csv`

The downstream stages write machine-readable model summaries, diagnostics,
sensitivity results, and figures under `results/`.

The generated report also includes a country-level table of primary-analysis
panel years, included complete-case observations, excluded observations, and
the specific included years: `results/main_country_sample_counts.csv`.

It also includes generated Table 1 descriptive statistics by health-system type
and overall: `results/table1_descriptive_statistics.csv`.

The one-off optimizer check produces supplementary files in `results/` for
quality assurance, including the mixed-model optimiser comparisons and fixed
effects under alternative settings, but these are not part of the routine
analysis pipeline.

The main human-readable output is:

- [results/results_summary.md](results/results_summary.md)
- [results/results_summary.html](results/results_summary.html)

They contain the model equations, headline and secondary results, conditional
slopes, categorical year effects, lagged sensitivities, other robustness
checks, interpretation cautions, and figures. Both are regenerated from the
machine-readable outputs; estimates should not be edited manually.

## Important limitations

- The results do not establish a causal fiscal trade-off.
- Reverse causation and residual confounding remain possible.
- Health, defence, and debt shares use GDP-related denominators, so common
  economic shocks can mechanically affect several variables.
- Public debt is persistent and correlated with economic and institutional
  characteristics. Lagging it improves temporal ordering but does not make the
  interaction causal.
- Outcome availability differs across indicators and countries.
- Relative changes can be unstable when the preceding spending share is small.
- Multiple secondary outcomes and lag combinations are exploratory and should
  be interpreted as a pattern of evidence rather than isolated significance
  tests.
