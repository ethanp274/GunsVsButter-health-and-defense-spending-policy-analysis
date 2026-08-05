# Health and Defence Spending: Results Summary

Generated: 2026-08-05

> These analyses estimate associations and do not establish causation.

## Analysis sample

The main analysis includes **607 observations from 28 countries during 2000-2025**. Iceland and Luxembourg are excluded, 2020-2021 are excluded, and 2022 is unavailable because its previous-year debt value comes from excluded 2021.

The headline model uses categorical year effects and a country random intercept. Its estimated country variance is **0.000000** and its singular-fit status is **TRUE**.

## Primary analysis

### Model sequence

| Model | Equation | N | Countries | Years | Singular fit |
| --- | --- | --- | --- | --- | --- |
| Pooled unadjusted association | $\Delta H_{it}=\beta_0+\beta_1\Delta D_{it}+\epsilon_{it}$ | 607 | 28 | 2000-2025 |  |
| Country random intercept | $\Delta H_{it}=\beta_0+\beta_1\Delta D_{it}+u_i+\epsilon_{it}$ | 607 | 28 | 2000-2025 | TRUE |
| Country random intercept and health-system moderation | $\Delta H_{it}=\beta_0+\beta_1\Delta D_{it}+\beta_2S_i+\beta_3(\Delta D_{it}\times S_i)+u_i+\epsilon_{it}$ | 607 | 28 | 2000-2025 | TRUE |
| Health-system and public-debt moderation | $\Delta H_{it}=\beta_0+\beta_1\Delta D_{it}+\beta_2S_i+\beta_3(\Delta D_{it}\times S_i)+\beta_4B_{i,t-1}+\beta_5(\Delta D_{it}\times B_{i,t-1})+u_i+\epsilon_{it}$ | 607 | 28 | 2000-2025 | TRUE |
| Fully adjusted with GDP per capita and year effects | $\Delta H_{it}=\beta_0+\beta_1\Delta D_{it}+\beta_2S_i+\beta_3(\Delta D_{it}\times S_i)+\beta_4B_{i,t-1}+\beta_5(\Delta D_{it}\times B_{i,t-1})+\beta_6\log_2(GDPpc_{it})+\gamma_t+u_i+\epsilon_{it}$ | 607 | 28 | 2000-2025 | TRUE |

Here, $\Delta H$ is relative health-spending change, $\Delta D$ is relative defence-spending change, $S$ is health-system type, $B_{i,t-1}$ is previous-year public debt as a share of GDP, $\gamma_t$ denotes categorical year effects, and $u_i$ is the country random intercept.

### Key headline findings

- In Beveridge countries at average previous-year debt, a 10% relative increase in defence spending was associated with a **0.866 [0.263, 1.469]** percentage-point relative change in health spending.
- The defence-change slope difference for Bismarck systems was **-0.231 [-0.943, 0.480]**.
- The defence-by-previous-year-debt interaction was **0.054 [-0.056, 0.164]**.
- The coefficient for a doubling of GDP per capita was **0.890 [0.121, 1.658]**.

Estimates are shown as coefficient [95% confidence interval]. Year-dummy coefficients are omitted from the compact table.

| Term | model_1_unadjusted | model_2_country_random_intercept | model_3_system_moderation | model_4_debt_moderation | model_5_fully_adjusted |
| --- | --- | --- | --- | --- | --- |
| Defence change, per 10% relative increase | 0.900 [0.516, 1.285] | 0.900 [0.518, 1.283] | 1.109 [0.491, 1.726] | 1.076 [0.457, 1.695] | 0.866 [0.263, 1.469] |
| Bismarck-style health system |  |  | -0.322 [-1.217, 0.573] | -0.452 [-1.341, 0.436] | -0.148 [-0.979, 0.682] |
| Defence change x Bismarck system |  |  | -0.338 [-1.125, 0.448] | -0.258 [-1.040, 0.524] | -0.231 [-0.943, 0.480] |
| Previous-year public debt, per 10 percentage points of GDP |  |  |  | -0.218 [-0.347, -0.089] | -0.160 [-0.282, -0.036] |
| Defence change x previous-year public debt |  |  |  | 0.077 [-0.041, 0.195] | 0.054 [-0.056, 0.164] |
| GDP per capita, per doubling |  |  |  |  | 0.890 [0.121, 1.658] |

### Conditional defence slopes

| System | Debt-level percentile | Previous-year debt (% GDP) | Defence slope [95% CI] |
| --- | --- | --- | --- |
| BEV | 25% | 37.97 | 0.751 [0.143, 1.359] |
| BIS | 25% | 37.97 | 0.519 [0.043, 0.996] |
| BEV | 50% | 51.13 | 0.822 [0.228, 1.416] |
| BIS | 50% | 51.13 | 0.590 [0.117, 1.064] |
| BEV | 75% | 77.81 | 0.966 [0.296, 1.635] |
| BIS | 75% | 77.81 | 0.734 [0.144, 1.324] |

### Categorical year effects

These coefficients are the common year-level differences in relative health-spending change from the 2000 reference year in the fully adjusted model. They should be interpreted as adjustment for shared annual shocks, not as effects caused by the calendar year.

| Year | Effect [95% CI] |
| --- | --- |
| 2000 | 0.000 (reference) |
| 2001 | 2.419 [-0.433, 5.272] |
| 2002 | 3.321 [0.460, 6.181] |
| 2003 | 2.734 [-0.118, 5.586] |
| 2004 | -1.138 [-3.913, 1.638] |
| 2005 | 0.490 [-2.286, 3.267] |
| 2006 | -1.408 [-4.193, 1.377] |
| 2007 | -1.349 [-4.141, 1.442] |
| 2008 | 3.776 [0.970, 6.582] |
| 2009 | 8.252 [5.449, 11.055] |
| 2010 | -0.525 [-3.326, 2.276] |
| 2011 | -2.249 [-5.055, 0.557] |
| 2012 | -1.048 [-3.857, 1.760] |
| 2013 | 0.164 [-2.652, 2.981] |
| 2014 | -1.175 [-3.998, 1.648] |
| 2015 | -1.496 [-4.330, 1.337] |
| 2016 | 0.137 [-2.715, 2.989] |
| 2017 | -2.607 [-5.443, 0.230] |
| 2018 | -0.736 [-3.596, 2.125] |
| 2019 | 1.263 [-1.649, 4.176] |
| 2023 | -2.917 [-5.943, 0.109] |
| 2024 | 1.919 [-1.155, 4.993] |
| 2025 | -1.486 [-4.721, 1.749] |

## Secondary analyses

All secondary models use the common form:

$$g(Y_{it})=\beta_0+\beta_W(R_{it}-\bar{R}_i)+\beta_B\bar{R}_i+\beta_SS_i+\beta_G\log_2(GDPpc_{it})+\gamma_t+u_i+\epsilon_{it},$$

where $R$ is the log2 health-to-defence spending ratio. The within-country coefficient is the principal longitudinal association. A one-unit change in log2 ratio represents a doubling of the health-to-defence ratio.

Hospital beds use OECD as the primary source, with WHO values used only for country-years where OECD is missing.

The primary secondary models use outcome levels because the out-of-pocket share of current health expenditure, beds, workforce, and treatable mortality are slow-moving measures, often observed intermittently. Differencing them would discard information and can magnify measurement error. Change in the log ratio paired with year-on-year outcome change is therefore reported as a short-run sensitivity rather than mixed into the primary estimand.

For log-transformed outcomes, effects below are percentage changes per doubling of the ratio. Other outcomes retain the units shown.

| Outcome | Scale | N | Countries | Years | Within-country effect [95% CI] | Between-country effect [95% CI] |
| --- | --- | --- | --- | --- | --- | --- |
| Out-of-pocket share of health expenditure | Percentage points of current health expenditure | 622 | 28 | 2000-2025 | -3.128 [-3.991, -2.265] | -5.664 [-9.457, -1.871] |
| Hospital beds | Beds per 1,000 people | 610 | 28 | 2000-2025 | 0.249 [0.094, 0.405] | -0.171 [-0.783, 0.442] |
| Medical doctors | Log outcome | 530 | 28 | 2000-2025 | 7.610 [5.366, 9.902] | 1.795 [-6.588, 10.931] |
| Nurses and midwives | Log outcome | 522 | 27 | 2000-2025 | 6.161 [3.364, 9.034] | 44.180 [24.793, 66.580] |
| Treatable mortality | Log outcome | 533 | 26 | 2000-2024 | -1.033 [-3.053, 1.029] | -34.152 [-45.278, -20.764] |

## Notable sensitivity analyses

### Lagged defence-change sensitivity

These models estimate whether defence-spending change predicts health-spending change one, two, or three years later. For every lag, the debt moderator is measured in the year before the health-spending change outcome.

| Sensitivity | N | Countries | Focal estimate [95% CI] | Singular fit |
| --- | --- | --- | --- | --- |
| One-year lag of defence change | 586 | 28 | 0.369 [-0.294, 1.033] | TRUE |
| Two-year lag of defence change | 534 | 28 | 0.982 [0.298, 1.665] | TRUE |
| Three-year lag of defence change | 483 | 28 | -0.068 [-0.871, 0.735] | TRUE |

### Other notable sensitivities

The focal estimates below correspond to the defence-change term used by each specification.

| Sensitivity | N | Countries | Focal estimate [95% CI] | Singular fit |
| --- | --- | --- | --- | --- |
| Three-year cumulative changes with debt at the start of the period | 503 | 28 | 1.415 [0.817, 2.013] | FALSE |
| Country and year fixed effects | 607 | 28 | 0.855 [0.202, 1.507] |  |
| Generalized least squares with country-specific AR(1) correlation | 607 | 28 | 0.867 [0.251, 1.484] |  |
| GEE with country clusters, AR(1) working correlation, and robust standard errors | 607 | 28 | 0.865 [-0.111, 1.841] |  |
| Absolute percentage-point changes in GDP shares | 586 | 28 | 0.141 [-0.065, 0.348] | TRUE |
| Current NATO members only | 516 | 23 | 0.358 [-0.294, 1.010] | TRUE |
| Restore Luxembourg while continuing to exclude Iceland | 630 | 29 | 0.814 [0.212, 1.415] | TRUE |
| Exclude observations from 2025 | 583 | 28 | 1.325 [0.639, 2.012] | TRUE |
| Exclude 2008 to 2010 | 526 | 28 | 0.801 [0.166, 1.437] | TRUE |
| Health and defence changes winsorised at the 1st and 99th percentiles | 607 | 28 | 0.870 [0.319, 1.422] | TRUE |

Across leave-one-country-out analyses, the headline defence coefficient ranged from **0.479 to 1.049**. The full range of lower and upper confidence limits was **-0.137 to 1.708**.

### Lagged secondary associations

These are within-country model-scale coefficients [95% confidence interval] for lagged log2 spending ratios.

| Outcome | 1-year lag | 3-year lag | 5-year lag |
| --- | --- | --- | --- |
| Out-of-pocket share of health expenditure | -2.588 [-3.499, -1.678] | -1.528 [-2.531, -0.524] | -1.535 [-2.681, -0.389] |
| Hospital beds | 0.255 [0.090, 0.421] | 0.012 [-0.185, 0.209] | 0.186 [-0.001, 0.373] |
| Medical doctors | 0.063 [0.040, 0.086] | 0.047 [0.019, 0.075] | 0.034 [0.005, 0.063] |
| Nurses and midwives | 0.052 [0.024, 0.081] | 0.033 [-0.004, 0.070] | 0.032 [-0.005, 0.069] |
| Treatable mortality | 0.001 [-0.020, 0.022] | -0.017 [-0.039, 0.004] | -0.012 [-0.033, 0.009] |

### Change-on-change secondary associations

These sensitivity models relate within-country change in the log2 spending ratio to year-on-year outcome change. Transitions involving 2020 or 2021 are not used. Coefficients are shown on each outcome's model scale.

| Outcome | Same year | 1-year lag | 3-year lag | 5-year lag |
| --- | --- | --- | --- | --- |
| Out-of-pocket share of health expenditure | -2.291 [-3.186, -1.396] | 1.180 [0.126, 2.234] | -0.425 [-1.698, 0.848] | 0.115 [-0.878, 1.108] |
| Hospital beds | -0.014 [-0.113, 0.085] | 0.041 [-0.079, 0.161] | 0.048 [-0.085, 0.182] | -0.026 [-0.142, 0.090] |
| Medical doctors | 0.015 [-0.004, 0.034] | -0.016 [-0.038, 0.006] | 0.032 [0.006, 0.058] | -0.010 [-0.030, 0.011] |
| Nurses and midwives | 0.010 [-0.010, 0.031] | 0.008 [-0.017, 0.033] | -0.014 [-0.043, 0.015] | -0.019 [-0.044, 0.007] |
| Treatable mortality | 0.006 [-0.013, 0.024] | -0.001 [-0.022, 0.020] | 0.008 [-0.015, 0.031] | -0.014 [-0.037, 0.009] |

Across the remaining change-on-change models, 3 of 20 95% confidence intervals excluded zero. Directions and timing varied across outcomes, so these results do not indicate a consistent short-run pattern.

## Descriptive figures

### Health-to-defence spending ratio

![Health-to-defence spending ratio over time](health_def_ratio_timeseries.png)

### Average spending by health-system type

![Average health and defence spending as a share of GDP](system_avg_spending_pct_gdp_timeseries.png)

## Interpretation cautions

- The models are associational and may retain residual confounding or reverse causation.
- Health, defence, and debt measures share GDP-related denominators, so common economic shocks can create coupled movements.
- A singular random-intercept fit indicates that the estimated between-country residual variance is effectively zero after included covariates.
- The GEE sensitivity estimates a population-average association with robust standard errors. With 28 country clusters, sandwich standard errors may still have limited small-sample accuracy.
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
