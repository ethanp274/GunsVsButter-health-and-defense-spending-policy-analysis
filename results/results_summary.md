# Health and Defence Spending: Results Summary

Generated: 2026-07-27

> These analyses estimate associations and do not establish causation.

## Analysis sample

The main analysis includes **667 observations from 29 countries during 2001-2023**. Iceland and Luxembourg are excluded from the primary sample.

The headline model uses categorical year effects and a country random intercept. Its estimated country variance is **0.000000** and its singular-fit status is **TRUE**.

## Primary analysis

### Model sequence

| Model | Equation | N | Countries | Years | Singular fit |
| --- | --- | --- | --- | --- | --- |
| Pooled unadjusted association | $\Delta H_{it}=\beta_0+\beta_1\Delta D_{it}+\epsilon_{it}$ | 667 | 29 | 2001-2023 |  |
| Country random intercept | $\Delta H_{it}=\beta_0+\beta_1\Delta D_{it}+u_i+\epsilon_{it}$ | 667 | 29 | 2001-2023 | TRUE |
| Country random intercept and health-system moderation | $\Delta H_{it}=\beta_0+\beta_1\Delta D_{it}+\beta_2S_i+\beta_3(\Delta D_{it}\times S_i)+u_i+\epsilon_{it}$ | 667 | 29 | 2001-2023 | TRUE |
| Health-system and public-debt moderation | $\Delta H_{it}=\beta_0+\beta_1\Delta D_{it}+\beta_2S_i+\beta_3(\Delta D_{it}\times S_i)+\beta_4\Delta B_{it}+\beta_5(\Delta D_{it}\times\Delta B_{it})+u_i+\epsilon_{it}$ | 667 | 29 | 2001-2023 | TRUE |
| Fully adjusted with GDP per capita and year effects | $\Delta H_{it}=\beta_0+\beta_1\Delta D_{it}+\beta_2S_i+\beta_3(\Delta D_{it}\times S_i)+\beta_4\Delta B_{it}+\beta_5(\Delta D_{it}\times\Delta B_{it})+\beta_6\log_2(GDPpc_{it})+\gamma_t+u_i+\epsilon_{it}$ | 667 | 29 | 2001-2023 | TRUE |

Here, $\Delta H$ is relative health-spending change, $\Delta D$ is relative defence-spending change, $S$ is health-system type, $\Delta B$ is relative public-debt change, $\gamma_t$ denotes categorical year effects, and $u_i$ is the country random intercept.

### Key headline findings

- In Beveridge countries at average debt change, a 10% relative increase in defence spending was associated with a **1.300 [0.592, 2.009]** percentage-point relative change in health spending.
- The defence-change slope difference for Bismarck systems was **-0.873 [-1.726, -0.020]**.
- The defence-by-debt-change interaction was **0.018 [-0.271, 0.306]**.
- The coefficient for a doubling of GDP per capita was **0.066 [-0.413, 0.544]**.

Estimates are shown as coefficient [95% confidence interval]. Year-dummy coefficients are omitted from the compact table.

| Term | model_1_unadjusted | model_2_country_random_intercept | model_3_system_moderation | model_4_debt_moderation | model_5_fully_adjusted |
| --- | --- | --- | --- | --- | --- |
| Defence change, per 10% relative increase | 1.130 [0.635, 1.625] | 1.130 [0.637, 1.624] | 2.077 [1.238, 2.917] | 1.737 [0.938, 2.535] | 1.300 [0.592, 2.009] |
| Bismarck-style health system |  |  | -0.667 [-1.743, 0.409] | -0.572 [-1.593, 0.450] | -0.605 [-1.545, 0.335] |
| Defence change x Bismarck system |  |  | -1.427 [-2.461, -0.393] | -0.969 [-1.954, 0.016] | -0.873 [-1.726, -0.020] |
| Public-debt change, per 10% relative increase |  |  |  | 1.523 [1.165, 1.881] | 0.478 [0.101, 0.856] |
| Defence change x public-debt change |  |  |  | 0.359 [0.039, 0.679] | 0.018 [-0.271, 0.306] |
| GDP per capita, per doubling |  |  |  |  | 0.066 [-0.413, 0.544] |

### Conditional defence slopes

| System | Debt-change percentile | Debt change (%) | Defence slope [95% CI] |
| --- | --- | --- | --- |
| BEV | 25% | -4.47 | 1.288 [0.558, 2.019] |
| BIS | 25% | -4.47 | 0.415 [-0.113, 0.944] |
| BEV | 50% | -0.44 | 1.296 [0.585, 2.007] |
| BIS | 50% | -0.44 | 0.423 [-0.092, 0.938] |
| BEV | 75% | 4.80 | 1.305 [0.591, 2.019] |
| BIS | 75% | 4.80 | 0.432 [-0.104, 0.969] |

## Secondary analyses

All secondary models use the common form:

$$g(Y_{it})=\beta_0+\beta_W(R_{it}-\bar{R}_i)+\beta_B\bar{R}_i+\beta_SS_i+\beta_G\log_2(GDPpc_{it})+\gamma_t+u_i+\epsilon_{it},$$

where $R$ is the log2 health-to-defence spending ratio. The within-country coefficient is the principal longitudinal association. A one-unit change in log2 ratio represents a doubling of the health-to-defence ratio.

For log-transformed outcomes, effects below are percentage changes per doubling of the ratio. Other outcomes retain the units shown.

| Outcome | Scale | N | Countries | Years | Within-country effect [95% CI] | Between-country effect [95% CI] |
| --- | --- | --- | --- | --- | --- | --- |
| Out-of-pocket expenditure | Percentage points | 696 | 29 | 2000-2023 | -3.559 [-4.425, -2.693] | -7.749 [-11.674, -3.824] |
| Life expectancy at birth | Years | 696 | 29 | 2000-2023 | -0.364 [-0.512, -0.215] | 1.469 [0.349, 2.589] |
| Hospital beds | Beds per 1,000 people | 670 | 29 | 2000-2023 | 0.128 [-0.031, 0.287] | 0.206 [-0.431, 0.844] |
| Medical doctors | Log outcome | 669 | 29 | 2000-2023 | 3.183 [0.494, 5.944] | 8.618 [-1.920, 20.288] |
| Nurses and midwives | Log outcome | 658 | 29 | 2000-2023 | 2.446 [-0.528, 5.509] | 51.167 [28.405, 77.963] |
| UHC service coverage | Index points | 203 | 29 | 2000-2021 | -0.719 [-1.913, 0.475] | 2.144 [0.203, 4.086] |
| Premature NCD mortality | Log outcome | 638 | 29 | 2000-2021 | -2.534 [-3.899, -1.149] | -18.176 [-28.908, -5.825] |
| Avoidable mortality | Log outcome | 579 | 27 | 2000-2023 | 0.715 [-1.153, 2.619] | -26.323 [-38.656, -11.511] |
| Preventable mortality | Log outcome | 579 | 27 | 2000-2023 | 2.715 [0.593, 4.881] | -21.873 [-34.158, -7.297] |
| Treatable mortality | Log outcome | 496 | 23 | 2000-2023 | -4.650 [-6.763, -2.490] | -27.507 [-42.227, -9.036] |

## Notable sensitivity analyses

The focal estimates below correspond to the defence-change term used by each specification.

| Sensitivity | N | Countries | Focal estimate [95% CI] | Singular fit |
| --- | --- | --- | --- | --- |
| One-year lag of defence and debt changes | 638 | 29 | 0.620 [-0.178, 1.418] | TRUE |
| Two-year lag of defence and debt changes | 609 | 29 | 1.190 [0.372, 2.007] | TRUE |
| Three-year lag of defence and debt changes | 580 | 29 | 0.639 [-0.200, 1.479] | TRUE |
| Three-year cumulative health, defence, and debt changes | 609 | 29 | 2.072 [1.228, 2.917] | FALSE |
| Country and year fixed effects | 667 | 29 | 1.446 [0.685, 2.206] |  |
| Generalized least squares with country-specific AR(1) correlation | 667 | 29 | 1.276 [0.550, 2.002] |  |
| Absolute percentage-point changes in GDP shares | 667 | 29 | 0.461 [0.206, 0.716] | TRUE |
| Current NATO members only | 552 | 24 | 1.120 [0.336, 1.903] | TRUE |
| Restore Luxembourg while continuing to exclude Iceland | 690 | 30 | 1.272 [0.568, 1.976] | TRUE |
| Include available observations from 2024 | 669 | 29 | 1.290 [0.584, 1.996] | TRUE |
| Exclude 2020 and 2021 | 609 | 29 | 1.174 [0.513, 1.835] | TRUE |
| Exclude 2008 to 2010 | 580 | 29 | 1.158 [0.384, 1.933] | TRUE |
| Relative changes winsorised at the 1st and 99th percentiles | 667 | 29 | 1.333 [0.680, 1.986] | TRUE |

Across leave-one-country-out analyses, the headline defence coefficient ranged from **0.822 to 1.810**. The full range of lower and upper confidence limits was **0.085 to 2.604**.

### Lagged secondary associations

These are within-country model-scale coefficients [95% confidence interval] for lagged log2 spending ratios.

| Outcome | 1-year lag | 3-year lag | 5-year lag |
| --- | --- | --- | --- |
| Out-of-pocket expenditure | -3.073 [-4.000, -2.147] | -1.691 [-2.703, -0.678] | -1.911 [-3.007, -0.814] |
| Life expectancy at birth | -0.336 [-0.492, -0.179] | -0.294 [-0.465, -0.123] | -0.411 [-0.597, -0.225] |
| Hospital beds | 0.151 [-0.017, 0.320] | 0.235 [0.054, 0.416] | 0.366 [0.179, 0.553] |
| Medical doctors | 0.026 [-0.002, 0.055] | 0.018 [-0.008, 0.045] | -0.010 [-0.039, 0.018] |
| Nurses and midwives | 0.009 [-0.023, 0.040] | -0.010 [-0.043, 0.023] | -0.053 [-0.088, -0.019] |
| UHC service coverage | -0.702 [-1.833, 0.428] | -0.627 [-1.785, 0.532] | -0.382 [-1.477, 0.713] |
| Premature NCD mortality | -0.029 [-0.043, -0.015] | -0.025 [-0.040, -0.010] | -0.015 [-0.031, 0.001] |
| Avoidable mortality | 0.002 [-0.018, 0.021] | 0.001 [-0.019, 0.021] | 0.006 [-0.016, 0.028] |
| Preventable mortality | 0.019 [-0.003, 0.040] | 0.014 [-0.009, 0.038] | 0.016 [-0.010, 0.042] |
| Treatable mortality | -0.049 [-0.071, -0.026] | -0.049 [-0.072, -0.026] | -0.042 [-0.065, -0.020] |

## Descriptive figures

### Health-to-defence spending ratio

![Health-to-defence spending ratio over time](health_def_ratio_timeseries.png)

### Average spending by health-system type

![Average health and defence spending as a share of GDP](system_avg_spending_pct_gdp_timeseries.png)

## Interpretation cautions

- The models are associational and may retain residual confounding or reverse causation.
- Health, defence, and debt measures share GDP-related denominators, so common economic shocks can create coupled movements.
- A singular random-intercept fit indicates that the estimated between-country residual variance is effectively zero after included covariates.
- Secondary analyses are exploratory and span outcomes with different observation schedules and sample sizes.

## Reproducibility

Run the reporting pipeline from the repository root:

```powershell
Rscript code/02_analysis.R
Rscript code/03_sensitivity_analyses.R
Rscript code/04_visualisation.R
Rscript code/05_results_summary.R
```

The report is generated entirely from machine-readable files in `results/`; no estimates are entered manually.
