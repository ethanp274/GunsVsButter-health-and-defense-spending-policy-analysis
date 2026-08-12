#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# SENSITIVITY ANALYSES OF HEALTH AND DEFENCE SPENDING
# Harry Rourke & Ethan Phillips
# Last updated: 2026-08-05
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# This script is independent of 02_analysis.R and can be run from a fresh session.

suppressPackageStartupMessages({
  library(broom)
  library(broom.mixed)
  library(dplyr)
  library(lme4)
  library(nlme)
  library(readr)
  library(tidyr)
})


# Load the processed panel
master_df <- read_csv(
  "processed_data/primary_analysis.csv",
  na = "",
  show_col_types = FALSE
)

results_dir <- "results"
dir.create(results_dir, showWarnings = FALSE)

excluded_analysis_years <- c(2020L, 2021L)
current_non_nato_codes <- c("AUT", "CYP", "IRL", "MLT", "CHE")
# Current OECD members represented in the 30-country study-country source.
# Iceland is absent from that source.
oecd_member_codes <- c(
  "AUT", "BEL", "CZE", "DNK", "EST", "FIN", "FRA", "DEU", "GRC",
  "HUN", "IRL", "ITA", "LVA", "LTU", "LUX", "NLD", "NOR", "POL",
  "PRT", "SVK", "SVN", "ESP", "SWE", "CHE", "GBR"
)
analysis_end_year <- max(master_df$year, na.rm = TRUE)


# Create annual, lagged, cumulative, and alternative change measures
panel_df <- master_df %>%
  group_by(code) %>%
  arrange(year, .by_group = TRUE) %>%
  mutate(
    health_change_percent = 100 * change_health_gdp,
    defence_change_10pct = change_def_gdp / 0.10,
    current_debt_10pp = government_debt_pct_gdp / 0.10,
    log2_gdp_percap = log2(gdp_percap),
    gdp_per_10k = gdp_percap / 10000,
    health_change_pp = 100 * (health_pct_gdp - lag(health_pct_gdp)),
    defence_change_pp = 100 * (defence_pct_gdp - lag(defence_pct_gdp)),
    debt_change_pp = 100 * (
      government_debt_pct_gdp - lag(government_debt_pct_gdp)
    ),
    previous_debt_10pp = if_else(
      (year - 1L) %in% excluded_analysis_years,
      NA_real_,
      previous_government_debt_pct_gdp / 0.10
    ),
    debt_start_3yr_10pp = if_else(
      (year - 3L) %in% excluded_analysis_years,
      NA_real_,
      lag(government_debt_pct_gdp, 3) / 0.10
    ),
    lag_defence_1_10pct = if_else(
      (year - 1L) %in% excluded_analysis_years,
      NA_real_,
      lag(change_def_gdp, 1) / 0.10
    ),
    lag_defence_2_10pct = if_else(
      (year - 2L) %in% excluded_analysis_years,
      NA_real_,
      lag(change_def_gdp, 2) / 0.10
    ),
    lag_defence_3_10pct = if_else(
      (year - 3L) %in% excluded_analysis_years,
      NA_real_,
      lag(change_def_gdp, 3) / 0.10
    ),
    health_change_3yr_percent = if_else(
      !is.na(health_pct_gdp) &
        !is.na(lag(health_pct_gdp, 3)) &
        lag(health_pct_gdp, 3) > 0,
      100 * (health_pct_gdp / lag(health_pct_gdp, 3) - 1),
      NA_real_
    ),
    defence_change_3yr_10pct = if_else(
      !is.na(defence_pct_gdp) &
        !is.na(lag(defence_pct_gdp, 3)) &
        lag(defence_pct_gdp, 3) > 0,
      (defence_pct_gdp / lag(defence_pct_gdp, 3) - 1) / 0.10,
      NA_real_
    ),
    log2_ratio = if_else(
      health_def_ratio > 0,
      log2(health_def_ratio),
      NA_real_
    ),
    change_log2_ratio = log2_ratio - lag(log2_ratio),
    lag_log2_ratio_1 = if_else(
      (year - 1L) %in% excluded_analysis_years,
      NA_real_,
      lag(log2_ratio, 1)
    ),
    lag_log2_ratio_3 = if_else(
      (year - 3L) %in% excluded_analysis_years,
      NA_real_,
      lag(log2_ratio, 3)
    ),
    lag_log2_ratio_5 = if_else(
      (year - 5L) %in% excluded_analysis_years,
      NA_real_,
      lag(log2_ratio, 5)
    ),
    lag_change_log2_ratio_1 = if_else(
      (year - 1L) %in% excluded_analysis_years,
      NA_real_,
      lag(change_log2_ratio, 1)
    ),
    lag_change_log2_ratio_3 = if_else(
      (year - 3L) %in% excluded_analysis_years,
      NA_real_,
      lag(change_log2_ratio, 3)
    ),
    lag_change_log2_ratio_5 = if_else(
      (year - 5L) %in% excluded_analysis_years,
      NA_real_,
      lag(change_log2_ratio, 5)
    ),
    log2_health_share = if_else(
      health_pct_gdp > 0,
      log2(health_pct_gdp),
      NA_real_
    ),
    log2_defence_share = if_else(
      defence_pct_gdp > 0,
      log2(defence_pct_gdp),
      NA_real_
    )
  ) %>%
  ungroup()


# Use the primary sample to define common centring constants
primary_df <- panel_df %>%
  filter(
    year <= analysis_end_year,
    !year %in% excluded_analysis_years
  )

centres <- c(
  current_debt_10pp = mean(primary_df$current_debt_10pp, na.rm = TRUE),
  log2_gdp_percap = mean(primary_df$log2_gdp_percap, na.rm = TRUE),
  debt_change_pp = mean(primary_df$debt_change_pp, na.rm = TRUE),
  previous_debt_10pp = mean(primary_df$previous_debt_10pp, na.rm = TRUE),
  debt_start_3yr_10pp = mean(
    primary_df$debt_start_3yr_10pp,
    na.rm = TRUE
  ),
  gdp_per_10k = mean(primary_df$gdp_per_10k, na.rm = TRUE)
)

panel_df <- panel_df %>%
  mutate(
    current_debt_10pp_c =
      current_debt_10pp - centres[["current_debt_10pp"]],
    log2_gdp_percap_c =
      log2_gdp_percap - centres[["log2_gdp_percap"]],
    debt_change_pp_c =
      debt_change_pp - centres[["debt_change_pp"]],
    previous_debt_10pp_c =
      previous_debt_10pp - centres[["previous_debt_10pp"]],
    debt_start_3yr_10pp_c =
      debt_start_3yr_10pp - centres[["debt_start_3yr_10pp"]],
    gdp_per_10k_c =
      gdp_per_10k - centres[["gdp_per_10k"]],
    country = factor(country),
    system = relevel(factor(system), ref = "BEV"),
    year_factor = factor(year)
  )

primary_df <- panel_df %>%
  filter(
    year <= analysis_end_year,
    !year %in% excluded_analysis_years
  )


# Helpers fit models safely and preserve visible diagnostics
model_status <- function(model) {
  if (inherits(model, "error")) {
    return(conditionMessage(model))
  }

  if (inherits(model, "merMod")) {
    messages <- model@optinfo$conv$lme4$messages

    if (!is.null(messages)) {
      if (all(grepl("singular", messages, ignore.case = TRUE))) {
        return("Model fitted; singular random effect")
      }

      return(
        paste(
          "Convergence warning:",
          paste(messages, collapse = "; ")
        )
      )
    }
  }

  "Model fitted"
}

tidy_sensitivity_model <- function(model, model_name, description) {
  if (inherits(model, "error")) {
    return(tibble(
      model = model_name,
      description,
      term = NA_character_,
      estimate = NA_real_,
      std_error = NA_real_,
      conf_low = NA_real_,
      conf_high = NA_real_,
      statistic = NA_real_,
      p_value = NA_real_
    ))
  }

  result <- if (inherits(model, "merMod")) {
    broom.mixed::tidy(
      model,
      effects = "fixed",
      conf.int = TRUE,
      conf.method = "Wald"
    )
  } else {
    broom::tidy(
      model,
      conf.int = TRUE
    )
  }

  result %>%
    transmute(
      model = model_name,
      description,
      term,
      estimate,
      std_error = std.error,
      conf_low = conf.low,
      conf_high = conf.high,
      statistic,
      p_value = if ("p.value" %in% names(result)) p.value else NA_real_
    )
}

fit_sensitivity_model <- function(
    data,
    model_name,
    description,
    formula,
    model_type = "lmer") {
  required_vars <- all.vars(formula)
  model_data <- data[
    complete.cases(data[required_vars]),
  ] %>%
    arrange(country, year) %>%
    droplevels()

  model <- tryCatch(
    {
      if (model_type == "lmer") {
        lmer(
          formula,
          data = model_data,
          REML = FALSE
        )
      } else if (model_type == "lm") {
        lm(
          formula,
          data = model_data
        )
      } else if (model_type == "gls_ar1") {
        nlme::gls(
          formula,
          data = model_data,
          correlation = nlme::corAR1(
            form = ~ year | country
          ),
          method = "ML"
        )
      } else {
        stop("Unknown model type: ", model_type)
      }
    },
    error = function(e) e
  )

  model_object <- model

  overview <- tibble(
    model = model_name,
    description,
    model_type,
    observations = nrow(model_data),
    countries = n_distinct(model_data$country),
    first_year = if (nrow(model_data) > 0) min(model_data$year) else NA_integer_,
    last_year = if (nrow(model_data) > 0) max(model_data$year) else NA_integer_,
    converged = if (inherits(model_object, "error")) {
      FALSE
    } else if (inherits(model_object, "merMod")) {
      optimizer_code <- model_object@optinfo$conv$opt
      is.null(optimizer_code) || all(optimizer_code == 0)
    } else {
      TRUE
    },
    singular_fit = if (inherits(model_object, "merMod")) {
      isSingular(model_object)
    } else {
      NA
    },
    status = model_status(model_object)
  )

  list(
    model = model,
    data = model_data,
    overview = overview,
    coefficients = tidy_sensitivity_model(
      model,
      model_name,
      description
    )
  )
}


# The fully adjusted annual-change formula is the reference specification
full_formula <- health_change_percent ~
  defence_change_10pct * system +
  defence_change_10pct * previous_debt_10pp_c +
  log2_gdp_percap_c +
  year_factor +
  (1 | country)

main_sensitivity_models <- list()

add_main_sensitivity <- function(
    model_name,
    description,
    data,
    formula,
    model_type = "lmer") {
  main_sensitivity_models[[model_name]] <<- fit_sensitivity_model(
    data = data,
    model_name = model_name,
    description = description,
    formula = formula,
    model_type = model_type
  )
}


# Test one-, two-, and three-year lags
#
# Each lagged defence change is moderated by debt measured one year before
# the health-spending change outcome.
add_main_sensitivity(
  "lag_1_year",
  "One-year lag of defence change",
  primary_df,
  health_change_percent ~
    lag_defence_1_10pct * system +
    lag_defence_1_10pct * previous_debt_10pp_c +
    log2_gdp_percap_c +
    year_factor +
    (1 | country)
)

add_main_sensitivity(
  "lag_2_years",
  "Two-year lag of defence change",
  primary_df,
  health_change_percent ~
    lag_defence_2_10pct * system +
    lag_defence_2_10pct * previous_debt_10pp_c +
    log2_gdp_percap_c +
    year_factor +
    (1 | country)
)

add_main_sensitivity(
  "lag_3_years",
  "Three-year lag of defence change",
  primary_df,
  health_change_percent ~
    lag_defence_3_10pct * system +
    lag_defence_3_10pct * previous_debt_10pp_c +
    log2_gdp_percap_c +
    year_factor +
    (1 | country)
)

add_main_sensitivity(
  "cumulative_3_year_change",
  "Three-year cumulative changes with debt at the start of the period",
  primary_df,
  health_change_3yr_percent ~
    defence_change_3yr_10pct * system +
    defence_change_3yr_10pct * debt_start_3yr_10pp_c +
    log2_gdp_percap_c +
    year_factor +
    (1 | country)
)


# Test alternative country and residual-correlation structures
add_main_sensitivity(
  "country_fixed_effects",
  "Country and year fixed effects",
  primary_df,
  health_change_percent ~
    defence_change_10pct * system +
    defence_change_10pct * previous_debt_10pp_c +
    log2_gdp_percap_c +
    year_factor +
    country,
  model_type = "lm"
)

add_main_sensitivity(
  "gls_ar1",
  "Generalized least squares with country-specific AR(1) correlation",
  primary_df,
  health_change_percent ~
    defence_change_10pct * system +
    defence_change_10pct * previous_debt_10pp_c +
    log2_gdp_percap_c +
    year_factor,
  model_type = "gls_ar1"
)

# Test alternative change measures and adjustments
add_main_sensitivity(
  "absolute_percentage_point_changes",
  "Absolute percentage-point changes in GDP shares",
  primary_df,
  health_change_pp ~
    defence_change_pp * system +
    defence_change_pp * previous_debt_10pp_c +
    log2_gdp_percap_c +
    year_factor +
    (1 | country)
)

add_main_sensitivity(
  "current_debt_level",
  "Current-year public-debt level as moderator",
  primary_df,
  health_change_percent ~
    defence_change_10pct * system +
    defence_change_10pct * current_debt_10pp_c +
    log2_gdp_percap_c +
    year_factor +
    (1 | country)
)

add_main_sensitivity(
  "debt_percentage_point_change",
  "Public-debt percentage-point change as moderator",
  primary_df,
  health_change_percent ~
    defence_change_10pct * system +
    defence_change_10pct * debt_change_pp_c +
    log2_gdp_percap_c +
    year_factor +
    (1 | country)
)

add_main_sensitivity(
  "debt_without_moderation",
  "Previous-year public-debt level without interaction",
  primary_df,
  health_change_percent ~
    defence_change_10pct * system +
    previous_debt_10pp_c +
    log2_gdp_percap_c +
    year_factor +
    (1 | country)
)

add_main_sensitivity(
  "untransformed_gdp_per_capita",
  "GDP per capita in $10,000 units",
  primary_df,
  health_change_percent ~
    defence_change_10pct * system +
    defence_change_10pct * previous_debt_10pp_c +
    gdp_per_10k_c +
    year_factor +
    (1 | country)
)


# Test alternative country and year samples
add_main_sensitivity(
  "nato_members_only",
  "NATO members only",
  primary_df %>%
    filter(!code %in% current_non_nato_codes),
  full_formula
)

add_main_sensitivity(
  "oecd_members_only",
  "OECD members only",
  primary_df %>%
    filter(code %in% oecd_member_codes),
  full_formula
)

add_main_sensitivity(
  "exclude_greece",
  "Exclude Greece",
  primary_df %>%
    filter(code != "GRC"),
  full_formula
)

# Include the pandemic years as an explicit main-model sensitivity. The
# primary models and ordinary sensitivities continue to exclude 2020-2021.
# Here, previous-year debt is restored for all years so 2021 uses 2020 debt and
# 2022 uses 2021 debt.
covid_included_df <- panel_df %>%
  mutate(
    previous_debt_10pp = previous_government_debt_pct_gdp / 0.10,
    previous_debt_10pp_c =
      previous_debt_10pp - centres[["previous_debt_10pp"]]
  )

add_main_sensitivity(
  "include_covid_years",
  "Include 2020 and 2021 COVID years and restore 2022 debt alignment",
  covid_included_df,
  full_formula
)

add_main_sensitivity(
  "exclude_2025",
  "Exclude observations from 2025",
  primary_df %>%
    filter(
      year < analysis_end_year
    ),
  full_formula
)

add_main_sensitivity(
  "exclude_financial_crisis",
  "Exclude 2008 to 2010",
  primary_df %>%
    filter(!year %in% 2008:2010),
  full_formula
)


# Define NATO membership using accession years
nato_join_years <- c(
  BEL = 1949, DNK = 1949, FRA = 1949, ITA = 1949,
  LUX = 1949, NLD = 1949, NOR = 1949, PRT = 1949, GBR = 1949,
  GRC = 1952, DEU = 1955, ESP = 1982,
  CZE = 1999, HUN = 1999, POL = 1999,
  BGR = 2004, EST = 2004, LVA = 2004, LTU = 2004, ROU = 2004,
  SVK = 2004, SVN = 2004, HRV = 2009, FIN = 2023, SWE = 2024
)

historical_nato_df <- primary_df %>%
  mutate(nato_join_year = unname(nato_join_years[code])) %>%
  filter(!is.na(nato_join_year), year >= nato_join_year)

add_main_sensitivity(
  "historical_nato_membership",
  "Country-years at or after NATO accession",
  historical_nato_df,
  full_formula
)


# Winsorise health and defence changes at the 1st and 99th percentiles
winsorise <- function(x, reference) {
  limits <- quantile(
    reference,
    probs = c(0.01, 0.99),
    na.rm = TRUE
  )

  pmin(pmax(x, limits[[1]]), limits[[2]])
}

winsorised_df <- primary_df %>%
  mutate(
    health_change_percent = winsorise(
      health_change_percent,
      primary_df$health_change_percent
    ),
    defence_change_10pct = winsorise(
      defence_change_10pct,
      primary_df$defence_change_10pct
    )
  )

add_main_sensitivity(
  "winsorised_changes",
  "Health and defence changes winsorised at the 1st and 99th percentiles",
  winsorised_df,
  full_formula
)


# Assess whether one country drives the headline coefficients
leave_one_country_out <- bind_rows(
  lapply(sort(unique(primary_df$code)), function(omitted_code) {
    result <- fit_sensitivity_model(
      data = primary_df %>% filter(code != omitted_code),
      model_name = paste0("omit_", omitted_code),
      description = paste("Omit", omitted_code),
      formula = full_formula,
      model_type = "lmer"
    )

    result$coefficients %>%
      filter(
        term %in% c(
          "defence_change_10pct",
          "defence_change_10pct:systemBIS",
          "defence_change_10pct:previous_debt_10pp_c"
        )
      ) %>%
      mutate(
        omitted_code,
        observations = result$overview$observations,
        countries = result$overview$countries,
        singular_fit = result$overview$singular_fit,
        status = result$overview$status
      )
  })
)


# Combine and save the main sensitivity results
main_sensitivity_overview <- bind_rows(
  lapply(main_sensitivity_models, `[[`, "overview")
)

main_sensitivity_coefficients <- bind_rows(
  lapply(main_sensitivity_models, `[[`, "coefficients")
) %>%
  mutate(
    across(
      c(estimate, std_error, conf_low, conf_high, statistic, p_value),
      ~ round(.x, 4)
    )
  )


# Prepare secondary outcome levels and year-on-year changes
#
# Level models answer whether the spending balance is associated with the
# level of system strength or health outcomes. Change-on-change models answer
# the narrower short-run question and are kept as sensitivities because annual
# differences can magnify measurement error in slow-moving indicators.
secondary_df <- panel_df %>%
  mutate(
    oop_health_spend_pct_points = 100 * oop_share_health_spend,
    oop_share_health_spend_logit = if_else(
      oop_share_health_spend > 0 & oop_share_health_spend < 1,
      qlogis(oop_share_health_spend),
      NA_real_
    ),
    log_mds_per_thou = if_else(
      mds_per_thou > 0,
      log(mds_per_thou),
      NA_real_
    ),
    log_nurses_per_thou = if_else(
      nurses_per_thou > 0,
      log(nurses_per_thou),
      NA_real_
    ),
    log_treatable_mortality = if_else(
      treatable_mortality_per_100k > 0,
      log(treatable_mortality_per_100k),
      NA_real_
    )
  ) %>%
  group_by(code) %>%
  arrange(year, .by_group = TRUE) %>%
  mutate(
    valid_annual_comparison =
      year - lag(year) == 1L &
      !year %in% excluded_analysis_years &
      !lag(year) %in% excluded_analysis_years,
    change_log2_ratio_clean = if_else(
      valid_annual_comparison,
      log2_ratio - lag(log2_ratio),
      NA_real_
    ),
    lag_change_log2_ratio_clean_1 =
      lag(change_log2_ratio_clean, 1),
    lag_change_log2_ratio_clean_3 =
      lag(change_log2_ratio_clean, 3),
    lag_change_log2_ratio_clean_5 =
      lag(change_log2_ratio_clean, 5),
    change_oop_health_spend_pct_points = if_else(
      valid_annual_comparison,
      oop_health_spend_pct_points - lag(oop_health_spend_pct_points),
      NA_real_
    ),
    change_hosp_beds_per_thou = if_else(
      valid_annual_comparison,
      hosp_beds_per_thou - lag(hosp_beds_per_thou),
      NA_real_
    ),
    change_log_mds_per_thou = if_else(
      valid_annual_comparison,
      log_mds_per_thou - lag(log_mds_per_thou),
      NA_real_
    ),
    change_log_nurses_per_thou = if_else(
      valid_annual_comparison,
      log_nurses_per_thou - lag(log_nurses_per_thou),
      NA_real_
    ),
    change_log_treatable_mortality = if_else(
      valid_annual_comparison,
      log_treatable_mortality - lag(log_treatable_mortality),
      NA_real_
    )
  ) %>%
  ungroup() %>%
  filter(
    year <= analysis_end_year,
    !year %in% excluded_analysis_years
  )

secondary_specs <- tribble(
  ~outcome_var, ~change_outcome_var, ~raw_outcome_var, ~outcome_label,
  "oop_health_spend_pct_points", "change_oop_health_spend_pct_points",
  "oop_share_health_spend_logit",
  "Out-of-pocket share of health expenditure",
  "log_nurses_per_thou", "change_log_nurses_per_thou",
  "nurses_per_thou", "Nurses and midwives",
  "log_mds_per_thou", "change_log_mds_per_thou", "mds_per_thou",
  "Medical doctors",
  "hosp_beds_per_thou", "change_hosp_beds_per_thou", NA,
  "Hospital beds",
  "log_treatable_mortality", "change_log_treatable_mortality",
  "treatable_mortality_per_100k", "Treatable mortality"
)


# Decompose an exposure into within- and between-country components
add_within_between <- function(data, exposure_var) {
  exposure_mean_var <- paste0(exposure_var, "_country_mean")
  exposure_within_var <- paste0(exposure_var, "_within")
  exposure_between_var <- paste0(exposure_var, "_between")

  prepared <- data %>%
    group_by(code) %>%
    mutate(
      "{exposure_mean_var}" := mean(
        .data[[exposure_var]],
        na.rm = TRUE
      )
    ) %>%
    ungroup()

  grand_mean <- prepared %>%
    distinct(code, .data[[exposure_mean_var]]) %>%
    filter(is.finite(.data[[exposure_mean_var]])) %>%
    summarise(value = mean(.data[[exposure_mean_var]])) %>%
    pull(value)

  prepared %>%
    mutate(
      "{exposure_within_var}" :=
        .data[[exposure_var]] - .data[[exposure_mean_var]],
      "{exposure_between_var}" :=
        .data[[exposure_mean_var]] - grand_mean
    )
}

fit_secondary_sensitivity <- function(
    outcome_var,
    outcome_label,
    exposure_var,
    exposure_label,
    adjustment = "standard") {
  prepared <- add_within_between(
    secondary_df,
    exposure_var
  )

  within_var <- paste0(exposure_var, "_within")
  between_var <- paste0(exposure_var, "_between")
  adjustment_terms <- if (adjustment == "debt") {
    c(
      "system",
      "log2_gdp_percap_c",
      "previous_debt_10pp_c",
      "year_factor"
    )
  } else {
    c(
      "system",
      "log2_gdp_percap_c",
      "year_factor"
    )
  }

  formula <- reformulate(
    c(
      within_var,
      between_var,
      adjustment_terms,
      "(1 | country)"
    ),
    response = outcome_var
  )

  model_name <- paste(
    outcome_var,
    exposure_label,
    adjustment,
    sep = "__"
  )

  result <- fit_sensitivity_model(
    data = prepared,
    model_name = model_name,
    description = paste(outcome_label, "-", exposure_label),
    formula = formula,
    model_type = "lmer"
  )

  focal_coefficients <- result$coefficients %>%
    filter(term %in% c(within_var, between_var))

  # Retain prespecified models that cannot be estimated from sparse outcomes
  if (nrow(focal_coefficients) == 0) {
    focal_coefficients <- tibble(
      model = model_name,
      description = paste(outcome_label, "-", exposure_label),
      term = c(within_var, between_var),
      estimate = NA_real_,
      std_error = NA_real_,
      conf_low = NA_real_,
      conf_high = NA_real_,
      statistic = NA_real_,
      p_value = NA_real_
    )
  }

  focal_coefficients %>%
    mutate(
      outcome = outcome_label,
      outcome_variable = outcome_var,
      exposure = exposure_label,
      exposure_variable = exposure_var,
      component = if_else(
        term == within_var,
        "Within country",
        "Between country"
      ),
      adjustment,
      observations = result$overview$observations,
      countries = result$overview$countries,
      first_year = result$overview$first_year,
      last_year = result$overview$last_year,
      singular_fit = result$overview$singular_fit,
      status = result$overview$status
    )
}


# Lag the ratio by one, three, and five years
secondary_lag_results <- bind_rows(
  lapply(seq_len(nrow(secondary_specs)), function(i) {
    bind_rows(
      lapply(c(1, 3, 5), function(lag_years) {
        fit_secondary_sensitivity(
          outcome_var = secondary_specs$outcome_var[[i]],
          outcome_label = secondary_specs$outcome_label[[i]],
          exposure_var = paste0("lag_log2_ratio_", lag_years),
          exposure_label = paste0("ratio_lag_", lag_years, "_years")
        )
      })
    )
  })
)


# Test whether ratio changes are associated with outcome changes
secondary_ratio_change_results <- bind_rows(
  lapply(seq_len(nrow(secondary_specs)), function(i) {
    exposure_specs <- c(
      change_log2_ratio_clean = "ratio_change_current",
      lag_change_log2_ratio_clean_1 = "ratio_change_lag_1_year",
      lag_change_log2_ratio_clean_3 = "ratio_change_lag_3_years",
      lag_change_log2_ratio_clean_5 = "ratio_change_lag_5_years"
    )

    bind_rows(
      lapply(names(exposure_specs), function(exposure_var) {
        fit_secondary_sensitivity(
          outcome_var = secondary_specs$change_outcome_var[[i]],
          outcome_label = paste0(
            secondary_specs$outcome_label[[i]],
            " annual change"
          ),
          exposure_var = exposure_var,
          exposure_label = exposure_specs[[exposure_var]]
        )
      })
    )
  })
)


# Add lagged debt level to the primary log-ratio specification
secondary_debt_adjusted_results <- bind_rows(
  lapply(seq_len(nrow(secondary_specs)), function(i) {
    fit_secondary_sensitivity(
      outcome_var = secondary_specs$outcome_var[[i]],
      outcome_label = secondary_specs$outcome_label[[i]],
      exposure_var = "log2_ratio",
      exposure_label = "ratio_with_lagged_debt",
      adjustment = "debt"
    )
  })
)


# Use alternative raw or bounded-outcome transformations where relevant
secondary_alternative_outcome_results <- bind_rows(
  lapply(seq_len(nrow(secondary_specs)), function(i) {
    alternative_outcome <- secondary_specs$raw_outcome_var[[i]]

    if (is.na(alternative_outcome)) {
      return(NULL)
    }

    fit_secondary_sensitivity(
      outcome_var = alternative_outcome,
      outcome_label = paste(
        secondary_specs$outcome_label[[i]],
        "(alternative scale)"
      ),
      exposure_var = "log2_ratio",
      exposure_label = "ratio_alternative_outcome_scale"
    )
  })
)


# Model health and defence shares separately instead of using their ratio
component_df <- secondary_df %>%
  add_within_between("log2_health_share") %>%
  add_within_between("log2_defence_share")

secondary_component_results <- bind_rows(
  lapply(seq_len(nrow(secondary_specs)), function(i) {
    outcome_var <- secondary_specs$outcome_var[[i]]
    required_vars <- c(
      outcome_var,
      "log2_health_share_within",
      "log2_health_share_between",
      "log2_defence_share_within",
      "log2_defence_share_between",
      "system",
      "log2_gdp_percap_c",
      "year_factor",
      "country"
    )

    model_data <- component_df[
      complete.cases(component_df[required_vars]),
    ] %>%
      droplevels()

    formula <- as.formula(
      paste0(
        outcome_var,
        " ~ log2_health_share_within + log2_health_share_between + ",
        "log2_defence_share_within + log2_defence_share_between + ",
        "system + log2_gdp_percap_c + year_factor + (1 | country)"
      )
    )

    result <- fit_sensitivity_model(
      data = model_data,
      model_name = paste0(outcome_var, "__separate_spending_components"),
      description = paste(
        secondary_specs$outcome_label[[i]],
        "- separate health and defence shares"
      ),
      formula = formula,
      model_type = "lmer"
    )

    result$coefficients %>%
      filter(grepl("^log2_(health|defence)_share_", term)) %>%
      mutate(
        outcome = secondary_specs$outcome_label[[i]],
        outcome_variable = outcome_var,
        exposure = "Separate health and defence shares",
        component = case_when(
          grepl("health.*within", term) ~ "Health share within country",
          grepl("health.*between", term) ~ "Health share between country",
          grepl("defence.*within", term) ~ "Defence share within country",
          TRUE ~ "Defence share between country"
        ),
        adjustment = "standard"
      )
  })
)

secondary_sensitivity_results <- bind_rows(
  secondary_lag_results,
  secondary_ratio_change_results,
  secondary_debt_adjusted_results,
  secondary_alternative_outcome_results,
  secondary_component_results
) %>%
  mutate(
    across(
      c(estimate, std_error, conf_low, conf_high, statistic, p_value),
      ~ round(.x, 4)
    )
  )

if (nrow(main_sensitivity_overview) != 19) {
  stop("Expected 19 main sensitivity specifications.")
}

if (any(!main_sensitivity_overview$converged)) {
  stop("At least one main sensitivity model failed to converge.")
}

if (n_distinct(leave_one_country_out$omitted_code) != 30) {
  stop("Expected 30 leave-one-country-out analyses.")
}

if (nrow(secondary_sensitivity_results) != 108) {
  stop("Expected 108 secondary sensitivity coefficient rows.")
}


# Save all robustness results
write_csv(
  main_sensitivity_overview,
  file.path(results_dir, "main_sensitivity_overview.csv"),
  na = ""
)

write_csv(
  main_sensitivity_coefficients,
  file.path(results_dir, "main_sensitivity_coefficients.csv"),
  na = ""
)

write_csv(
  leave_one_country_out,
  file.path(results_dir, "main_leave_one_country_out.csv"),
  na = ""
)

write_csv(
  secondary_sensitivity_results,
  file.path(results_dir, "secondary_sensitivity_results.csv"),
  na = ""
)


# Save and print a concise execution summary
summary_lines <- c(
  "Health and Defence Spending Sensitivity Analyses",
  "================================================",
  "",
  sprintf(
    "Main sensitivity specifications fitted: %s.",
    nrow(main_sensitivity_overview)
  ),
  sprintf(
    "Specifications failing to converge: %s.",
    sum(!main_sensitivity_overview$converged)
  ),
  sprintf(
    "Singular mixed-model specifications: %s.",
    sum(main_sensitivity_overview$singular_fit, na.rm = TRUE)
  ),
  sprintf(
    "Leave-one-country-out models fitted: %s.",
    n_distinct(leave_one_country_out$omitted_code)
  ),
  sprintf(
    "Secondary sensitivity coefficient rows saved: %s.",
    nrow(secondary_sensitivity_results)
  ),
  "",
  "These analyses are robustness checks and do not establish causation."
)

writeLines(
  summary_lines,
  file.path(results_dir, "sensitivity_analysis_summary.txt")
)

cat(paste(summary_lines, collapse = "\n"))
cat("\n\nSensitivity outputs saved in the results/ folder.\n")
