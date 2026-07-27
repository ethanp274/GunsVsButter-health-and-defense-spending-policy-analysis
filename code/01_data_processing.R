#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DATA CLEANING AND PREPARATION FOR ANALYSIS OF HEALTH AND DEFENCE SPENDING
# Harry Rourke & Ethan Phillips
# Last updated: 2026-07-27
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Load the packages used to read, reshape, and join the data
suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(tidyr)
})


# Read the seven current raw datasets
missing_values <- c("", "NA", "xxx", "...", "..", ". .")

defence_raw <- read_csv(
  "raw_data/SIPRI_defence_pct_gdp.csv",
  na = missing_values,
  name_repair = "unique_quiet",
  show_col_types = FALSE
)

health_raw <- read_csv(
  "raw_data/WHO_health_spend_and_outcomes.csv",
  na = missing_values,
  show_col_types = FALSE
)

gdp_raw <- read_csv(
  "raw_data/WorldBank_gdp.csv",
  na = missing_values,
  show_col_types = FALSE
)

gdp_percap_raw <- read_csv(
  "raw_data/WorldBank_gdp_per_capita.csv",
  na = missing_values,
  show_col_types = FALSE
)

debt_raw <- read_csv(
  "raw_data/IMF_debt_pct_gdp.csv",
  na = missing_values,
  show_col_types = FALSE
)

mortality_raw <- read_csv(
  "raw_data/OECD_mortality_per100k.csv",
  na = missing_values,
  show_col_types = FALSE
)

systems_df <- read_csv(
  "raw_data/oecd_europe_health_systems.csv",
  na = missing_values,
  show_col_types = FALSE
) %>%
  mutate(code = trimws(code))


# Reshape a wide source from one year per column to one year per row
reshape_country_year <- function(data) {
  data %>%
    mutate(
      code = trimws(code),
      across(matches("^\\d{4}$"), as.numeric)
    ) %>%
    pivot_longer(
      cols = matches("^\\d{4}$"),
      names_to = "year",
      values_to = "value"
    ) %>%
    mutate(year = as.integer(year))
}

study_codes <- systems_df$code


# Prepare defence spending as a share of GDP
defence_df <- defence_raw %>%
  reshape_country_year() %>%
  filter(code %in% study_codes, year >= 2000, year <= 2024) %>%
  transmute(code, year, defence_pct_gdp = value)


# Prepare the selected health spending and outcome indicators
health_df <- health_raw %>%
  reshape_country_year() %>%
  filter(code %in% study_codes, year >= 2000, year <= 2024) %>%
  mutate(
    clean_variable = case_when(
      variable == "Domestic general government health expenditure (% of GDP)" ~
        "health_pct_gdp",
      variable == "Hospital beds (per 1,000 people)" ~
        "hosp_beds_per_thou",
      variable == "Life expectancy at birth, total (years)" ~
        "life_exp",
      variable == "Physicians (per 1,000 people)" ~
        "mds_per_thou",
      variable == "Nurses and midwives (per 1,000 people)" ~
        "nurses_per_thou",
      variable == "Out-of-pocket expenditure (% of current health expenditure)" ~
        "oop_pct",
      variable == "UHC service coverage index" ~
        "uhc_idx",
      variable ==
        "Mortality from CVD, cancer, diabetes or CRD between exact ages 30 and 70 (%)" ~
        "premature_ncd_mortality_pct",
      TRUE ~ NA_character_
    )
  ) %>%
  filter(!is.na(clean_variable)) %>%
  select(code, year, clean_variable, value) %>%
  pivot_wider(
    names_from = clean_variable,
    values_from = value
  )


# Prepare the three OECD mortality indicators
mortality_df <- mortality_raw %>%
  reshape_country_year() %>%
  filter(code %in% study_codes, year >= 2000, year <= 2024) %>%
  mutate(
    clean_variable = case_when(
      variable == "Avoidable mortality" ~
        "avoidable_mortality_per_100k",
      variable == "Preventable mortality" ~
        "preventable_mortality_per_100k",
      variable == "Treatable mortality" ~
        "treatable_mortality_per_100k",
      TRUE ~ NA_character_
    )
  ) %>%
  filter(!is.na(clean_variable)) %>%
  select(code, year, clean_variable, value) %>%
  pivot_wider(
    names_from = clean_variable,
    values_from = value
  )


# Prepare GDP, GDP per capita, and government debt
gdp_df <- gdp_raw %>%
  reshape_country_year() %>%
  filter(code %in% study_codes, year >= 2000, year <= 2024) %>%
  transmute(code, year, gdp_current_usd = value)

gdp_percap_df <- gdp_percap_raw %>%
  reshape_country_year() %>%
  filter(code %in% study_codes, year >= 2000, year <= 2024) %>%
  transmute(code, year, gdp_percap = value)

debt_df <- debt_raw %>%
  reshape_country_year() %>%
  filter(code %in% study_codes, year >= 2000, year <= 2024) %>%
  transmute(code, year, government_debt_pct_gdp = value)


# Check that each prepared source has at most one row per country and year
check_unique_keys <- function(data, source_name) {
  if (anyDuplicated(data[c("code", "year")]) > 0) {
    stop(source_name, " has duplicate country-year rows.")
  }
}

check_unique_keys(defence_df, "SIPRI defence data")
check_unique_keys(health_df, "WHO health data")
check_unique_keys(mortality_df, "OECD mortality data")
check_unique_keys(gdp_df, "World Bank GDP data")
check_unique_keys(gdp_percap_df, "World Bank GDP-per-capita data")
check_unique_keys(debt_df, "IMF debt data")


# Build the complete panel and retain missing source observations as NA
master_df <- expand_grid(
  systems_df,
  year = 2000:2024
) %>%
  left_join(defence_df, by = c("code", "year")) %>%
  left_join(health_df, by = c("code", "year")) %>%
  left_join(gdp_df, by = c("code", "year")) %>%
  left_join(gdp_percap_df, by = c("code", "year")) %>%
  left_join(debt_df, by = c("code", "year")) %>%
  left_join(mortality_df, by = c("code", "year"))


# Calculate relative annual changes and the health-to-defence spending ratio
master_df <- master_df %>%
  group_by(code) %>%
  arrange(year, .by_group = TRUE) %>%
  mutate(
    change_def_gdp = if_else(
      !is.na(defence_pct_gdp) &
        !is.na(lag(defence_pct_gdp)) &
        lag(defence_pct_gdp) > 0,
      round(defence_pct_gdp / lag(defence_pct_gdp) - 1, 4),
      NA_real_
    ),
    change_health_gdp = if_else(
      !is.na(health_pct_gdp) &
        !is.na(lag(health_pct_gdp)) &
        lag(health_pct_gdp) > 0,
      round(health_pct_gdp / lag(health_pct_gdp) - 1, 4),
      NA_real_
    ),
    change_debt_gdp = if_else(
      !is.na(government_debt_pct_gdp) &
        !is.na(lag(government_debt_pct_gdp)) &
        lag(government_debt_pct_gdp) > 0,
      round(
        government_debt_pct_gdp / lag(government_debt_pct_gdp) - 1,
        4
      ),
      NA_real_
    ),
    health_def_ratio = if_else(
      !is.na(health_pct_gdp) &
        !is.na(defence_pct_gdp) &
        defence_pct_gdp > 0,
      round(health_pct_gdp / defence_pct_gdp, 4),
      NA_real_
    )
  ) %>%
  ungroup() %>%
  arrange(country, year) %>%
  select(
    country,
    code,
    system,
    year,
    defence_pct_gdp,
    health_pct_gdp,
    gdp_current_usd,
    gdp_percap,
    government_debt_pct_gdp,
    hosp_beds_per_thou,
    life_exp,
    mds_per_thou,
    nurses_per_thou,
    oop_pct,
    uhc_idx,
    premature_ncd_mortality_pct,
    avoidable_mortality_per_100k,
    preventable_mortality_per_100k,
    treatable_mortality_per_100k,
    change_def_gdp,
    change_health_gdp,
    change_debt_gdp,
    health_def_ratio
  )


# Stop with a clear error if the finalized panel is not as expected
if (n_distinct(master_df$code) != 31) {
  stop("The finalized panel must contain exactly 31 countries.")
}

if (nrow(master_df) != 31 * 25) {
  stop("The finalized panel must contain 775 country-year rows.")
}

if (any(range(master_df$year) != c(2000, 2024))) {
  stop("The finalized panel must cover 2000-2024.")
}

if (anyDuplicated(master_df[c("code", "year")]) > 0) {
  stop("The finalized panel has duplicate country-year rows.")
}

if (any(is.na(master_df$country)) ||
    any(is.na(master_df$code)) ||
    any(is.na(master_df$system)) ||
    any(is.na(master_df$year))) {
  stop("Country, code, system, and year must be complete.")
}

measure_columns <- setdiff(
  names(master_df),
  c("country", "code", "system")
)

if (!all(vapply(master_df[measure_columns], is.numeric, logical(1)))) {
  stop("Year and all measure columns must be numeric.")
}

nonnegative_columns <- c(
  "defence_pct_gdp",
  "health_pct_gdp",
  "gdp_current_usd",
  "gdp_percap",
  "government_debt_pct_gdp",
  "hosp_beds_per_thou",
  "life_exp",
  "mds_per_thou",
  "nurses_per_thou",
  "oop_pct",
  "uhc_idx",
  "premature_ncd_mortality_pct",
  "avoidable_mortality_per_100k",
  "preventable_mortality_per_100k",
  "treatable_mortality_per_100k"
)

has_negative_value <- vapply(
  master_df[nonnegative_columns],
  function(x) any(x < 0, na.rm = TRUE),
  logical(1)
)

if (any(has_negative_value)) {
  stop("Source measures must not contain negative values.")
}

derived_check <- master_df %>%
  group_by(code) %>%
  arrange(year, .by_group = TRUE) %>%
  mutate(
    previous_defence = lag(defence_pct_gdp),
    previous_health = lag(health_pct_gdp),
    previous_debt = lag(government_debt_pct_gdp)
  ) %>%
  ungroup()

invalid_defence_change <- with(
  derived_check,
  !is.na(change_def_gdp) &
    (is.na(defence_pct_gdp) |
      is.na(previous_defence) |
      previous_defence <= 0)
)

invalid_health_change <- with(
  derived_check,
  !is.na(change_health_gdp) &
    (is.na(health_pct_gdp) |
      is.na(previous_health) |
      previous_health <= 0)
)

invalid_debt_change <- with(
  derived_check,
  !is.na(change_debt_gdp) &
    (is.na(government_debt_pct_gdp) |
      is.na(previous_debt) |
      previous_debt <= 0)
)

invalid_ratio <- with(
  derived_check,
  !is.na(health_def_ratio) &
    (is.na(health_pct_gdp) |
      is.na(defence_pct_gdp) |
      defence_pct_gdp <= 0)
)

if (any(invalid_defence_change) ||
    any(invalid_health_change) ||
    any(invalid_debt_change) ||
    any(invalid_ratio)) {
  stop("Derived variables do not handle missing or non-positive values correctly.")
}


# Save the finalized dataset for the analysis stage
dir.create("processed_data", showWarnings = FALSE)
write_csv(master_df, "processed_data/primary_analysis.csv", na = "")

cat(
  "Saved processed_data/primary_analysis.csv:",
  nrow(master_df), "rows,",
  n_distinct(master_df$code), "countries,",
  paste0(min(master_df$year), "-", max(master_df$year)),
  "\n"
)
