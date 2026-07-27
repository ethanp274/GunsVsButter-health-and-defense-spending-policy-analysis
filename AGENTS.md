# Agent Guidance

This file applies to the entire repository.

## Start here

Before changing the project:

1. Read `README.md`.
2. Read `raw_data/data_dictionary.md`.
3. Inspect `git status --short` and preserve unrelated user changes.
4. Read the complete script or document you intend to edit.
5. Treat `results/results_summary.md` as generated output, not a hand-edited
   source.

The local dissertation proposal,
`MGHL DISSERTATION PROPOSAL DEFENCEHEALTH.docx`, is historical context. It may
be outdated in its methods, data sources, sample, and research questions. Do
not use it to override the current code, README, data dictionary, or explicit
user instructions.

## Source-of-truth order

When sources disagree, use this order:

1. The user's latest explicit instruction.
2. Current analysis and processing code.
3. `README.md` and `raw_data/data_dictionary.md`.
4. Current machine-readable outputs under `results/`.
5. Meeting notes under `notes/`.
6. The historical dissertation proposal.
7. Files under `deprecated/`.

Generated outputs can be stale until the master pipeline is rerun. Validate
the code before relying on an old estimate.

## Project invariants

Preserve these decisions unless the user explicitly changes them:

- The processed panel covers 31 countries and 2000-2024.
- Raw missing observations remain `NA`; do not impute or interpolate.
- Health and defence spending are shares of GDP, stored as proportions.
- Health spending as a share of total government spending is not used.
- The main analysis excludes Iceland and Luxembourg.
- All analyses and plots exclude 2020 and 2021.
- The main model also lacks 2022 because previous-year debt would come from
  excluded 2021.
- The main outcome is relative annual health-spending change.
- The main exposure is relative annual defence-spending change.
- Beveridge (`BEV`) is the reference health-system type.
- The headline model contains categorical year effects and a country random
  intercept.
- Previous-year public debt is the main debt moderator, centred and scaled per
  10 percentage points of GDP.
- For every lagged defence model, debt is measured in the year before the
  health-change outcome, not before the lagged defence exposure.
- Secondary primary models use the within-/between-country decomposition of
  the log2 health-to-defence ratio against outcome levels.
- Change-on-change secondary models are sensitivities.
- UHC is retained in processed data but is excluded from secondary analyses.
- Interpret every model as associational, not causal.

## Lag convention

Use the outcome year as the anchor:

```text
health change at t ~ defence change at t - k + debt at t - 1
```

Example:

- defence change from 2001 to 2002 is labelled 2002;
- health change from 2002 to 2003 is labelled 2003;
- the one-year lag model uses debt from 2002.

Do not shift the debt moderator back to the year before the defence exposure
without an explicit methodological decision from the user.

## Pipeline map

- `code/00_run_pipeline.R`: runs the full pipeline.
- `code/01_data_processing.R`: reads the seven raw CSVs and creates the clean
  panel.
- `code/02_analysis.R`: fits the five main models and primary secondary models.
- `code/03_sensitivity_analyses.R`: fits main and secondary robustness checks.
- `code/04_visualisation.R`: generates descriptive figures.
- `code/05_results_summary.R`: regenerates the Markdown results report.
- `raw_data/data_dictionary.md`: authoritative data inventory and units.
- `processed_data/primary_analysis.csv`: generated analysis dataset.
- `results/results_summary.md`: generated human-readable results.

`raw_data/sources/` contains provenance workbooks. `deprecated/` contains
superseded inputs and analyses. Neither directory should be substituted for
the current CSV inputs without explicit instruction.

## Coding conventions

- Keep R code maximally simple and readable for junior analysts.
- Prefer explicit intermediate objects over dense metaprogramming.
- Use concise comments to explain each major step and non-obvious modelling
  decision.
- Preserve the staged model sequence and common-sample comparisons unless the
  analysis plan changes.
- Use clear variable names that encode scale and timing, such as
  `previous_debt_10pp_c`.
- Centre continuous moderators before interactions.
- Keep categorical year effects as factors.
- Do not suppress singularity or convergence diagnostics.
- Treat the country-clustered GEE as a population-average sensitivity, not as
  a substitute for the prespecified headline mixed model.
- Do not manually type estimates into the report generator.
- Do not edit raw CSVs or source workbooks unless the user explicitly requests
  a data correction.
- Preserve user changes in a dirty worktree and avoid destructive Git
  operations.

## Verification

For any material pipeline change, run:

```powershell
Rscript code/00_run_pipeline.R
```

Then check:

- every stage exits successfully;
- the processed data still contain 31 countries, 775 rows, and years
  2000-2024;
- the main model uses the intended countries, years, timing, and complete-case
  sample;
- 2020 and 2021 do not appear as fitted year effects;
- previous-year debt is correctly aligned within country;
- lagged defence models use debt at `t - 1` relative to health change at `t`;
- no UHC secondary model or result has reappeared;
- transformations contain no infinite values;
- convergence and singularity status remain visible;
- `results/results_summary.md` contains current equations, samples, year
  effects, lag sensitivities, and figures;
- `git diff --check` reports no whitespace errors.

Do not hard-code a new expected sample count until it has been derived from the
current data and checked against the intended exclusions.

## Useful agent skills

When available:

- Use `methods-rigor-check` for material changes to questions, estimands,
  temporal alignment, confounder handling, or model structure.
- Use the document-reading skill when the dissertation proposal or another
  `.docx` must be inspected. Treat proposal claims as historical until checked
  against current code.
- Use spreadsheet tooling for workbook inspection or structured CSV/XLSX
  artifact work, while keeping the CSV inputs and data dictionary synchronized.
- Use local R execution for analysis verification rather than reasoning from
  code alone.

If a requested capability is unavailable, explain the limitation briefly and
continue with the safest local alternative.
