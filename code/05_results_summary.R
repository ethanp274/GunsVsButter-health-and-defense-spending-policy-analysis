#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# GENERATE A MARKDOWN SUMMARY OF ANALYSIS RESULTS
# Harry Rourke & Ethan Phillips
# Last updated: 2026-08-13
# Summary reflects the five-stage headline model sequence and the robustness checks
# used for the current, final analysis design as of this date
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Run stages 02, 03, and 04 before this script so their outputs are current.

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(tidyr)
})

results_dir <- "results"
tables_dir <- file.path(results_dir, "tables")
sensitivities_dir <- file.path(results_dir, "sensitivities")
figures_dir <- file.path(results_dir, "figures")
output_file <- file.path(results_dir, "results_summary.md")
html_output_file <- file.path(results_dir, "results_summary.html")


# Check that every required result and figure is available before writing the
# Markdown report. This prevents the summary from silently drifting away from the
# current pipeline outputs or a missing figure.
required_files <- c(
  file.path("tables", c(
    "analysis_sample_flow.csv",
    "main_country_sample_counts.csv",
    "table1_descriptive_statistics.csv",
    "main_model_overview.csv",
    "main_model_coefficients.csv",
    "main_interaction_slopes.csv",
    "secondary_model_overview.csv",
    "secondary_model_coefficients.csv"
  )),
  file.path("sensitivities", c(
    "main_sensitivity_overview.csv",
    "main_sensitivity_coefficients.csv",
    "main_leave_one_country_out.csv",
    "secondary_sensitivity_results.csv"
  )),
  file.path("figures", c(
    "health_def_ratio_timeseries.png",
    "system_avg_spending_pct_gdp_timeseries.png",
    "main_model_forest_plot.png",
    "main_interaction_slopes_plot.png"
  ))
)

missing_files <- required_files[
  !file.exists(file.path(results_dir, required_files))
]

if (length(missing_files) > 0) {
  stop(
    "Run stages 02, 03, and 04 first. Missing outputs: ",
    paste(missing_files, collapse = ", ")
  )
}


# Load the machine-readable results so the report is assembled from the saved
# outputs rather than manual retyping of coefficients or samples.
sample_flow <- read_csv(
  file.path(tables_dir, "analysis_sample_flow.csv"),
  show_col_types = FALSE
)

country_sample_counts <- read_csv(
  file.path(tables_dir, "main_country_sample_counts.csv"),
  show_col_types = FALSE
)

table1_descriptive_statistics <- read_csv(
  file.path(tables_dir, "table1_descriptive_statistics.csv"),
  show_col_types = FALSE
)

main_overview <- read_csv(
  file.path(tables_dir, "main_model_overview.csv"),
  show_col_types = FALSE
)

main_coefficients <- read_csv(
  file.path(tables_dir, "main_model_coefficients.csv"),
  show_col_types = FALSE
)

interaction_slopes <- read_csv(
  file.path(tables_dir, "main_interaction_slopes.csv"),
  show_col_types = FALSE
)

secondary_overview <- read_csv(
  file.path(tables_dir, "secondary_model_overview.csv"),
  show_col_types = FALSE
)

secondary_coefficients <- read_csv(
  file.path(tables_dir, "secondary_model_coefficients.csv"),
  show_col_types = FALSE
)

main_sensitivity_overview <- read_csv(
  file.path(sensitivities_dir, "main_sensitivity_overview.csv"),
  show_col_types = FALSE
)

main_sensitivity_coefficients <- read_csv(
  file.path(sensitivities_dir, "main_sensitivity_coefficients.csv"),
  show_col_types = FALSE
)

leave_one_country_out <- read_csv(
  file.path(sensitivities_dir, "main_leave_one_country_out.csv"),
  show_col_types = FALSE
)

secondary_sensitivity <- read_csv(
  file.path(sensitivities_dir, "secondary_sensitivity_results.csv"),
  show_col_types = FALSE
)


# Small helpers keep the Markdown output clean and consistent.
format_number <- function(x, digits = 3) {
  ifelse(
    is.na(x),
    "",
    formatC(x, digits = digits, format = "f")
  )
}

format_estimate_ci <- function(
    estimate,
    conf_low,
    conf_high,
    digits = 3) {
  ifelse(
    is.na(estimate),
    "",
    paste0(
      format_number(estimate, digits),
      " [",
      format_number(conf_low, digits),
      ", ",
      format_number(conf_high, digits),
      "]"
    )
  )
}

escape_markdown <- function(x) {
  x <- ifelse(is.na(x), "", as.character(x))
  gsub("\\|", "\\\\|", x)
}

markdown_table <- function(data) {
  data <- as.data.frame(data, stringsAsFactors = FALSE)
  data[] <- lapply(data, escape_markdown)

  header <- paste0(
    "| ",
    paste(names(data), collapse = " | "),
    " |"
  )

  divider <- paste0(
    "| ",
    paste(rep("---", ncol(data)), collapse = " | "),
    " |"
  )

  rows <- apply(
    data,
    1,
    function(row) {
      paste0("| ", paste(row, collapse = " | "), " |")
    }
  )

  c(header, divider, rows)
}

get_main_term <- function(term_name) {
  row <- main_coefficients %>%
    filter(
      model == "model_5_fully_adjusted",
      term == term_name
    )

  if (nrow(row) != 1) {
    return("not available")
  }

  format_estimate_ci(
    row$estimate,
    row$conf_low,
    row$conf_high
  )
}


# Describe each staged main model with its compact equation.
main_equations <- tibble(
  model = c(
    "model_1_unadjusted",
    "model_2_country_random_intercept",
    "model_3_system_moderation",
    "model_4_debt_moderation",
    "model_5_fully_adjusted"
  ),
  equation = c(
    "$\\Delta H_{it}=\\beta_0+\\beta_1\\Delta D_{it}+\\epsilon_{it}$",
    "$\\Delta H_{it}=\\beta_0+\\beta_1\\Delta D_{it}+u_i+\\epsilon_{it}$",
    "$\\Delta H_{it}=\\beta_0+\\beta_1\\Delta D_{it}+\\beta_2S_i+\\beta_3(\\Delta D_{it}\\times S_i)+u_i+\\epsilon_{it}$",
    "$\\Delta H_{it}=\\beta_0+\\beta_1\\Delta D_{it}+\\beta_2S_i+\\beta_3(\\Delta D_{it}\\times S_i)+\\beta_4B_{i,t-1}+\\beta_5(\\Delta D_{it}\\times B_{i,t-1})+u_i+\\epsilon_{it}$",
    "$\\Delta H_{it}=\\beta_0+\\beta_1\\Delta D_{it}+\\beta_2S_i+\\beta_3(\\Delta D_{it}\\times S_i)+\\beta_4B_{i,t-1}+\\beta_5(\\Delta D_{it}\\times B_{i,t-1})+\\beta_6\\log_2(GDPpc_{it})+\\gamma_t+u_i+\\epsilon_{it}$"
  )
)

main_model_table <- main_overview %>%
  left_join(main_equations, by = "model") %>%
  transmute(
    Model = description,
    Equation = equation,
    N = observations,
    Countries = countries,
    Years = paste0(first_year, "-", last_year),
    `Singular fit` = singular_fit
  )


# Show focal coefficients without filling the report with year dummies
main_focal_terms <- c(
  "defence_change_10pct",
  "systemBIS",
  "previous_debt_10pp_c",
  "log2_gdp_percap_c",
  "defence_change_10pct:systemBIS",
  "defence_change_10pct:previous_debt_10pp_c"
)

main_coefficient_table <- main_coefficients %>%
  filter(term %in% main_focal_terms) %>%
  mutate(
    result = format_estimate_ci(
      estimate,
      conf_low,
      conf_high
    )
  ) %>%
  select(model, term_label, result) %>%
  pivot_wider(
    names_from = model,
    values_from = result
  ) %>%
  rename(Term = term_label)

main_slope_table <- interaction_slopes %>%
  transmute(
    System = system,
    `Debt-level percentile` = debt_percentile,
    `Previous-year debt (% GDP)` =
      format_number(previous_debt_pct_gdp, 2),
    `Defence slope [95% CI]` = format_estimate_ci(
      estimate,
      conf_low,
      conf_high
    )
  )


# Summarise within- and between-country secondary associations
secondary_ratio_effects <- secondary_coefficients %>%
  filter(term %in% c("ratio_within", "ratio_between")) %>%
  mutate(
    reported_estimate = if_else(
      !is.na(effect_for_ratio_doubling),
      effect_for_ratio_doubling,
      estimate
    ),
    reported_low = if_else(
      !is.na(effect_conf_low),
      effect_conf_low,
      conf_low
    ),
    reported_high = if_else(
      !is.na(effect_conf_high),
      effect_conf_high,
      conf_high
    ),
    component = if_else(
      term == "ratio_within",
      "Within-country",
      "Between-country"
    ),
    result = format_estimate_ci(
      reported_estimate,
      reported_low,
      reported_high
    )
  ) %>%
  select(model, outcome, outcome_scale, component, result) %>%
  pivot_wider(
    names_from = component,
    values_from = result
  )

secondary_result_table <- secondary_overview %>%
  select(
    model,
    outcome,
    outcome_scale,
    observations,
    countries,
    first_year,
    last_year
  ) %>%
  left_join(
    secondary_ratio_effects,
    by = c("model", "outcome", "outcome_scale")
  ) %>%
  transmute(
    Outcome = outcome,
    Scale = outcome_scale,
    N = observations,
    Countries = countries,
    Years = paste0(first_year, "-", last_year),
    `Within-country effect [95% CI]` = `Within-country`,
    `Between-country effect [95% CI]` = `Between-country`
  )


# Pull the focal exposure estimates from selected main sensitivities, showing
# both the defence-effect main term and the system interaction.
sensitivity_term_map <- tribble(
  ~model, ~main_term, ~interaction_term,
  "lag_1_year", "lag_defence_1_10pct", "lag_defence_1_10pct:systemBIS",
  "lag_2_years", "lag_defence_2_10pct", "lag_defence_2_10pct:systemBIS",
  "lag_3_years", "lag_defence_3_10pct", "lag_defence_3_10pct:systemBIS",
  "cumulative_3_year_change", "defence_change_3yr_10pct", "defence_change_3yr_10pct:systemBIS",
  "country_fixed_effects", "defence_change_10pct", "defence_change_10pct:systemBIS",
  "gls_ar1", "defence_change_10pct", "defence_change_10pct:systemBIS",
  "gee_ar1", "defence_change_10pct", "defence_change_10pct:systemBIS",
  "absolute_percentage_point_changes", "defence_change_pp", "defence_change_pp:systemBIS",
  "nato_members_only", "defence_change_10pct", "defence_change_10pct:systemBIS",
  "oecd_members_only", "defence_change_10pct", "defence_change_10pct:systemBIS",
  "exclude_greece", "defence_change_10pct", "defence_change_10pct:systemBIS",
  "include_covid_years", "defence_change_10pct", "defence_change_10pct:systemBIS",
  "exclude_2025", "defence_change_10pct", "defence_change_10pct:systemBIS",
  "exclude_financial_crisis", "defence_change_10pct", "defence_change_10pct:systemBIS",
  "winsorised_changes", "defence_change_10pct", "defence_change_10pct:systemBIS"
)

notable_sensitivity_table <- sensitivity_term_map %>%
  left_join(
    main_sensitivity_overview %>%
      select(
        model,
        description,
        observations,
        countries,
        singular_fit
      ),
    by = "model"
  ) %>%
  left_join(
    main_sensitivity_coefficients %>%
      select(
        model,
        term,
        estimate,
        conf_low,
        conf_high
      ) %>%
      rename(
        main_estimate = estimate,
        main_conf_low = conf_low,
        main_conf_high = conf_high
      ),
    by = c("model" = "model", "main_term" = "term")
  ) %>%
  left_join(
    main_sensitivity_coefficients %>%
      select(
        model,
        term,
        estimate,
        conf_low,
        conf_high
      ) %>%
      rename(
        interaction_estimate = estimate,
        interaction_conf_low = conf_low,
        interaction_conf_high = conf_high
      ),
    by = c("model" = "model", "interaction_term" = "term")
  ) %>%
  transmute(
    Sensitivity = description,
    N = observations,
    Countries = countries,
    `Defence effect [95% CI]` = format_estimate_ci(
      main_estimate,
      main_conf_low,
      main_conf_high
    ),
    `Defence x BIS interaction [95% CI]` = format_estimate_ci(
      interaction_estimate,
      interaction_conf_low,
      interaction_conf_high
    ),
    `Singular fit` = singular_fit
  )

lagged_main_table <- notable_sensitivity_table %>%
  slice_head(n = 3)

other_notable_sensitivity_table <- notable_sensitivity_table %>%
  slice(-(1:3))

leave_one_out_summary <- leave_one_country_out %>%
  filter(term == "defence_change_10pct") %>%
  summarise(
    minimum = min(estimate, na.rm = TRUE),
    maximum = max(estimate, na.rm = TRUE),
    minimum_low = min(conf_low, na.rm = TRUE),
    maximum_high = max(conf_high, na.rm = TRUE)
  )


# Condense secondary lag sensitivities to the longitudinal coefficient
secondary_lag_table <- secondary_sensitivity %>%
  filter(
    component == "Within country",
    exposure %in% c(
      "ratio_lag_1_years",
      "ratio_lag_3_years",
      "ratio_lag_5_years"
    )
  ) %>%
  mutate(
    result = format_estimate_ci(
      estimate,
      conf_low,
      conf_high
    ),
    lag = recode(
      exposure,
      ratio_lag_1_years = "1-year lag",
      ratio_lag_3_years = "3-year lag",
      ratio_lag_5_years = "5-year lag"
    )
  ) %>%
  select(outcome, lag, result) %>%
  pivot_wider(
    names_from = lag,
    values_from = result
  ) %>%
  rename(Outcome = outcome)

# Show the short-run change-on-change alternative estimand
secondary_change_table <- secondary_sensitivity %>%
  filter(
    component == "Within country",
    exposure %in% c(
      "ratio_change_current",
      "ratio_change_lag_1_year",
      "ratio_change_lag_3_years",
      "ratio_change_lag_5_years"
    )
  ) %>%
  mutate(
    outcome = sub(" annual change$", "", outcome),
    result = if_else(
      is.na(estimate),
      "Not estimable",
      format_estimate_ci(
        estimate,
        conf_low,
        conf_high
      )
    ),
    timing = recode(
      exposure,
      ratio_change_current = "Same year",
      ratio_change_lag_1_year = "1-year lag",
      ratio_change_lag_3_years = "3-year lag",
      ratio_change_lag_5_years = "5-year lag"
    )
  ) %>%
  select(outcome, timing, result) %>%
  pivot_wider(
    names_from = timing,
    values_from = result
  ) %>%
  rename(Outcome = outcome)

secondary_change_summary <- secondary_sensitivity %>%
  filter(
    component == "Within country",
    grepl("^ratio_change", exposure),
    !is.na(estimate)
  ) %>%
  summarise(
    estimable_models = n(),
    intervals_excluding_zero = sum(
      conf_low > 0 | conf_high < 0
    )
  )


# Build the Markdown report
main_sample <- sample_flow %>%
  filter(stage == "Common main-model sample")

headline_overview <- main_overview %>%
  filter(model == "model_5_fully_adjusted")

year_effect_table <- bind_rows(
  tibble(
    Year = as.integer(main_sample$first_year),
    `Effect [95% CI]` = "0.000 (reference)"
  ),
  main_coefficients %>%
    filter(
      model == "model_5_fully_adjusted",
      grepl("^year_factor", term)
    ) %>%
    transmute(
      Year = as.integer(sub("^year_factor", "", term)),
      `Effect [95% CI]` = format_estimate_ci(
        estimate,
        conf_low,
        conf_high
      )
    )
) %>%
  arrange(Year)

country_sample_table <- country_sample_counts %>%
  transmute(
    Country = country,
    Code = code,
    System = system,
    `Panel years` = panel_observations,
    `Included observations` = included_observations,
    `Excluded observations` = excluded_observations,
    `Included years` = included_years
  )

table1_country_counts <- country_sample_counts %>%
  distinct(code, system) %>%
  count(system, name = "countries")

table1_country_n <- setNames(
  table1_country_counts$countries,
  table1_country_counts$system
)

format_table1_cell <- function(mean, sd, nonmissing_n, digits) {
  if (is.na(mean)) {
    return("Not available")
  }

  sd_text <- if (is.na(sd)) {
    "NA"
  } else {
    formatC(sd, format = "f", digits = digits)
  }

  paste0(
    formatC(mean, format = "f", digits = digits),
    " (",
    sd_text,
    "); n=",
    nonmissing_n
  )
}

table1_report <- table1_descriptive_statistics %>%
  mutate(
    value = mapply(
      format_table1_cell,
      mean,
      sd,
      nonmissing_n,
      digits
    )
  ) %>%
  select(label, unit, group, value) %>%
  pivot_wider(
    names_from = group,
    values_from = value
  ) %>%
  rename(
    Variable = label,
    Unit = unit
  )

names(table1_report)[names(table1_report) == "BIS"] <- paste0(
  "BIS (n=",
  table1_country_n[["BIS"]],
  ")"
)
names(table1_report)[names(table1_report) == "BEV"] <- paste0(
  "BEV (n=",
  table1_country_n[["BEV"]],
  ")"
)
names(table1_report)[names(table1_report) == "Total"] <- paste0(
  "Total (N=",
  sum(table1_country_counts$countries),
  ")"
)

report_lines <- c(
  "# Health and Defence Spending: Results Summary",
  "",
  paste("Generated:", Sys.Date()),
  "",
  "> These analyses estimate associations and do not establish causation.",
  "",
  "## Analysis sample",
  "",
  sprintf(
    "The main analysis includes **%s observations from %s countries during %s-%s**. Iceland is absent from the authoritative study-country source, Luxembourg is included in all analyses, and COVID years 2020-2021 are excluded from the primary analysis. They are retained in the processed panel for the explicit main-model sensitivity. 2022 is unavailable in the primary model because its previous-year debt value comes from excluded 2021.",
    main_sample$rows,
    main_sample$countries,
    main_sample$first_year,
    main_sample$last_year
  ),
  "",
  "The table below reports the country-level contribution to the common complete-case main-model sample. Included years satisfy all main-model requirements; panel years are the 24 primary-analysis years after excluding 2020 and 2021.",
  "",
  markdown_table(country_sample_table),
  "",
  "### Table 1. Descriptive statistics of the primary-analysis panel",
  "",
  "Values are mean (standard deviation); n is the number of non-missing country-year observations. Statistics use the 24 primary-analysis years and exclude 2020 and 2021.",
  "",
  markdown_table(table1_report),
  "",
  sprintf(
    "The headline model uses categorical year effects and a country random intercept. Its estimated country variance is **%s** and its singular-fit status is **%s**.",
    format_number(headline_overview$country_variance, 6),
    headline_overview$singular_fit
  ),
  "",
  "## Primary analysis",
  "",
  "### Model sequence",
  "",
  markdown_table(main_model_table),
  "",
  "Here, $\\Delta H$ is relative health-spending change, $\\Delta D$ is relative defence-spending change, $S$ is health-system type, $B_{i,t-1}$ is previous-year public debt as a share of GDP, $\\gamma_t$ denotes categorical year effects, and $u_i$ is the country random intercept.",
  "",
  "### Key headline findings",
  "",
  paste0(
    "- In Beveridge countries at average previous-year debt, a 10% relative increase in defence spending was associated with a **",
    get_main_term("defence_change_10pct"),
    "** percentage-point relative change in health spending."
  ),
  paste0(
    "- The Bismarck-system fixed effect was **",
    get_main_term("systemBIS"),
    "**."
  ),
  paste0(
    "- The defence-change slope difference for Bismarck systems was **",
    get_main_term("defence_change_10pct:systemBIS"),
    "**."
  ),
  paste0(
    "- The defence-by-previous-year-debt interaction was **",
    get_main_term("defence_change_10pct:previous_debt_10pp_c"),
    "**."
  ),
  paste0(
    "- The coefficient for a doubling of GDP per capita was **",
    get_main_term("log2_gdp_percap_c"),
    "**."
  ),
  "",
  "Estimates are shown as coefficient [95% confidence interval]. Year-dummy coefficients are omitted from the compact table.",
  "",
  markdown_table(main_coefficient_table),
  "",
  "### Conditional defence slopes",
  "",
  markdown_table(main_slope_table),
  "",
  "### Model-output figures",
  "",
  "![Headline model forest plot](figures/main_model_forest_plot.png)",
  "",
  "![Interaction slopes plot](figures/main_interaction_slopes_plot.png)",
  "",
  "The GEE is retained as a robustness check in the sensitivity analyses rather than as a headline main model in the sequential sequence.",
  "",
  "### Categorical year effects",
  "",
  sprintf(
    "These coefficients are the common year-level differences in relative health-spending change from the %s reference year in the fully adjusted model. They should be interpreted as adjustment for shared annual shocks, not as effects caused by the calendar year.",
    main_sample$first_year
  ),
  "",
  markdown_table(year_effect_table),
  "",
  "## Secondary analyses",
  "",
  "All secondary models use the common form:",
  "",
  "$$g(Y_{it})=\\beta_0+\\beta_W(R_{it}-\\bar{R}_i)+\\beta_B\\bar{R}_i+\\beta_SS_i+\\beta_G\\log_2(GDPpc_{it})+\\gamma_t+u_i+\\epsilon_{it},$$",
  "",
  "where $R$ is the log2 health-to-defence spending ratio. The within-country coefficient is the principal longitudinal association. A one-unit change in log2 ratio represents a doubling of the health-to-defence ratio.",
  "",
  "Hospital beds use OECD as the primary source, with WHO values used only for country-years where OECD is missing.",
  "",
  "The primary secondary models use outcome levels because the out-of-pocket share of current health expenditure, beds, workforce, and treatable mortality are slow-moving measures, often observed intermittently. Differencing them would discard information and can magnify measurement error. Change in the log ratio paired with year-on-year outcome change is therefore reported as a short-run sensitivity rather than mixed into the primary estimand.",
  "",
  "For log-transformed outcomes, effects below are percentage changes per doubling of the ratio. Other outcomes retain the units shown.",
  "",
  markdown_table(secondary_result_table),
  "",
  "## Notable sensitivity analyses",
  "",
  "### Lagged defence-change sensitivity",
  "",
  "These models estimate whether defence-spending change predicts health-spending change one, two, or three years later. For every lag, the debt moderator is measured in the year before the health-spending change outcome.",
  "",
  markdown_table(lagged_main_table),
  "",
  "### Other notable sensitivities",
  "",
  "The focal estimates below show the defence-change main effect and the defence-by-Bismarck interaction for each specification.",
  "",
  markdown_table(other_notable_sensitivity_table),
  "",
  sprintf(
    "Across leave-one-country-out analyses, the headline defence coefficient ranged from **%s to %s**. The full range of lower and upper confidence limits was **%s to %s**.",
    format_number(leave_one_out_summary$minimum),
    format_number(leave_one_out_summary$maximum),
    format_number(leave_one_out_summary$minimum_low),
    format_number(leave_one_out_summary$maximum_high)
  ),
  "",
  "### Lagged secondary associations",
  "",
  "These are within-country model-scale coefficients [95% confidence interval] for lagged log2 spending ratios.",
  "",
  markdown_table(secondary_lag_table),
  "",
  "### Change-on-change secondary associations",
  "",
  "These sensitivity models relate within-country change in the log2 spending ratio to year-on-year outcome change. Transitions involving 2020 or 2021 are not used. Coefficients are shown on each outcome's model scale.",
  "",
  markdown_table(secondary_change_table),
  "",
  sprintf(
    "Across the remaining change-on-change models, %s of %s 95%% confidence intervals excluded zero. Directions and timing varied across outcomes, so these results do not indicate a consistent short-run pattern.",
    secondary_change_summary$intervals_excluding_zero,
    secondary_change_summary$estimable_models
  ),
  "",
  "## Descriptive figures",
  "",
  "### Health-to-defence spending ratio",
  "",
  "![Health-to-defence spending ratio over time](figures/health_def_ratio_timeseries.png)",
  "",
  "### Average spending by health-system type",
  "",
  "![Average health and defence spending as a share of GDP](figures/system_avg_spending_pct_gdp_timeseries.png)",
  "",
  "## Interpretation cautions",
  "",
  "- The models are associational and may retain residual confounding or reverse causation.",
  "- Health, defence, and debt measures share GDP-related denominators, so common economic shocks can create coupled movements.",
  "- A singular random-intercept fit indicates that the estimated between-country residual variance is effectively zero after included covariates.",
  "- The GEE is reported in the sensitivity section as a robust population-average check, not as the headline main-model specification.",
  "- Secondary analyses are exploratory and span outcomes with different observation schedules and sample sizes.",
  "- Annual differencing may reduce trend confounding but magnifies measurement error and is poorly suited to intermittently observed outcomes.",
  "",
  "## Reproducibility",
  "",
  "Run the reporting pipeline from the repository root:",
  "",
  "```powershell",
  "Rscript code/02_analysis.R",
  "Rscript code/03_sensitivity_analyses.R",
  "Rscript code/04_visualisation.R",
  "Rscript code/05_results_summary.R",
  "```",
  "",
  "The report is generated entirely from machine-readable files in `results/tables/` and `results/sensitivities/`; no estimates are entered manually."
)

writeLines(report_lines, output_file)

html_body <- commonmark::markdown_html(
  paste(report_lines, collapse = "\n"),
  extensions = c(
    "table",
    "strikethrough",
    "autolink",
    "tagfilter",
    "tasklist"
  )
)

html_document <- paste0(
  "<!doctype html>\n",
  "<html lang=\"en\">\n",
  "<head>\n",
  "<meta charset=\"utf-8\">\n",
  "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n",
  "<title>Health and Defence Spending: Results Summary</title>\n",
  "<link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/katex.min.css\">\n",
  "<style>",
  "body{font-family:system-ui,sans-serif;line-height:1.6;max-width:1100px;",
  "margin:2rem auto;padding:0 1rem;color:#1f2328}",
  "table{border-collapse:collapse;width:100%;margin:1rem 0}",
  "th,td{border:1px solid #d0d7de;padding:.45rem;text-align:left;",
  "vertical-align:top}",
  "th{background:#f6f8fa}",
  "blockquote{border-left:4px solid #d0d7de;margin-left:0;padding-left:1rem}",
  "code{background:#f6f8fa;padding:.1rem .25rem}",
  "pre code{display:block;padding:1rem;overflow:auto}",
  "img{max-width:100%;height:auto}",
  "</style>\n",
  "</head>\n",
  "<body>\n",
  html_body,
  "<script defer src=\"https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/katex.min.js\"></script>\n",
  "<script defer src=\"https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/contrib/auto-render.min.js\" ",
  "onload=\"renderMathInElement(document.body,{delimiters:[",
  "{left:'$$',right:'$$',display:true},{left:'$',right:'$',display:false}]});\"></script>\n",
  "</body>\n",
  "</html>"
)

writeLines(html_document, html_output_file)

cat(
  "Saved", output_file, "and", html_output_file,
  "from", length(report_lines), "Markdown lines.\n"
)
