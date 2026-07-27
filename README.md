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

UHC service coverage remains available in the processed dataset but is
deliberately excluded from all secondary analyses.

## Current study design

The processing stage constructs a balanced framework of 31 countries and 25
years (2000-2024), with unavailable source observations retained as `NA`.
There is no imputation or interpolation.

The primary analysis:

- excludes Iceland and Luxembourg;
- excludes observations from 2020 and 2021 because of the exceptional effects
  of COVID-19 on spending, GDP, debt, and health measures;
- omits 2022 from the main model because its required previous-year debt value
  is from excluded 2021;
- uses Beveridge systems as the reference group;
- includes categorical year effects and a country random intercept;
- adjusts for centred log2 GDP per capita; and
- uses previous-year public debt, centred and scaled per 10 percentage points
  of GDP, as a moderator of defence-spending change.

The fully adjusted model is:

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

The fitted country random-intercept variance is currently effectively zero,
so the headline mixed model is singular. This is reported transparently.
Country fixed-effects, generalized least-squares AR(1), and population-average
GEE models are included as sensitivities.

## Temporal alignment

In the contemporaneous main model, health-spending change, defence-spending
change, and GDP per capita are measured for outcome year `t`. Public debt is
measured in `t - 1`.

In lagged defence sensitivities, debt remains aligned to the health-spending
decision:

```text
health change at t ~ defence change at t - k + debt at t - 1
```

For example, if defence spending changes from 2001 to 2002 and health spending
changes from 2002 to 2003, the one-year lag model uses debt from 2002.

The sensitivity script tests one-, two-, and three-year defence lags. It also
tests alternative samples, debt specifications, country and residual
structures, absolute changes, cumulative changes, NATO membership definitions,
and influential observations.

## Secondary outcomes

The current secondary analyses cover:

- out-of-pocket health expenditure;
- life expectancy;
- hospital beds;
- physicians;
- nurses and midwives;
- premature non-communicable disease mortality;
- avoidable mortality;
- preventable mortality; and
- treatable mortality.

The primary secondary models use within- and between-country components of the
log2 health-to-defence spending ratio, system type, log2 GDP per capita,
categorical year effects, and a country random intercept. Sensitivities examine
lagged ratios, annual ratio and outcome changes, alternative outcome scales,
lagged debt adjustment, and health and defence shares as separate exposures.

## Data

The authoritative data inventory, units, mappings, and limitations are in
[the raw-data dictionary](raw_data/data_dictionary.md).

The seven current CSV inputs are:

- `raw_data/SIPRI_defence_pct_gdp.csv`
- `raw_data/WHO_health_spend_and_outcomes.csv`
- `raw_data/WorldBank_gdp.csv`
- `raw_data/WorldBank_gdp_per_capita.csv`
- `raw_data/IMF_debt_pct_gdp.csv`
- `raw_data/OECD_mortality_per100k.csv`
- `raw_data/oecd_europe_health_systems.csv`

GDP-share and percentage-share variables are stored as proportions: `0.05`
means 5%. GDP and GDP per capita are current US dollars. Missing values remain
missing.

Original workbooks are retained under `raw_data/sources/` for provenance.
Files under `deprecated/` are not pipeline inputs.

## Running the pipeline

Run the complete workflow from the repository root:

```powershell
Rscript code/00_run_pipeline.R
```

The master script runs every stage in a fresh R session and stops if a stage
fails:

1. `code/01_data_processing.R`
2. `code/02_analysis.R`
3. `code/03_sensitivity_analyses.R`
4. `code/04_visualisation.R`
5. `code/05_results_summary.R`

Required R packages are:

```r
install.packages(c(
  "broom",
  "broom.mixed",
  "dplyr",
  "geepack",
  "ggplot2",
  "lme4",
  "nlme",
  "readr",
  "tidyr"
))
```

## Outputs

The processing stage writes:

- `processed_data/primary_analysis.csv`

The downstream stages write machine-readable model summaries, diagnostics,
sensitivity results, and figures under `results/`.

The main human-readable output is:

- [results/results_summary.md](results/results_summary.md)

It contains the model equations, headline and secondary results, conditional
slopes, categorical year effects, lagged sensitivities, other robustness
checks, interpretation cautions, and figures. It is regenerated from the
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

## Historical dissertation proposal

The local file
[MGHL DISSERTATION PROPOSAL DEFENCEHEALTH.docx](<MGHL DISSERTATION PROPOSAL DEFENCEHEALTH.docx>)
records the original dissertation proposal and remains useful for the broad
"guns versus butter" motivation and dissertation context.

It is not the current methods specification. In particular, the proposal
described external conflict exposure, UCDP data, a two-way fixed-effects
design, and a different set of research questions. Those elements are not the
implemented headline analysis. The current scripts, this README, the data
dictionary, and the generated results summary supersede the proposal whenever
they differ.

## Repository guidance

Practical instructions for future coding agents are in [AGENTS.md](AGENTS.md).
