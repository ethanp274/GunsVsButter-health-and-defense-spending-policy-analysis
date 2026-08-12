#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# MAIN ANALYSIS OF HEALTH AND DEFENCE SPENDING
# Harry Rourke & Ethan Phillips
# Last updated: 2026-08-05
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# This script estimates associations rather than causal effects.

suppressPackageStartupMessages({
  library(broom)
  library(broom.mixed)
  library(dplyr)
  library(geepack)
  library(lme4)
  library(readr)
  library(tidyr)
})


# Load the processed country-year panel
master_df <- read_csv(
  "processed_data/primary_analysis.csv",
  na = "",
  show_col_types = FALSE
)

results_dir <- "results"
dir.create(results_dir, showWarnings = FALSE)
excluded_analysis_years <- c(2020L, 2021L)
analysis_end_year <- max(master_df$year, na.rm = TRUE)


# Prepare the primary sample and interpretable model scales
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

previous_debt_center <- mean(
  primary_df$previous_debt_10pp,
  na.rm = TRUE
)

gdp_center <- mean(
  primary_df$log2_gdp_percap,
  na.rm = TRUE
)

primary_df <- primary_df %>%
  mutate(
    previous_debt_10pp_c =
      previous_debt_10pp - previous_debt_center,
    log2_gdp_percap_c = log2_gdp_percap - gdp_center
  )

scaled_main_vars <- c(
  "health_change_percent",
  "defence_change_10pct",
  "previous_debt_10pp_c",
  "log2_gdp_percap_c"
)

has_infinite_main_value <- vapply(
  primary_df[scaled_main_vars],
  function(x) any(is.infinite(x)),
  logical(1)
)

if (any(has_infinite_main_value)) {
  stop("Main-analysis transformations produced infinite values.")
}


# Use one common sample so changes between model stages reflect adjustment only
main_required_vars <- c(
  "health_change_percent",
  "defence_change_10pct",
  "previous_debt_10pp_c",
  "log2_gdp_percap_c",
  "system",
  "country",
  "year_factor"
)

main_data <- primary_df[
  complete.cases(primary_df[main_required_vars]),
] %>%
  droplevels()

if (nrow(main_data) == 0 ||
    n_distinct(main_data$country) == 0 ||
    min(main_data$year) != 2000 ||
    max(main_data$year) != 2025 ||
    any(main_data$year %in% excluded_analysis_years)) {
  stop(
    paste(
      "The main-analysis sample must be non-empty, cover 2000-2025,",
      "and exclude 2020-2021."
    )
  )
}


# Fit five explicit main models
main_model_1 <- lm(
  health_change_percent ~ defence_change_10pct,
  data = main_data
)

main_model_2 <- lmer(
  health_change_percent ~ defence_change_10pct + (1 | country),
  data = main_data,
  REML = FALSE
)

main_model_3 <- lmer(
  health_change_percent ~
    defence_change_10pct * system +
    (1 | country),
  data = main_data,
  REML = FALSE
)

main_model_4 <- lmer(
  health_change_percent ~
    defence_change_10pct * system +
    defence_change_10pct * previous_debt_10pp_c +
    (1 | country),
  data = main_data,
  REML = FALSE
)

main_model_5 <- lmer(
  health_change_percent ~
    defence_change_10pct * system +
    defence_change_10pct * previous_debt_10pp_c +
    log2_gdp_percap_c +
    year_factor +
    (1 | country),
  data = main_data,
  REML = FALSE
)

main_model_6_population_average_gee <- geepack::geeglm(
  health_change_percent ~
    defence_change_10pct * system +
    defence_change_10pct * previous_debt_10pp_c +
    log2_gdp_percap_c +
    year_factor,
  data = main_data %>% arrange(country, year),
  id = country,
  waves = year,
  family = gaussian(link = "identity"),
  corstr = "ar1",
  std.err = "san.se"
)

main_models <- list(
  model_1_unadjusted = main_model_1,
  model_2_country_random_intercept = main_model_2,
  model_3_system_moderation = main_model_3,
  model_4_debt_moderation = main_model_4,
  model_5_fully_adjusted = main_model_5,
  model_6_population_average_gee = main_model_6_population_average_gee
)

main_model_descriptions <- c(
  model_1_unadjusted =
    "Pooled unadjusted association",
  model_2_country_random_intercept =
    "Country random intercept",
  model_3_system_moderation =
    "Country random intercept and health-system moderation",
  model_4_debt_moderation =
    "Health-system and public-debt moderation",
  model_5_fully_adjusted =
    "Fully adjusted with GDP per capita and year effects",
  model_6_population_average_gee =
    "Final population-average GEE with country clusters and AR(1) working correlation"
)


# Helpers create consistent, readable result tables
model_converged <- function(model) {
  if (inherits(model, "geeglm")) {
    return(model$geese$error == 0)
  }

  if (!inherits(model, "merMod")) {
    return(TRUE)
  }

  optimizer_code <- model@optinfo$conv$opt
  is.null(optimizer_code) || all(optimizer_code == 0)
}

country_variance <- function(model) {
  if (!inherits(model, "merMod")) {
    return(NA_real_)
  }

  variance_table <- as.data.frame(VarCorr(model))
  country_row <- variance_table %>%
    filter(grp == "country", var1 == "(Intercept)")

  if (nrow(country_row) == 0) {
    return(NA_real_)
  }

  country_row$vcov[[1]]
}

summarise_model <- function(model, model_name, description, model_data) {
  model_object <- model

  tibble(
    model = model_name,
    description,
    model_type = case_when(
      inherits(model_object, "merMod") ~ "Linear mixed model",
      inherits(model_object, "geeglm") ~ "Population-average GEE",
      TRUE ~ "Pooled linear model"
    ),
    observations = nobs(model_object),
    countries = n_distinct(model_data$country),
    first_year = min(model_data$year),
    last_year = max(model_data$year),
    aic = if (inherits(model_object, "geeglm")) {
      NA_real_
    } else {
      AIC(model_object)
    },
    bic = if (inherits(model_object, "geeglm")) {
      NA_real_
    } else {
      BIC(model_object)
    },
    residual_sd = if (inherits(model_object, "geeglm")) {
      NA_real_
    } else {
      sigma(model_object)
    },
    country_variance = country_variance(model_object),
    converged = model_converged(model_object),
    singular_fit = if (inherits(model_object, "merMod")) {
      isSingular(model_object)
    } else {
      NA
    }
  )
}

label_term <- function(term) {
  case_when(
    term == "(Intercept)" ~ "Intercept",
    term == "defence_change_10pct" ~
      "Defence change, per 10% relative increase",
    term == "systemBIS" ~ "Bismarck-style health system",
    term == "previous_debt_10pp_c" ~
      "Previous-year public debt, per 10 percentage points of GDP",
    term == "log2_gdp_percap_c" ~
      "GDP per capita, per doubling",
    term == "defence_change_10pct:systemBIS" ~
      "Defence change x Bismarck system",
    term == "defence_change_10pct:previous_debt_10pp_c" ~
      "Defence change x previous-year public debt",
    term == "ratio_within" ~
      "Within-country log2 health-to-defence ratio",
    term == "ratio_between" ~
      "Between-country mean log2 health-to-defence ratio",
    grepl("^year_factor", term) ~
      paste("Year", sub("^year_factor", "", term)),
    TRUE ~ term
  )
}

tidy_model <- function(model, model_name, description) {
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
      term_label = label_term(term),
      estimate,
      std_error = std.error,
      conf_low = conf.low,
      conf_high = conf.high,
      statistic,
      p_value = if ("p.value" %in% names(result)) p.value else NA_real_
    )
}


# Summarise the five main models
main_model_overview <- bind_rows(
  lapply(names(main_models), function(model_name) {
    summarise_model(
      model = main_models[[model_name]],
      model_name = model_name,
      description = main_model_descriptions[[model_name]],
      model_data = main_data
    )
  })
) %>%
  mutate(
    across(
      c(aic, bic, residual_sd, country_variance),
      ~ round(.x, 4)
    )
  )

main_model_coefficients <- bind_rows(
  lapply(names(main_models), function(model_name) {
    tidy_model(
      model = main_models[[model_name]],
      model_name = model_name,
      description = main_model_descriptions[[model_name]]
    )
  })
) %>%
  mutate(
    across(
      c(estimate, std_error, conf_low, conf_high, statistic, p_value),
      ~ round(.x, 4)
    )
  )

if (any(!main_model_overview$converged)) {
  stop("At least one main model failed to converge.")
}


# Translate the two interactions into conditional defence slopes
debt_percentiles <- quantile(
  main_data$previous_debt_10pp,
  probs = c(0.25, 0.50, 0.75),
  na.rm = TRUE
)

interaction_grid <- bind_rows(
  lapply(seq_along(debt_percentiles), function(i) {
    tibble(
      system = c("BEV", "BIS"),
      debt_percentile = names(debt_percentiles)[[i]],
      previous_debt_10pp = as.numeric(debt_percentiles[[i]])
    )
  })
)

fixed_estimates <- fixef(main_model_5)
fixed_covariance <- as.matrix(vcov(main_model_5))

calculate_defence_slope <- function(system_value, debt_value) {
  weights <- setNames(
    rep(0, length(fixed_estimates)),
    names(fixed_estimates)
  )

  weights[["defence_change_10pct"]] <- 1

  if (system_value == "BIS") {
    weights[["defence_change_10pct:systemBIS"]] <- 1
  }

  weights[["defence_change_10pct:previous_debt_10pp_c"]] <-
    debt_value - previous_debt_center

  estimate <- sum(weights * fixed_estimates)
  std_error <- sqrt(
    as.numeric(t(weights) %*% fixed_covariance %*% weights)
  )

  tibble(
    estimate,
    std_error,
    conf_low = estimate - 1.96 * std_error,
    conf_high = estimate + 1.96 * std_error
  )
}

main_interaction_slopes <- interaction_grid %>%
  rowwise() %>%
  mutate(
    slope = list(
      calculate_defence_slope(system, previous_debt_10pp)
    )
  ) %>%
  unnest(slope) %>%
  ungroup() %>%
  transmute(
    system,
    debt_percentile,
    previous_debt_pct_gdp = round(10 * previous_debt_10pp, 2),
    estimate = round(estimate, 4),
    std_error = round(std_error, 4),
    conf_low = round(conf_low, 4),
    conf_high = round(conf_high, 4),
    interpretation =
      "Percentage-point relative health-spending change per 10% relative defence increase"
  )


# Prepare outcome levels for the secondary analyses
#
# The primary secondary estimand relates a country's spending balance to its
# outcome level. Annual outcome changes are tested separately as sensitivities
# because differencing slow-moving indicators can amplify measurement noise.
secondary_df <- primary_df %>%
  filter(!is.na(health_def_ratio), health_def_ratio > 0) %>%
  mutate(
    log2_ratio = log2(health_def_ratio),
    oop_health_spend_pct_points = 100 * oop_share_health_spend,
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
  mutate(ratio_country_mean = mean(log2_ratio, na.rm = TRUE)) %>%
  ungroup()

ratio_grand_mean <- secondary_df %>%
  distinct(code, ratio_country_mean) %>%
  summarise(value = mean(ratio_country_mean)) %>%
  pull(value)

secondary_df <- secondary_df %>%
  mutate(
    ratio_within = log2_ratio - ratio_country_mean,
    ratio_between = ratio_country_mean - ratio_grand_mean
  )

transformed_secondary_vars <- c(
  "log2_ratio",
  "ratio_within",
  "ratio_between",
  "log_mds_per_thou",
  "log_nurses_per_thou",
  "log_treatable_mortality"
)

has_infinite_secondary_value <- vapply(
  secondary_df[transformed_secondary_vars],
  function(x) any(is.infinite(x)),
  logical(1)
)

if (any(has_infinite_secondary_value)) {
  stop("Secondary-analysis transformations produced infinite values.")
}

secondary_specs <- tribble(
  ~outcome_var, ~model_name, ~outcome_label, ~outcome_scale,
  "oop_health_spend_pct_points", "out_of_pocket_model",
  "Out-of-pocket share of health expenditure",
  "Percentage points of current health expenditure",
  "log_nurses_per_thou", "nurses_midwives_model",
  "Nurses and midwives", "Log outcome",
  "log_mds_per_thou", "medical_doctors_model",
  "Medical doctors", "Log outcome",
  "hosp_beds_per_thou", "hospital_beds_model",
  "Hospital beds", "Beds per 1,000 people",
  "log_treatable_mortality", "treatable_mortality_model",
  "Treatable mortality", "Log outcome"
)


# Fit one consistent model to each secondary outcome
fit_secondary_model <- function(outcome_var, model_name, outcome_label) {
  required_vars <- c(
    outcome_var,
    "ratio_within",
    "ratio_between",
    "system",
    "log2_gdp_percap_c",
    "year_factor",
    "country"
  )

  model_data <- secondary_df[
    complete.cases(secondary_df[required_vars]),
  ] %>%
    droplevels()

  formula <- as.formula(
    paste0(
      outcome_var,
      " ~ ratio_within + ratio_between + system + ",
      "log2_gdp_percap_c + year_factor + (1 | country)"
    )
  )

  model <- lmer(
    formula,
    data = model_data,
    REML = FALSE
  )

  list(
    model_name = model_name,
    outcome_label = outcome_label,
    model = model,
    data = model_data
  )
}

secondary_models <- lapply(
  seq_len(nrow(secondary_specs)),
  function(i) {
    fit_secondary_model(
      outcome_var = secondary_specs$outcome_var[[i]],
      model_name = secondary_specs$model_name[[i]],
      outcome_label = secondary_specs$outcome_label[[i]]
    )
  }
)

names(secondary_models) <- secondary_specs$model_name

secondary_model_overview <- bind_rows(
  lapply(seq_along(secondary_models), function(i) {
    result <- secondary_models[[i]]

    summarise_model(
      model = result$model,
      model_name = result$model_name,
      description = result$outcome_label,
      model_data = result$data
    ) %>%
      mutate(
        outcome = result$outcome_label,
        outcome_scale = secondary_specs$outcome_scale[[i]]
      )
  })
) %>%
  mutate(
    across(
      c(aic, bic, residual_sd, country_variance),
      ~ round(.x, 4)
    )
  )

secondary_model_coefficients <- bind_rows(
  lapply(seq_along(secondary_models), function(i) {
    result <- secondary_models[[i]]

    tidy_model(
      model = result$model,
      model_name = result$model_name,
      description = result$outcome_label
    ) %>%
      mutate(
        outcome = result$outcome_label,
        outcome_scale = secondary_specs$outcome_scale[[i]],
        effect_for_ratio_doubling = case_when(
          outcome_scale == "Log outcome" &
            term %in% c("ratio_within", "ratio_between") ~
            100 * (exp(estimate) - 1),
          term %in% c("ratio_within", "ratio_between") ~
            estimate,
          TRUE ~ NA_real_
        ),
        effect_conf_low = case_when(
          outcome_scale == "Log outcome" &
            term %in% c("ratio_within", "ratio_between") ~
            100 * (exp(conf_low) - 1),
          term %in% c("ratio_within", "ratio_between") ~
            conf_low,
          TRUE ~ NA_real_
        ),
        effect_conf_high = case_when(
          outcome_scale == "Log outcome" &
            term %in% c("ratio_within", "ratio_between") ~
            100 * (exp(conf_high) - 1),
          term %in% c("ratio_within", "ratio_between") ~
            conf_high,
          TRUE ~ NA_real_
        ),
        effect_unit = case_when(
          outcome_scale == "Log outcome" &
            term %in% c("ratio_within", "ratio_between") ~
            "Percent outcome change per doubling of the ratio",
          term %in% c("ratio_within", "ratio_between") ~
            paste(outcome_scale, "per doubling of the ratio"),
          TRUE ~ NA_character_
        )
      )
  })
) %>%
  mutate(
    across(
      c(
        estimate,
        std_error,
        conf_low,
        conf_high,
        statistic,
        p_value,
        effect_for_ratio_doubling,
        effect_conf_low,
        effect_conf_high
      ),
      ~ round(.x, 4)
    )
  )

if (any(!secondary_model_overview$converged)) {
  stop("At least one secondary model failed to converge.")
}


# Record how observations enter each stage
analysis_sample_flow <- bind_rows(
  tibble(
    stage = "Processed panel",
    rows = nrow(master_df),
    countries = n_distinct(master_df$code),
    first_year = min(master_df$year),
    last_year = max(master_df$year)
  ),
  tibble(
    stage = paste(
      "Primary countries through",
      analysis_end_year,
      "excluding 2020-2021"
    ),
    rows = nrow(primary_df),
    countries = n_distinct(primary_df$code),
    first_year = min(primary_df$year),
    last_year = max(primary_df$year)
  ),
  tibble(
    stage = "Common main-model sample",
    rows = nrow(main_data),
    countries = n_distinct(main_data$code),
    first_year = min(main_data$year),
    last_year = max(main_data$year)
  )
)

# Report the country-level contribution to the common complete-case sample.
# Include countries with zero observations so the table covers the full
# authoritative study-country list.
country_sample_counts <- primary_df %>%
  count(country, code, system, name = "panel_observations") %>%
  left_join(
    main_data %>%
      group_by(country, code, system) %>%
      summarise(
        included_observations = n(),
        included_years = paste(sort(year), collapse = ", "),
        .groups = "drop"
      ),
    by = c("country", "code", "system")
  ) %>%
  mutate(
    included_observations = coalesce(included_observations, 0L),
    excluded_observations = panel_observations - included_observations,
    included_years = replace_na(included_years, "")
  ) %>%
  arrange(code)

if (sum(country_sample_counts$included_observations) != nrow(main_data)) {
  stop("Country-level included observations do not sum to the main sample.")
}

# Build Table 1 from the primary-analysis panel. Values are country-year
# descriptive statistics, stratified by health-system type and pooled overall.
table1_specs <- tribble(
  ~variable, ~label, ~unit, ~scale, ~digits,
  "health_pct_gdp", "Government health spending", "% GDP", 100, 2,
  "defence_pct_gdp", "Defence spending", "% GDP", 100, 2,
  "gdp_percap", "GDP per capita", "PPP US$ per person", 1, 0,
  "government_debt_pct_gdp", "Government debt", "% GDP", 100, 2,
  "previous_government_debt_pct_gdp", "Previous-year government debt", "% GDP", 100, 2,
  "change_health_gdp", "Annual health-spending change", "% relative change", 100, 2,
  "change_def_gdp", "Annual defence-spending change", "% relative change", 100, 2,
  "health_def_ratio", "Health-to-defence spending ratio", "ratio", 1, 2,
  "oop_share_health_spend", "Out-of-pocket spending", "% current health expenditure", 100, 2,
  "nurses_per_thou", "Nurses and midwives", "per 1,000 people", 1, 2,
  "mds_per_thou", "Physicians", "per 1,000 people", 1, 2,
  "hosp_beds_per_thou", "Hospital beds", "per 1,000 people", 1, 2,
  "treatable_mortality_per_100k", "Treatable mortality", "per 100,000 people", 1, 1
)

table1_groups <- list(
  BIS = primary_df %>% filter(system == "BIS"),
  BEV = primary_df %>% filter(system == "BEV"),
  Total = primary_df
)

table1_descriptive_statistics <- bind_rows(
  lapply(names(table1_groups), function(group_name) {
    group_data <- table1_groups[[group_name]]

    bind_rows(
      lapply(seq_len(nrow(table1_specs)), function(i) {
        specification <- table1_specs[i, ]
        values <- group_data[[specification$variable]]
        values <- values[!is.na(values)]

        tibble(
          variable = specification$variable,
          label = specification$label,
          unit = specification$unit,
          group = group_name,
          nonmissing_n = length(values),
          mean = if (length(values) > 0) {
            mean(values) * specification$scale
          } else {
            NA_real_
          },
          sd = if (length(values) > 1) {
            sd(values) * specification$scale
          } else {
            NA_real_
          },
          digits = specification$digits
        )
      })
    )
  })
)

write_csv(
  table1_descriptive_statistics,
  file.path(results_dir, "table1_descriptive_statistics.csv"),
  na = ""
)


# Save machine-readable outputs
write_csv(
  analysis_sample_flow,
  file.path(results_dir, "analysis_sample_flow.csv"),
  na = ""
)

write_csv(
  country_sample_counts,
  file.path(results_dir, "main_country_sample_counts.csv"),
  na = ""
)

write_csv(
  main_model_overview,
  file.path(results_dir, "main_model_overview.csv"),
  na = ""
)

write_csv(
  main_model_coefficients,
  file.path(results_dir, "main_model_coefficients.csv"),
  na = ""
)

write_csv(
  main_interaction_slopes,
  file.path(results_dir, "main_interaction_slopes.csv"),
  na = ""
)

write_csv(
  secondary_model_overview,
  file.path(results_dir, "secondary_model_overview.csv"),
  na = ""
)

write_csv(
  secondary_model_coefficients,
  file.path(results_dir, "secondary_model_coefficients.csv"),
  na = ""
)


# Save a concise summary for readers who do not need every coefficient
headline_terms <- main_model_coefficients %>%
  filter(
    model == "model_5_fully_adjusted",
    term %in% c(
      "defence_change_10pct",
      "defence_change_10pct:systemBIS",
      "previous_debt_10pp_c",
      "defence_change_10pct:previous_debt_10pp_c",
      "log2_gdp_percap_c"
    )
  )

summary_lines <- c(
  "Health and Defence Spending Analysis",
  "====================================",
  "",
  "These models estimate associations and do not establish causation.",
  sprintf(
    "Primary sample: %s observations from %s countries, %s-%s.",
    nrow(main_data),
    n_distinct(main_data$country),
    min(main_data$year),
    max(main_data$year)
  ),
  "Iceland is absent from the authoritative study-country source; Luxembourg is included in all analyses.",
  "COVID years 2020 and 2021 are excluded from the primary analysis; they are retained in the processed panel for the explicit main-model sensitivity.",
  "The main models also omit 2022 because its previous-year debt value is from excluded 2021.",
  "The headline model includes country random intercepts and categorical year effects.",
  sprintf(
    "Headline random-intercept variance: %.6f | Singular fit: %s",
    country_variance(main_model_5),
    isSingular(main_model_5)
  ),
  "",
  "Headline fixed effects: estimate [95% CI]",
  paste0(
    "  ",
    headline_terms$term_label,
    ": ",
    sprintf("%.4f", headline_terms$estimate),
    " [",
    sprintf("%.4f", headline_terms$conf_low),
    ", ",
    sprintf("%.4f", headline_terms$conf_high),
    "]"
  ),
  "",
  "Secondary models",
  "----------------",
  "The within-country ratio coefficient is the longitudinal association.",
  "Log outcomes are reported in the CSV as percent change per doubling of the ratio.",
  paste0(
    "  ",
    secondary_model_overview$outcome,
    ": ",
    secondary_model_overview$observations,
    " observations, ",
    secondary_model_overview$countries,
    " countries, ",
    secondary_model_overview$first_year,
    "-",
    secondary_model_overview$last_year,
    ", singular fit: ",
    secondary_model_overview$singular_fit
  )
)

writeLines(
  summary_lines,
  file.path(results_dir, "analysis_summary.txt")
)


# Print the same concise summary to the console
cat(paste(summary_lines, collapse = "\n"))
cat("\n\nMain analysis outputs saved in the results/ folder.\n")
