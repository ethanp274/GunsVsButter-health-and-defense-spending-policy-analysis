# Health and Defence Spending: Results Summary

Generated: 2026-07-27

> These analyses estimate associations and do not establish causation.

## Analysis sample

The main analysis includes **580 observations from 29 countries during 2001-2023**. Iceland and Luxembourg are excluded, 2020-2021 are excluded, and 2022 is unavailable because its previous-year debt value comes from excluded 2021.

The headline model uses categorical year effects and a country random intercept. Its estimated country variance is **0.000000** and its singular-fit status is **TRUE**.

## Primary analysis

### Model sequence

| Model | Equation | N | Countries | Years | Singular fit |
| --- | --- | --- | --- | --- | --- |
| Pooled unadjusted association | $\Delta H_{it}=\beta_0+\beta_1\Delta D_{it}+\epsilon_{it}$ | 580 | 29 | 2001-2023 |  |
| Country random intercept | $\Delta H_{it}=\beta_0+\beta_1\Delta D_{it}+u_i+\epsilon_{it}$ | 580 | 29 | 2001-2023 | TRUE |
| Country random intercept and health-system moderation | $\Delta H_{it}=\beta_0+\beta_1\Delta D_{it}+\beta_2S_i+\beta_3(\Delta D_{it}\times S_i)+u_i+\epsilon_{it}$ | 580 | 29 | 2001-2023 | TRUE |
| Health-system and public-debt moderation | $\Delta H_{it}=\beta_0+\beta_1\Delta D_{it}+\beta_2S_i+\beta_3(\Delta D_{it}\times S_i)+\beta_4B_{i,t-1}+\beta_5(\Delta D_{it}\times B_{i,t-1})+u_i+\epsilon_{it}$ | 580 | 29 | 2001-2023 | TRUE |
| Fully adjusted with GDP per capita and year effects | $\Delta H_{it}=\beta_0+\beta_1\Delta D_{it}+\beta_2S_i+\beta_3(\Delta D_{it}\times S_i)+\beta_4B_{i,t-1}+\beta_5(\Delta D_{it}\times B_{i,t-1})+\beta_6\log_2(GDPpc_{it})+\gamma_t+u_i+\epsilon_{it}$ | 580 | 29 | 2001-2023 | TRUE |

Here, $\Delta H$ is relative health-spending change, $\Delta D$ is relative defence-spending change, $S$ is health-system type, $B_{i,t-1}$ is previous-year public debt as a share of GDP, $\gamma_t$ denotes categorical year effects, and $u_i$ is the country random intercept.

### Key headline findings

- In Beveridge countries at average previous-year debt, a 10% relative increase in defence spending was associated with a **1.103 [0.415, 1.791]** percentage-point relative change in health spending.
- The defence-change slope difference for Bismarck systems was **-0.455 [-1.288, 0.379]**.
- The defence-by-previous-year-debt interaction was **0.090 [-0.046, 0.226]**.
- The coefficient for a doubling of GDP per capita was **0.474 [0.025, 0.924]**.

Estimates are shown as coefficient [95% confidence interval]. Year-dummy coefficients are omitted from the compact table.

| Term | model_1_unadjusted | model_2_country_random_intercept | model_3_system_moderation | model_4_debt_moderation | model_5_fully_adjusted |
| --- | --- | --- | --- | --- | --- |
| Defence change, per 10% relative increase | 0.913 [0.468, 1.357] | 0.913 [0.470, 1.355] | 1.437 [0.705, 2.170] | 1.370 [0.633, 2.107] | 1.103 [0.415, 1.791] |
| Bismarck-style health system |  |  | -0.681 [-1.618, 0.255] | -0.886 [-1.809, 0.036] | -0.478 [-1.373, 0.417] |
| Defence change x Bismarck system |  |  | -0.818 [-1.735, 0.099] | -0.618 [-1.528, 0.292] | -0.455 [-1.288, 0.379] |
| Previous-year public debt, per 10 percentage points of GDP |  |  |  | -0.306 [-0.447, -0.165] | -0.237 [-0.374, -0.100] |
| Defence change x previous-year public debt |  |  |  | 0.121 [-0.028, 0.269] | 0.090 [-0.046, 0.226] |
| GDP per capita, per doubling |  |  |  |  | 0.474 [0.025, 0.924] |

### Conditional defence slopes

| System | Debt-level percentile | Previous-year debt (% GDP) | Defence slope [95% CI] |
| --- | --- | --- | --- |
| BEV | 25% | 37.84 | 0.912 [0.218, 1.606] |
| BIS | 25% | 37.84 | 0.458 [-0.064, 0.979] |
| BEV | 50% | 51.40 | 1.034 [0.358, 1.711] |
| BIS | 50% | 51.40 | 0.580 [0.037, 1.122] |
| BEV | 75% | 74.60 | 1.244 [0.486, 2.001] |
| BIS | 75% | 74.60 | 0.789 [0.089, 1.490] |

### Categorical year effects

These coefficients are the common year-level differences in relative health-spending change from the 2001 reference year in the fully adjusted model. They should be interpreted as adjustment for shared annual shocks, not as effects caused by the calendar year.

| Year | Effect [95% CI] |
| --- | --- |
| 2001 | 0.000 (reference) |
| 2002 | 1.374 [-1.211, 3.959] |
| 2003 | 0.885 [-1.708, 3.479] |
| 2004 | -3.700 [-6.308, -1.091] |
| 2005 | -1.678 [-4.291, 0.935] |
| 2006 | -4.542 [-7.170, -1.915] |
| 2007 | -3.834 [-6.481, -1.187] |
| 2008 | 0.969 [-1.692, 3.630] |
| 2009 | 4.889 [2.244, 7.535] |
| 2010 | -2.749 [-5.395, -0.103] |
| 2011 | -4.368 [-7.024, -1.711] |
| 2012 | -3.204 [-5.845, -0.564] |
| 2013 | -2.358 [-5.008, 0.292] |
| 2014 | -3.251 [-5.906, -0.596] |
| 2015 | -3.626 [-6.267, -0.986] |
| 2016 | -2.300 [-4.944, 0.344] |
| 2017 | -4.526 [-7.178, -1.874] |
| 2018 | -2.608 [-5.271, 0.056] |
| 2019 | -1.069 [-3.757, 1.619] |
| 2023 | -4.670 [-7.391, -1.948] |

## Secondary analyses

All secondary models use the common form:

$$g(Y_{it})=\beta_0+\beta_W(R_{it}-\bar{R}_i)+\beta_B\bar{R}_i+\beta_SS_i+\beta_G\log_2(GDPpc_{it})+\gamma_t+u_i+\epsilon_{it},$$

where $R$ is the log2 health-to-defence spending ratio. The within-country coefficient is the principal longitudinal association. A one-unit change in log2 ratio represents a doubling of the health-to-defence ratio.

The primary secondary models use outcome levels because beds, workforce, life expectancy, coverage, and mortality are slow-moving stocks or rates, often measured intermittently. Differencing them would discard information and can magnify measurement error. Change in the log ratio paired with year-on-year outcome change is therefore reported as a short-run sensitivity rather than mixed into the primary estimand.

For log-transformed outcomes, effects below are percentage changes per doubling of the ratio. Other outcomes retain the units shown.

| Outcome | Scale | N | Countries | Years | Within-country effect [95% CI] | Between-country effect [95% CI] |
| --- | --- | --- | --- | --- | --- | --- |
| Out-of-pocket expenditure | Percentage points | 638 | 29 | 2000-2023 | -2.792 [-3.667, -1.917] | -8.260 [-12.287, -4.232] |
| Life expectancy at birth | Years | 638 | 29 | 2000-2023 | -0.397 [-0.533, -0.260] | 1.308 [0.223, 2.393] |
| Hospital beds | Beds per 1,000 people | 612 | 29 | 2000-2023 | 0.121 [-0.048, 0.290] | 0.251 [-0.390, 0.893] |
| Medical doctors | Log outcome | 611 | 29 | 2000-2023 | 1.902 [-0.958, 4.845] | 9.481 [-1.341, 21.491] |
| Nurses and midwives | Log outcome | 600 | 29 | 2000-2023 | 1.685 [-1.412, 4.879] | 49.605 [27.046, 76.171] |
| Premature NCD mortality | Log outcome | 580 | 29 | 2000-2019 | -2.456 [-3.861, -1.032] | -17.300 [-28.074, -4.914] |
| Avoidable mortality | Log outcome | 531 | 27 | 2000-2023 | 0.711 [-0.844, 2.290] | -24.850 [-37.335, -9.879] |
| Preventable mortality | Log outcome | 531 | 27 | 2000-2023 | 2.251 [0.617, 3.913] | -19.829 [-32.308, -5.049] |
| Treatable mortality | Log outcome | 455 | 23 | 2000-2023 | -2.870 [-4.962, -0.732] | -27.301 [-42.348, -8.325] |

## Notable sensitivity analyses

### Lagged defence-change sensitivity

These models estimate whether defence-spending change predicts health-spending change one, two, or three years later. For every lag, the debt moderator is measured in the year before the health-spending change outcome.

| Sensitivity | N | Countries | Focal estimate [95% CI] | Singular fit |
| --- | --- | --- | --- | --- |
| One-year lag of defence change | 551 | 29 | 0.739 [-0.018, 1.496] | TRUE |
| Two-year lag of defence change | 493 | 29 | 1.459 [0.676, 2.242] | TRUE |
| Three-year lag of defence change | 464 | 29 | -0.183 [-0.991, 0.625] | TRUE |

### Other notable sensitivities

The focal estimates below correspond to the defence-change term used by each specification.

| Sensitivity | N | Countries | Focal estimate [95% CI] | Singular fit |
| --- | --- | --- | --- | --- |
| Three-year cumulative changes with debt at the start of the period | 522 | 29 | 2.086 [1.349, 2.823] | TRUE |
| Country and year fixed effects | 580 | 29 | 1.160 [0.414, 1.907] |  |
| Generalized least squares with country-specific AR(1) correlation | 580 | 29 | 1.095 [0.391, 1.800] |  |
| GEE with country clusters, AR(1) working correlation, and robust standard errors | 580 | 29 | 1.100 [-0.094, 2.295] |  |
| Absolute percentage-point changes in GDP shares | 580 | 29 | 0.308 [0.072, 0.545] | TRUE |
| Current NATO members only | 480 | 24 | 0.835 [0.018, 1.652] | TRUE |
| Restore Luxembourg while continuing to exclude Iceland | 600 | 30 | 1.063 [0.375, 1.751] | TRUE |
| Include available observations from 2024 | 582 | 29 | 1.090 [0.403, 1.777] | TRUE |
| Exclude 2008 to 2010 | 493 | 29 | 1.065 [0.331, 1.800] | TRUE |
| Health and defence changes winsorised at the 1st and 99th percentiles | 580 | 29 | 1.154 [0.492, 1.816] | TRUE |

Across leave-one-country-out analyses, the headline defence coefficient ranged from **0.687 to 1.536**. The full range of lower and upper confidence limits was **-0.020 to 2.330**.

### Lagged secondary associations

These are within-country model-scale coefficients [95% confidence interval] for lagged log2 spending ratios.

| Outcome | 1-year lag | 3-year lag | 5-year lag |
| --- | --- | --- | --- |
| Out-of-pocket expenditure | -2.088 [-3.016, -1.160] | -1.271 [-2.276, -0.266] | -1.630 [-2.694, -0.566] |
| Life expectancy at birth | -0.473 [-0.621, -0.325] | -0.266 [-0.428, -0.103] | -0.384 [-0.542, -0.227] |
| Hospital beds | 0.187 [-0.002, 0.377] | 0.139 [-0.061, 0.338] | 0.350 [0.151, 0.550] |
| Medical doctors | -0.001 [-0.033, 0.032] | 0.027 [-0.000, 0.055] | -0.010 [-0.039, 0.020] |
| Nurses and midwives | -0.026 [-0.061, 0.008] | -0.026 [-0.060, 0.009] | -0.057 [-0.092, -0.022] |
| Premature NCD mortality | -0.018 [-0.033, -0.003] | -0.018 [-0.033, -0.002] | -0.008 [-0.023, 0.008] |
| Avoidable mortality | 0.018 [0.003, 0.034] | -0.002 [-0.019, 0.014] | 0.002 [-0.014, 0.018] |
| Preventable mortality | 0.032 [0.016, 0.049] | 0.003 [-0.015, 0.021] | 0.006 [-0.012, 0.025] |
| Treatable mortality | -0.013 [-0.035, 0.009] | -0.025 [-0.048, -0.003] | -0.029 [-0.050, -0.009] |

### Change-on-change secondary associations

These sensitivity models relate within-country change in the log2 spending ratio to year-on-year outcome change. Transitions involving 2020 or 2021 are not used. Coefficients are shown on each outcome's model scale.

| Outcome | Same year | 1-year lag | 3-year lag | 5-year lag |
| --- | --- | --- | --- | --- |
| Out-of-pocket expenditure | -2.895 [-3.815, -1.976] | 1.364 [0.228, 2.500] | 0.501 [-0.694, 1.695] | 0.246 [-0.833, 1.326] |
| Life expectancy at birth | 0.120 [-0.035, 0.275] | -0.064 [-0.236, 0.107] | 0.144 [-0.037, 0.325] | -0.253 [-0.445, -0.062] |
| Hospital beds | -0.023 [-0.163, 0.117] | 0.121 [-0.027, 0.268] | -0.057 [-0.203, 0.089] | -0.025 [-0.179, 0.129] |
| Medical doctors | 0.018 [-0.025, 0.062] | -0.007 [-0.057, 0.043] | 0.030 [0.002, 0.058] | -0.012 [-0.037, 0.013] |
| Nurses and midwives | 0.017 [-0.016, 0.051] | 0.000 [-0.038, 0.039] | -0.013 [-0.050, 0.024] | -0.037 [-0.074, -0.000] |
| Premature NCD mortality | -0.007 [-0.019, 0.005] | -0.003 [-0.017, 0.010] | -0.011 [-0.025, 0.003] | -0.009 [-0.024, 0.006] |
| Avoidable mortality | -0.003 [-0.020, 0.014] | -0.005 [-0.023, 0.012] | 0.007 [-0.011, 0.025] | 0.000 [-0.019, 0.019] |
| Preventable mortality | -0.007 [-0.026, 0.011] | -0.001 [-0.020, 0.018] | 0.010 [-0.010, 0.030] | 0.004 [-0.017, 0.025] |
| Treatable mortality | 0.004 [-0.019, 0.027] | -0.003 [-0.027, 0.021] | 0.003 [-0.022, 0.029] | -0.015 [-0.043, 0.012] |

Across the remaining change-on-change models, 5 of 36 95% confidence intervals excluded zero. Directions and timing varied across outcomes, so these results do not indicate a consistent short-run pattern.

## Descriptive figures

### Health-to-defence spending ratio

![Health-to-defence spending ratio over time](health_def_ratio_timeseries.png)

### Average spending by health-system type

![Average health and defence spending as a share of GDP](system_avg_spending_pct_gdp_timeseries.png)

## Interpretation cautions

- The models are associational and may retain residual confounding or reverse causation.
- Health, defence, and debt measures share GDP-related denominators, so common economic shocks can create coupled movements.
- A singular random-intercept fit indicates that the estimated between-country residual variance is effectively zero after included covariates.
- The GEE sensitivity estimates a population-average association with robust standard errors. With 29 country clusters, sandwich standard errors may still have limited small-sample accuracy.
- Secondary analyses are exploratory and span outcomes with different observation schedules and sample sizes.
- Annual differencing may reduce trend confounding but magnifies measurement error and is poorly suited to intermittently observed outcomes.

## Reproducibility

Run the reporting pipeline from the repository root:

```powershell
Rscript code/02_analysis.R
Rscript code/03_sensitivity_analyses.R
Rscript code/04_visualisation.R
Rscript code/05_results_summary.R
```

The report is generated entirely from machine-readable files in `results/`; no estimates are entered manually.
