#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DATA CLEANING AND PREPARATION FOR ANALYSIS OF HEALTH AND DEFENSE SPENDING TRADEOFF   
# Harry Rourke & Ethan Phillips                                
# Last updated: 2026-06-27                                   
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Load packages
library(dplyr)
library(readr)
library(tidyr)


# Load raw data
defence_df <- read_csv(
  "raw_data/defence_spending_pct_gov_spending.csv",
  na = c("", "xxx", "...", "..", ". ."),
  name_repair = "unique_quiet",
  show_col_types = FALSE
)

health_df <- read_csv(
  "raw_data/health_spend_and_outcomes_by_year.csv",
  na = c("", "xxx", "...", "..", ". ."),
  show_col_types = FALSE
)

defence_gdp_df <- read_csv(
  "raw_data/defence_spending_pct_gdp.csv",
  na = c("", "xxx", "...", "..", ". ."),
  name_repair = "unique_quiet",
  show_col_types = FALSE
)

health_gdp_df <- read_csv(
  "raw_data/health_spending_pct_gdp.csv",
  na = c("", "xxx", "...", "..", ". ."),
  show_col_types = FALSE
)

gdp_df <- read_csv(
  "raw_data/gdp_per_capita.csv",
  na = c("", "xxx", "...", "..", ". ."),
  show_col_types = FALSE
)

systems_df <- read_csv(
  "raw_data/oecd_europe_health_systems.csv",
  show_col_types = FALSE
)

defence_df <- defence_df %>%
  mutate(
    code = trimws(code),
    code = if_else(country == "Slovakia" & (is.na(code) | code == ""), "SVK", code)
  )

defence_gdp_df <- defence_gdp_df %>%
  mutate(
    Code = trimws(Code),
    Code = if_else(Country == "Slovakia" & (is.na(Code) | Code == ""), "SVK", Code)
  )

health_df <- health_df %>%
  mutate(code = trimws(code))

health_gdp_df <- health_gdp_df %>%
  mutate(`Country Code` = trimws(`Country Code`))

gdp_df <- gdp_df %>%
  mutate(code = trimws(code))

systems_df <- systems_df %>%
  mutate(code = trimws(code))

# Reshape from wide to long
reshape_country_year <- function(df, code_col = NULL) {
  if (!is.null(code_col) && code_col %in% names(df)) {
    df <- df %>%
      filter(!is.na(.data[[code_col]]), .data[[code_col]] != "")
  }

  df %>%
    mutate(across(matches("^\\d{4}$"), as.character)) %>%
    pivot_longer(
      cols = matches("^\\d{4}$"),
      names_to = "year",
      values_to = "value"
    ) %>%
    mutate(
      year = as.integer(year),
      value = if_else(is.na(value), NA_character_, as.character(value)),
      value = trimws(value),
      value = na_if(value, ""),
      value = na_if(value, "xxx"),
      value = na_if(value, "..."),
      value = na_if(value, ".."),
      value = na_if(value, ". ."),
      value = gsub("[,%]", "", value),
      value = as.numeric(value)
    )
}

reshape_health_country_year <- function(df) {
  df %>%
    filter(
      !is.na(variable),
      !is.na(country),
      !is.na(code),
      variable != "",
      country != "",
      code != ""
    ) %>%
    reshape_country_year(code_col = "code") %>%
    select(code, year, variable, value) %>%
    pivot_wider(
      names_from = variable,
      values_from = value
    )
}

defence_df <- reshape_country_year(defence_df, code_col = "code") %>%
    rename(defence_pct = value) %>%
    select(c(code, year, defence_pct))

defence_gdp_df <- reshape_country_year(defence_gdp_df, code_col = "Code") %>%
    rename(defence_pct_gdp = value) %>%
    rename(code = Code) %>%
    mutate(defence_pct_gdp = round(defence_pct_gdp / 100, 4)) %>%
    select(c(code, year, defence_pct_gdp))

health_df <- reshape_health_country_year(health_df)

health_gdp_df <- reshape_country_year(health_gdp_df, code_col = "Country Code") %>%
    rename(health_pct_gdp = value) %>%
    rename(code = "Country Code") %>%
    mutate(health_pct_gdp = round(health_pct_gdp / 100, 4)) %>%
    select(c(code, year, health_pct_gdp))

gdp_df <- reshape_country_year(gdp_df, code_col = "code") %>% 
    rename(gdp_percap = value) %>%
    select(c(code, year, gdp_percap))


# Merge datasets
master_df <- systems_df %>%
  left_join(defence_df, by = c("code" = "code")) %>%
  left_join(defence_gdp_df, by = c("code" = "code", "year" = "year")) %>%
  left_join(health_df, by = c("code" = "code", "year" = "year")) %>%
  left_join(health_gdp_df, by = c("code" = "code", "year" = "year")) %>%
  left_join(gdp_df, by = c("code" = "code", "year" = "year")) 


# Filter for desired years
master_df <- master_df %>%
    filter(year > 1999) %>%
    filter(year < 2023)


# Calculate lagged variables
master_df <- master_df %>%
    group_by(country) %>%
    arrange(year, .by_group = TRUE) %>%
    mutate(health_pct_gge = round(health_pct_gge/100, 4)) %>%
    mutate(change_def = defence_pct - lag(defence_pct)) %>%
    mutate(change_health = health_pct_gge - lag(health_pct_gge)) %>%
    mutate(change_def_gdp = defence_pct_gdp - lag(defence_pct_gdp)) %>%
    mutate(change_health_gdp = health_pct_gdp - lag(health_pct_gdp)) %>%
    mutate(change_def = round(change_def/lag(defence_pct), 4)) %>%
    mutate(change_health = round(change_health/lag(health_pct_gge), 4)) %>%
    mutate(
      change_def_gdp = if_else(
        !is.na(lag(defence_pct_gdp)) & lag(defence_pct_gdp) > 0,
        round(change_def_gdp / lag(defence_pct_gdp), 4),
        NA_real_
      )
    ) %>%
    mutate(
      change_health_gdp = if_else(
        !is.na(lag(health_pct_gdp)) & lag(health_pct_gdp) > 0,
        round(change_health_gdp / lag(health_pct_gdp), 4),
        NA_real_
      )
    ) %>%
    mutate(
      health_def_ratio = if_else(
        !is.na(defence_pct_gdp) & defence_pct_gdp > 0,
        health_pct_gdp / defence_pct_gdp,
        NA_real_
      )
    ) %>%
    mutate(health_def_ratio = round(health_def_ratio, 4)) %>%
    ungroup()
    

# Save processed data
write_csv(master_df, "processed_data/primary_analysis.csv", na = "")
