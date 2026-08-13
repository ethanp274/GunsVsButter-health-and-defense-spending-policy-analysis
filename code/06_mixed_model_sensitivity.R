#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# SENSITIVITY CHECK FOR MIXED-MODEL SINGULARITY
# Harry Rourke & Ethan Phillips
# Last updated: 2026-08-13
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(lme4)
  library(tidyr)
  library(purrr)
})

# Load the processed country-year panel.
master_df <- read_csv(
  "processed_data/primary_analysis.csv",
  na = "",
  show_col_types = FALSE
)

excluded_analysis_years <- c(2020L, 2021L)
analysis_end_year <- max(master_df$year, na.rm = TRUE)

primary_df <- master_df %>%
  group_by(code) %>%
  arrange(year, .by_group = TRUE) %>%
  mutate(
    previous_debt_10pp = if_else(
      (year - 1L) %in% excluded_analysis_years,
      NA_real_,
      previous_government_debt_pct_gdp / 0.10
    )
  ) %>%
  ungroup() %>%
  filter(
    year <= analysis_end_year,
    !year %in% excluded_analysis_years
  ) %>%
  mutate(
    country = factor(country),
    system = relevel(factor(system), ref = "BEV"),
    year_factor = factor(year),
    health_change_percent = 100 * change_health_gdp,
    defence_change_10pct = change_def_gdp / 0.10,
    log2_gdp_percap = log2(gdp_percap)
  )

previous_debt_center <- mean(primary_df$previous_debt_10pp, na.rm = TRUE)
gdp_center <- mean(primary_df$log2_gdp_percap, na.rm = TRUE)

primary_df <- primary_df %>%
  mutate(
    previous_debt_10pp_c = previous_debt_10pp - previous_debt_center,
    log2_gdp_percap_c = log2_gdp_percap - gdp_center
  )

main_required_vars <- c(
  "health_change_percent",
  "defence_change_10pct",
  "previous_debt_10pp_c",
  "log2_gdp_percap_c",
  "system",
  "country",
  "year_factor"
)

main_data <- primary_df[complete.cases(primary_df[main_required_vars]), ] %>%
  droplevels()

formula_main <- health_change_percent ~
  defence_change_10pct + defence_change_10pct:system +
  defence_change_10pct * previous_debt_10pp_c +
  log2_gdp_percap_c +
  year_factor +
  (1 | country)

# Build a small grid of estimation settings.
# The goal is to assess whether the singular fit is a stable feature of the data
# or a numerical artefact of the default optimiser configuration.
case_table <- tribble(
  ~case_id, ~description, ~optimizer, ~opt_ctrl, ~start_theta, ~check_conv_singular,
  "default", "lme4 default", "bobyqa", list(maxfun = 20000L), NA_real_, "warning",
  "bobyqa_hard", "Bobyqa, higher maxfun", "bobyqa", list(maxfun = 100000L), NA_real_, "warning",
  "nm", "Nelder_Mead", "Nelder_Mead", list(maxfun = 20000L), NA_real_, "warning",
  "nloptwrap", "nloptwrap (BFGS-like fallback)", "nloptwrap", list(maxfun = 20000L), NA_real_, "warning",
  "bobyqa_start_0", "Bobyqa with small random-effect start", "bobyqa", list(maxfun = 20000L), 0, "warning",
  "bobyqa_start_1", "Bobyqa with moderate random-effect start", "bobyqa", list(maxfun = 20000L), log(1), "warning",
  "bobyqa_start_2", "Bobyqa with larger random-effect start", "bobyqa", list(maxfun = 20000L), log(2), "warning",
  "tight_tol", "Tighter convergence tolerances", "bobyqa", list(maxfun = 20000L, xtol_abs = 1e-10, ftol_abs = 1e-10), NA_real_, "warning"
)

fit_case <- function(case_row) {
  ctrl <- lmerControl(
    optimizer = case_row$optimizer,
    optCtrl = case_row$opt_ctrl,
    check.conv.singular = case_row$check_conv_singular,
    check.conv.grad = .makeCC("warning", 0.6),
    check.conv.hess = .makeCC("warning", 0.6),
    check.nobs.vs.rankZ = "warning",
    check.nobs.vs.nlev = "warning",
    check.nlev.gtreq.5 = "ignore"
  )

  start_spec <- NULL
  if (!is.na(case_row$start_theta)) {
    start_spec <- list(theta = rep(case_row$start_theta, 1))
  }

  fit <- tryCatch(
    {
      if (is.null(start_spec)) {
        lmer(formula_main, data = main_data, REML = FALSE, control = ctrl)
      } else {
        lmer(formula_main, data = main_data, REML = FALSE, control = ctrl, start = start_spec)
      }
    },
    error = function(e) e
  )

  if (inherits(fit, "error")) {
    return(tibble(
      case_id = case_row$case_id,
      description = case_row$description,
      optimizer = case_row$optimizer,
      maxfun = if (!is.null(case_row$opt_ctrl$maxfun)) case_row$opt_ctrl$maxfun else NA_real_,
      start_theta = if (is.na(case_row$start_theta)) NA_real_ else case_row$start_theta,
      success = FALSE,
      converged = NA,
      singular = NA,
      logLik = NA_real_,
      sigma = NA_real_,
      random_effect_variance = NA_real_,
      error = conditionMessage(fit)
    ))
  }

  var_corr <- as.data.frame(VarCorr(fit))
  country_var <- var_corr %>%
    filter(grp == "country", var1 == "(Intercept)") %>%
    pull(vcov)

  if (length(country_var) == 0) {
    country_var <- NA_real_
  }

  convergence_message <- NA_character_
  if (!is.null(fit@optinfo$conv$lme4$messages)) {
    convergence_message <- paste(fit@optinfo$conv$lme4$messages, collapse = "; ")
  }

  tibble(
    case_id = case_row$case_id,
    description = case_row$description,
    optimizer = case_row$optimizer,
    maxfun = if (!is.null(case_row$opt_ctrl$maxfun)) case_row$opt_ctrl$maxfun else NA_real_,
    start_theta = if (is.na(case_row$start_theta)) NA_real_ else case_row$start_theta,
    success = TRUE,
    converged = isTRUE(fit@optinfo$conv$lme4$conv$opt == 0L),
    singular = isSingular(fit),
    logLik = as.numeric(logLik(fit)),
    sigma = sigma(fit),
    random_effect_variance = if (length(country_var) == 0) NA_real_ else as.numeric(country_var),
    error = NA_character_,
    convergence_message = convergence_message
  )
}

results <- bind_rows(lapply(split(case_table, 1:nrow(case_table)), fit_case))

# Also record the fixed-effect estimates for the final comparison.
fixed_effects <- bind_rows(lapply(split(case_table, 1:nrow(case_table)), function(case_row) {
  ctrl <- lmerControl(
    optimizer = case_row$optimizer,
    optCtrl = case_row$opt_ctrl,
    check.conv.singular = case_row$check_conv_singular,
    check.conv.grad = .makeCC("warning", 0.6),
    check.conv.hess = .makeCC("warning", 0.6),
    check.nobs.vs.rankZ = "warning",
    check.nobs.vs.nlev = "warning",
    check.nlev.gtreq.5 = "ignore"
  )

  start_spec <- NULL
  if (!is.na(case_row$start_theta)) {
    start_spec <- list(theta = rep(case_row$start_theta, 1))
  }

  fit <- tryCatch(
    {
      if (is.null(start_spec)) {
        lmer(formula_main, data = main_data, REML = FALSE, control = ctrl)
      } else {
        lmer(formula_main, data = main_data, REML = FALSE, control = ctrl, start = start_spec)
      }
    },
    error = function(e) NULL
  )

  if (is.null(fit)) {
    return(tibble())
  }

  beta <- fixef(fit)
  coef_frame <- tibble(
    case_id = case_row$case_id,
    term = names(beta),
    estimate = as.numeric(beta)
  )

  coef_frame
}))

# Save the raw comparison outputs.
results_dir <- "results"
dir.create(results_dir, showWarnings = FALSE)
write_csv(results, "results/mixed_model_optimizer_sensitivity.csv")
write_csv(fixed_effects, "results/mixed_model_optimizer_fixed_effects.csv")

# Print a concise summary to the console for quick inspection.
print(results %>%
  select(case_id, description, optimizer, success, converged, singular, sigma, random_effect_variance, logLik) %>%
  arrange(case_id))
