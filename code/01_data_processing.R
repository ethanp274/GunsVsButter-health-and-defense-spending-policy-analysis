#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DATA CLEANING AND PREPARATION FOR ANALYSIS OF HEALTH AND DEFENCE SPENDING
# Harry Rourke & Ethan Phillips
# Last updated: 2026-08-05
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Load the packages used to read, reshape, and join the data
suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(tidyr)
})


# Read the current CSV inputs
missing_values <- c("", "NA", "xxx", "...", "..", ". .")

read_source_csv <- function(path) {
  if (!file.exists(path)) {
    stop("Required source file is missing: ", path)
  }

  read_csv(
    path,
    na = missing_values,
    col_types = cols(.default = col_character()),
    name_repair = "unique_quiet",
    show_col_types = FALSE
  )
}

defence_raw <- read_source_csv("raw_data/SIPRI_defence_pct_gdp.csv")
health_raw <- read_source_csv("raw_data/OECD_health_spending_pct_gdp.csv")
gdp_percap_raw <- read_source_csv("raw_data/OECD_gdp_per_cap.csv")
debt_raw <- read_source_csv("raw_data/IMF_debt_pct_gdp.csv")
beds_raw <- read_source_csv("raw_data/OECD_beds_per_k.csv")
consults_raw <- read_source_csv("raw_data/OECD_md_consults_per_person.csv")
physicians_raw <- read_source_csv("raw_data/OECD_mds_per_k.csv")
nurses_raw <- read_source_csv("raw_data/OECD_rns_per_k.csv")
oop_raw <- read_source_csv("raw_data/OECD_oop_pct_health_spend.csv")
scans_raw <- read_source_csv("raw_data/OECD_scans_per_k.csv")
treatable_mortality_raw <- read_source_csv(
  "raw_data/OECD_treat_mortality_per_100k.csv"
)

systems_df <- read_source_csv("raw_data/oecd_europe_health_systems.csv") %>%
  mutate(
    country = trimws(country),
    code = toupper(trimws(code)),
    system = trimws(system)
  )


# Validate the authoritative study-country list before using it for joins
if (nrow(systems_df) != 31 || n_distinct(systems_df$code) != 31) {
  stop("The study-country list must contain exactly 31 unique countries.")
}

if (any(!systems_df$system %in% c("BEV", "BIS"))) {
  stop("Health-system classifications must be BEV or BIS.")
}

study_codes <- systems_df$code

panel_years <- 2000:2025
source_years <- (min(panel_years) - 1L):max(panel_years)


# Helpers for the two source layouts
require_columns <- function(data, required, source_name) {
  missing_columns <- setdiff(required, names(data))

  if (length(missing_columns) > 0) {
    stop(
      source_name,
      " is missing required columns: ",
      paste(missing_columns, collapse = ", ")
    )
  }
}

assert_nonempty <- function(data, source_name) {
  if (nrow(data) == 0) {
    stop(source_name, " produced no study-country observations.")
  }
}

# Reshape a wide source from one year per column to one year per row.
reshape_wide_country_year <- function(data, source_name) {
  require_columns(data, "code", source_name)

  year_columns <- grep("^\\d{4}$", names(data), value = TRUE)

  if (length(year_columns) == 0) {
    stop(source_name, " does not contain four-digit year columns.")
  }

  data %>%
    mutate(
      code = toupper(trimws(code)),
      across(all_of(year_columns), ~ as.numeric(.x))
    ) %>%
    pivot_longer(
      cols = all_of(year_columns),
      names_to = "year",
      values_to = "value"
    ) %>%
    mutate(year = as.integer(year))
}

# Standardise the common OECD SDMX fields while retaining metadata for
# source-specific series selection.
standardise_oecd_rows <- function(data, source_name) {
  require_columns(
    data,
    c("REF_AREA", "TIME_PERIOD", "OBS_VALUE"),
    source_name
  )

  data %>%
    mutate(
      code = toupper(trimws(REF_AREA)),
      year = as.integer(TIME_PERIOD),
      value = as.numeric(OBS_VALUE)
    ) %>%
    filter(
      code %in% study_codes,
      year >= min(source_years),
      year <= max(source_years)
    )
}


# Prepare SIPRI defence spending and IMF government debt.
defence_df <- reshape_wide_country_year(
  defence_raw,
  "SIPRI defence data"
) %>%
  filter(code %in% study_codes, year %in% source_years) %>%
  transmute(code, year, defence_pct_gdp = value)

debt_df <- reshape_wide_country_year(
  debt_raw,
  "IMF government-debt data"
) %>%
  filter(code %in% study_codes, year %in% source_years) %>%
  transmute(code, year, government_debt_pct_gdp = value)


# Prepare government/compulsory health spending as a proportion of GDP.
# The OECD source reports percentage points, so 7.0 becomes 0.07.
health_df <- standardise_oecd_rows(
  health_raw,
  "OECD health-spending data"
) %>%
  filter(
    FINANCING_SCHEME == "HF1",
    UNIT_MEASURE == "PT_B1GQ"
  ) %>%
  transmute(
    code,
    year,
    health_pct_gdp = value / 100
  )


# Prepare OECD GDP per capita. The source is PPP-converted US dollars per
# person at current prices, replacing the former current-US-dollar measure.
gdp_percap_df <- standardise_oecd_rows(
  gdp_percap_raw,
  "OECD GDP-per-capita data"
) %>%
  filter(
    UNIT_MEASURE == "USD_PPP_PS",
    PRICE_BASE == "V"
  ) %>%
  transmute(code, year, gdp_percap = value)


# Prepare the longitudinal OECD health-system indicators.
beds_df <- standardise_oecd_rows(
  beds_raw,
  "OECD hospital-bed data"
) %>%
  filter(
    MEASURE == "HB",
    UNIT_MEASURE == "10P3HB",
    OWNERSHIP_TYPE == "_T",
    HEALTH_FUNCTION == "_Z",
    CARE_TYPE == "_Z",
    MEDICAL_TECH == "_Z",
    HEALTH_CARE_PROVIDER == "_Z"
  ) %>%
  transmute(code, year, hosp_beds_per_thou = value)

physicians_df <- standardise_oecd_rows(
  physicians_raw,
  "OECD physician data"
) %>%
  filter(
    MEASURE == "HSE",
    UNIT_MEASURE == "10P3HB",
    HEALTH_PROF == "PHYS",
    HEALTH_PROF_ACTIVITY_STATUS == "P",
    AGE == "_Z",
    SEX == "_Z"
  ) %>%
  transmute(code, year, mds_per_thou = value)

nurses_df <- standardise_oecd_rows(
  nurses_raw,
  "OECD nurse data"
) %>%
  filter(
    MEASURE == "HSE",
    UNIT_MEASURE == "10P3HB",
    HEALTH_PROF == "MINU",
    HEALTH_PROF_ACTIVITY_STATUS == "P",
    AGE == "_Z",
    SEX == "_Z"
  ) %>%
  transmute(code, year, nurses_per_thou = value)

consults_df <- standardise_oecd_rows(
  consults_raw,
  "OECD consultation data"
) %>%
  filter(
    MEASURE == "CONSULT",
    UNIT_MEASURE == "CN_PS",
    OCCUPATION == "OC221",
    AGE == "_Z",
    SEX == "_Z"
  ) %>%
  transmute(code, year, doctor_consults_per_person = value)

oop_df <- standardise_oecd_rows(
  oop_raw,
  "OECD out-of-pocket data"
) %>%
  filter(
    MEASURE == "EXP_HEALTH",
    UNIT_MEASURE == "PT_EXP_HLTH",
    FINANCING_SCHEME == "HF3",
    PROVIDER == "_T",
    FUNCTION == "_T"
  ) %>%
  transmute(code, year, oop_pct = value / 100)


# Diagnostic scans contain three technologies and multiple provider types.
# Retain the total-provider series and widen the three technologies.
scan_columns <- c(
  "ct_scans_per_thou",
  "mri_scans_per_thou",
  "pet_scans_per_thou"
)

scans_df <- standardise_oecd_rows(
  scans_raw,
  "OECD diagnostic-scan data"
) %>%
  filter(
    MEASURE == "EXAM",
    UNIT_MEASURE == "EXM_10P3PS",
    PROVIDER == "_T"
  ) %>%
  mutate(
    scan_variable = case_when(
      HEALTH_FACILITY == "CT_SCAN" ~ "ct_scans_per_thou",
      HEALTH_FACILITY == "MRI" ~ "mri_scans_per_thou",
      HEALTH_FACILITY == "PET_SCAN" ~ "pet_scans_per_thou",
      TRUE ~ NA_character_
    )
  ) %>%
  filter(!is.na(scan_variable)) %>%
  select(code, year, scan_variable, value) %>%
  pivot_wider(
    names_from = scan_variable,
    values_from = value
  )

for (column in setdiff(scan_columns, names(scans_df))) {
  scans_df[[column]] <- NA_real_
}

scans_df <- scans_df %>%
  select(code, year, all_of(scan_columns))


# The current OECD mortality extract contains the retained treatable outcome.
treatable_mortality_df <- standardise_oecd_rows(
  treatable_mortality_raw,
  "OECD treatable-mortality data"
) %>%
  filter(
    MEASURE == "TRTM",
    UNIT_MEASURE == "DT_10P5HB",
    AGE == "_T",
    SEX == "_T",
    CALC_METHODOLOGY == "STANDARD"
  ) %>%
  transmute(
    code,
    year,
    treatable_mortality_per_100k = value
  )


# Check that each prepared source has at most one row per country and year.
check_unique_keys <- function(data, source_name) {
  assert_nonempty(data, source_name)

  if (anyDuplicated(data[c("code", "year")]) > 0) {
    stop(source_name, " has duplicate country-year rows.")
  }
}

check_unique_keys(defence_df, "SIPRI defence data")
check_unique_keys(health_df, "OECD health-spending data")
check_unique_keys(gdp_percap_df, "OECD GDP-per-capita data")
check_unique_keys(debt_df, "IMF government-debt data")
check_unique_keys(beds_df, "OECD hospital-bed data")
check_unique_keys(physicians_df, "OECD physician data")
check_unique_keys(nurses_df, "OECD nurse data")
check_unique_keys(consults_df, "OECD consultation data")
check_unique_keys(oop_df, "OECD out-of-pocket data")
check_unique_keys(scans_df, "OECD diagnostic-scan data")
check_unique_keys(
  treatable_mortality_df,
  "OECD treatable-mortality data"
)


# Build an extended working panel so the first retained year's changes can use
# source observations from 1999. The final master file is filtered to 2000-2025.
panel_df <- expand_grid(
  systems_df,
  year = source_years
) %>%
  left_join(defence_df, by = c("code", "year")) %>%
  left_join(health_df, by = c("code", "year")) %>%
  left_join(gdp_percap_df, by = c("code", "year")) %>%
  left_join(debt_df, by = c("code", "year")) %>%
  left_join(beds_df, by = c("code", "year")) %>%
  left_join(physicians_df, by = c("code", "year")) %>%
  left_join(nurses_df, by = c("code", "year")) %>%
  left_join(consults_df, by = c("code", "year")) %>%
  left_join(oop_df, by = c("code", "year")) %>%
  left_join(scans_df, by = c("code", "year")) %>%
  left_join(treatable_mortality_df, by = c("code", "year"))


# Calculate relative annual changes, previous-year debt, and the
# health-to-defence spending ratio before removing the 1999 working row.
panel_df <- panel_df %>%
  group_by(code) %>%
  arrange(year, .by_group = TRUE) %>%
  mutate(
    previous_government_debt_pct_gdp = lag(government_debt_pct_gdp),
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
  arrange(country, year)

master_df <- panel_df %>%
  filter(year %in% panel_years) %>%
  select(
    country,
    code,
    system,
    year,
    defence_pct_gdp,
    health_pct_gdp,
    gdp_percap,
    government_debt_pct_gdp,
    previous_government_debt_pct_gdp,
    hosp_beds_per_thou,
    mds_per_thou,
    nurses_per_thou,
    doctor_consults_per_person,
    oop_pct,
    ct_scans_per_thou,
    mri_scans_per_thou,
    pet_scans_per_thou,
    treatable_mortality_per_100k,
    change_def_gdp,
    change_health_gdp,
    change_debt_gdp,
    health_def_ratio
  )


# Stop with a clear error if the finalized panel is not structurally valid.
if (n_distinct(master_df$code) != 31) {
  stop("The finalized panel must contain exactly 31 countries.")
}

if (nrow(master_df) != 31 * length(panel_years)) {
  stop("The finalized panel must contain 806 country-year rows.")
}

if (any(range(master_df$year) != c(min(panel_years), max(panel_years)))) {
  stop("The finalized panel must cover 2000-2025.")
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
  "gdp_percap",
  "government_debt_pct_gdp",
  "previous_government_debt_pct_gdp",
  "hosp_beds_per_thou",
  "mds_per_thou",
  "nurses_per_thou",
  "doctor_consults_per_person",
  "oop_pct",
  "ct_scans_per_thou",
  "mri_scans_per_thou",
  "pet_scans_per_thou",
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

proportion_columns <- c(
  "defence_pct_gdp",
  "health_pct_gdp",
  "oop_pct"
)

has_invalid_proportion <- vapply(
  master_df[proportion_columns],
  function(x) any(x > 1, na.rm = TRUE),
  logical(1)
)

if (any(has_invalid_proportion)) {
  stop("GDP-share and OOP proportion columns must not exceed 1.")
}

derived_check <- panel_df %>%
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


# Save the finalized dataset for the analysis stage.
dir.create("processed_data", showWarnings = FALSE)
write_csv(master_df, "processed_data/primary_analysis.csv", na = "")

cat(
  "Saved processed_data/primary_analysis.csv:",
  nrow(master_df), "rows,",
  n_distinct(master_df$code), "countries,",
  paste0(min(master_df$year), "-", max(master_df$year)),
  "\n"
)
