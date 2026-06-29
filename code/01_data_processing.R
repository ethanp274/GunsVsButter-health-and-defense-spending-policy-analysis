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
  "raw_data/defence_spending_pct_gdp.csv",
  na = c("", "xxx", "..."),
  show_col_types = FALSE
)

health_df <- read_csv(
  "raw_data/health_spending_pct_gdp.csv",
  na = c("", "xxx", "..."),
  show_col_types = FALSE
)

gdp_df <- read_csv(
  "raw_data/gdp_per_capita.csv",
  na = c("", "xxx", "..."),
  show_col_types = FALSE
)

systems_df <- read_csv(
  "raw_data/oecd_europe_health_systems.csv",
  show_col_types = FALSE
)

systems_df <- systems_df %>%
    rename(code = Code) %>%
    rename(country = Country) %>%
    rename(system = System) %>%
    rename(region = Region)


# Reshape from wide to long
reshape_country_year <- function(df, code_col = NULL) {
  if (!is.null(code_col) && code_col %in% names(df)) {
    df <- df %>%
      filter(!is.na(.data[[code_col]]), .data[[code_col]] != "")
  }

  df %>%
    pivot_longer(
      cols = matches("^\\d{4}$"),
      names_to = "year",
      values_to = "value"
    ) %>%
    mutate(
      year = as.integer(year),
      value = if_else(is.na(value), NA_character_, as.character(value)),
      value = na_if(value, ""),
      value = na_if(value, "xxx"),
      value = na_if(value, "..."),
      value = gsub("[,%]", "", value),
      value = as.numeric(value)
    )
}

defence_df <- reshape_country_year(defence_df, code_col = "Code") %>%
    rename(defence_pct = value) %>%
    rename(code = Code) %>%
    select(c(code, year, defence_pct))

health_df <- reshape_country_year(health_df, code_col = "Country Code") %>%
    rename(health_pct = value) %>%
    rename(code = "Country Code") %>%
    select(c(code, year, health_pct))

gdp_df <- reshape_country_year(gdp_df, code_col = "Country Code") %>% 
    rename(gdp_percap = value) %>%
    rename(code = "Country Code") %>%
    select(c(code, year, gdp_percap))


# Merge datasets
master_df <- systems_df %>%
  left_join(defence_df, by = c("code" = "code")) %>%
  left_join(health_df, by = c("code" = "code", "year" = "year")) %>%
  left_join(gdp_df, by = c("code" = "code", "year" = "year")) 


# Filter for desired years
master_df <- master_df %>%
    filter(year > 1999)

# Calculate lagged variables
master_df <- master_df %>%
    group_by(country) %>%
    mutate(change_def = defence_pct - lag(defence_pct)) %>%
    mutate(change_health = health_pct - lag(health_pct)) %>%
    mutate(change_def = round(change_def/lag(defence_pct), 4)) %>%
    mutate(change_health = round(change_health/lag(health_pct), 4)) %>%
    ungroup()

# Save processed data
write_csv(master_df, "processed_data/primary_analysis.csv", na = "")
