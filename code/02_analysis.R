#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# MAIN ANALYSIS OF HEALTH AND DEFENSE SPENDING TRADEOFF   
# Harry Rourke & Ethan Phillips                                
# Last updated: 2026-06-27                                   
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Load packages

library(tidyr)
library(dplyr)
library(lme4)

# Load processed data
master_df <- read_csv("./processed_data/primary_analysis.csv", na = c(""))

# Prepare variables
master_df$system <- as.factor(master_df$system)
master_df$region <- as.factor(master_df$region)
master_df$country <- as.factor(master_df$country)

# Run preliminary analysis
main_model <- glmer(
    change_health ~ change_def + change_def:system + (1 | country),
    data = master_df
)

print(summary(main_model))



# Save analysis results