#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# MAIN ANALYSIS OF HEALTH AND DEFENSE SPENDING TRADEOFF
# Harry Rourke & Ethan Phillips
# Last updated: 2026-07-09
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Load packages
suppressPackageStartupMessages({
  library(dplyr)
  library(lme4)
  library(readr)
  library(tidyr)
})


# Load processed data
master_df <- read_csv("processed_data/primary_analysis.csv", na = c(""), show_col_types = FALSE)

results_dir <- "results"
dir.create(results_dir, showWarnings = FALSE)


# Prepare variables
analysis_df <- master_df %>%
  mutate(
    country = factor(country),
    system = relevel(factor(system), ref = "BEV"),
    gdp_per_10k = gdp_percap / 10000
  )


# Fit linear mixed-effects models
fit_lmer_model <- function(model_name, outcome_label, formula, required_vars) {
  model_data <- analysis_df %>%
    filter(if_all(all_of(required_vars), ~ !is.na(.x)))

  model <- suppressMessages(suppressWarnings(lmer(
    formula,
    data = model_data,
    REML = FALSE,
    control = lmerControl(check.conv.singular = "ignore")
  )))

  list(
    model_name = model_name,
    outcome_label = outcome_label,
    model = model,
    data = model_data
  )
}

secondary_outcomes <- list(
  list(
    variable = "oop_pct",
    model_name = "out_of_pocket_model",
    outcome_label = "Out-of-pocket expenditure share"
  ),
  list(
    variable = "life_exp",
    model_name = "life_expectancy_model",
    outcome_label = "Life expectancy at birth"
  ),
  list(
    variable = "hosp_beds_per_thou",
    model_name = "hospital_beds_model",
    outcome_label = "Hospital beds per 1,000 people"
  ),
  list(
    variable = "mds_per_thou",
    model_name = "medical_doctors_model",
    outcome_label = "Medical doctors per 1,000 people"
  ),
  list(
    variable = "nurses_per_thou",
    model_name = "nurses_midwives_model",
    outcome_label = "Nurses and midwives per 1,000 people"
  ),
  list(
    variable = "uhc_idx",
    model_name = "uhc_service_coverage_model",
    outcome_label = "Universal health coverage service coverage index"
  )
)

main_model <- fit_lmer_model(
  model_name = "main_model",
  outcome_label = "Annual change in health spending as a share of GDP",
  formula = change_health_gdp ~ change_def_gdp * system + gdp_per_10k + (1 | country),
  required_vars = c("change_health_gdp", "change_def_gdp", "system", "gdp_per_10k", "country")
)

secondary_models <- lapply(secondary_outcomes, function(outcome) {
  fit_lmer_model(
    model_name = outcome$model_name,
    outcome_label = outcome$outcome_label,
    formula = as.formula(paste0(outcome$variable, " ~ health_def_ratio + gdp_per_10k + (1 | country)")),
    required_vars = c(outcome$variable, "health_def_ratio", "gdp_per_10k", "country")
  )
})

models <- c(
  list(main_model),
  secondary_models
)

model_order <- tibble(
  model = vapply(models, `[[`, character(1), "model_name"),
  model_order = seq_along(models)
)

secondary_model_overview <- tibble(
  model = vapply(secondary_outcomes, `[[`, character(1), "model_name"),
  outcome_variable = vapply(secondary_outcomes, `[[`, character(1), "variable"),
  explanatory_variable = "health_def_ratio",
  adjustment_variable = "gdp_per_10k",
  random_effect = "country"
)

# Create readable results tables
label_term <- function(term) {
  case_when(
    term == "(Intercept)" ~ "Intercept",
    term == "change_def" ~ "Change in defence spending share",
    term == "change_def_gdp" ~ "Change in defence spending as a share of GDP",
    term == "systemBIS" ~ "Bismarck-style health system",
    term == "gdp_per_10k" ~ "GDP per capita, per $10,000",
    term == "change_def:systemBIS" ~ "Defence spending change x Bismarck system",
    term == "change_def_gdp:systemBIS" ~ "Defence GDP-share change x Bismarck system",
    term == "health_def_ratio" ~ "Health-to-defence spending ratio",
    TRUE ~ term
  )
}

tidy_fixed_effects <- function(model_result) {
  coefficient_table <- as.data.frame(coef(summary(model_result$model)))
  coefficient_table$term <- rownames(coefficient_table)

  coefficient_table %>%
    as_tibble() %>%
    transmute(
      model = model_result$model_name,
      outcome = model_result$outcome_label,
      term,
      term_label = label_term(term),
      estimate = Estimate,
      std_error = `Std. Error`,
      conf_low = Estimate - 1.96 * `Std. Error`,
      conf_high = Estimate + 1.96 * `Std. Error`,
      t_value = `t value`
    ) %>%
    mutate(
      across(c(estimate, std_error, conf_low, conf_high, t_value), ~ round(.x, 4))
    )
}

summarise_model <- function(model_result) {
  model_data <- model_result$data

  tibble(
    model = model_result$model_name,
    outcome = model_result$outcome_label,
    observations = nobs(model_result$model),
    rows_excluded = nrow(analysis_df) - nobs(model_result$model),
    countries = n_distinct(model_data$country),
    first_year = min(model_data$year, na.rm = TRUE),
    last_year = max(model_data$year, na.rm = TRUE),
    aic = round(AIC(model_result$model), 2),
    bic = round(BIC(model_result$model), 2),
    residual_sd = round(sigma(model_result$model), 4),
    singular_fit = isSingular(model_result$model)
  )
}

tidy_random_effects <- function(model_result) {
  as.data.frame(VarCorr(model_result$model)) %>%
    as_tibble() %>%
    transmute(
      model = model_result$model_name,
      outcome = model_result$outcome_label,
      group = grp,
      term = var1,
      variance = round(vcov, 4),
      std_dev = round(sdcor, 4)
    )
}

model_overview <- bind_rows(lapply(models, summarise_model)) %>%
  left_join(model_order, by = "model") %>%
  arrange(model_order) %>%
  select(-model_order)

fixed_effects <- bind_rows(lapply(models, tidy_fixed_effects)) %>%
  left_join(model_order, by = "model") %>%
  arrange(model_order) %>%
  select(-model_order)

random_effects <- bind_rows(lapply(models, tidy_random_effects)) %>%
  left_join(model_order, by = "model") %>%
  arrange(model_order) %>%
  select(-model_order)


# Save machine-readable outputs
write_csv(model_overview, file.path(results_dir, "model_overview.csv"), na = "")
write_csv(fixed_effects, file.path(results_dir, "model_fixed_effects.csv"), na = "")
write_csv(random_effects, file.path(results_dir, "model_random_effects.csv"), na = "")
write_csv(secondary_model_overview, file.path(results_dir, "secondary_model_specs.csv"), na = "")


# Save a readable plain-text summary
format_fixed_effects <- function(model_result) {
  fixed_effects %>%
    filter(model == model_result$model_name) %>%
    mutate(
      line = sprintf(
        "  %-44s %10.4f  [%10.4f, %10.4f]",
        term_label,
        estimate,
        conf_low,
        conf_high
      )
    ) %>%
    pull(line)
}

summary_lines <- c(
  "Health and Defence Spending Analysis",
  "====================================",
  "",
  sprintf(
    "Processed dataset: %s rows, %s countries, years %s-%s.",
    nrow(analysis_df),
    n_distinct(analysis_df$country),
    min(analysis_df$year, na.rm = TRUE),
    max(analysis_df$year, na.rm = TRUE)
  ),
  "All models are linear mixed-effects models with random intercepts for country.",
  "GDP per capita is scaled so one unit equals $10,000.",
  "",
  "Model Results",
  "-------------"
)

for (model_result in models) {
  overview_row <- model_overview %>%
    filter(model == model_result$model_name)

  summary_lines <- c(
    summary_lines,
    "",
    sprintf("%s: %s", model_result$model_name, model_result$outcome_label),
    sprintf(
      "Observations: %s | Countries: %s | Years: %s-%s | AIC: %.2f | Residual SD: %.4f",
      overview_row$observations,
      overview_row$countries,
      overview_row$first_year,
      overview_row$last_year,
      overview_row$aic,
      overview_row$residual_sd
    ),
    sprintf(
      "Rows excluded for missing model variables: %s | Singular fit: %s",
      overview_row$rows_excluded,
      overview_row$singular_fit
    ),
    "Fixed effects: estimate [95% CI]",
    format_fixed_effects(model_result)
  )
}

writeLines(summary_lines, file.path(results_dir, "model_results_summary.txt"))


# Print the readable summary to the console
cat(paste(summary_lines, collapse = "\n"))
cat("\n\nResults saved in the results/ folder.\n")
