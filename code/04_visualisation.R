#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# VISUALISATION OF HEALTH AND DEFENSE SPENDING TRADEOFF
# Harry Rourke & Ethan Phillips
# Last updated: 2026-08-05
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Load packages
suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(readr)
  library(tidyr)
})


# Load processed data
master_df <- read_csv("processed_data/primary_analysis.csv", na = c(""), show_col_types = FALSE)

results_dir <- "results"
dir.create(results_dir, showWarnings = FALSE)

excluded_analysis_years <- c(2020L, 2021L)
analysis_end_year <- max(master_df$year, na.rm = TRUE)

plot_master_df <- master_df %>%
  filter(
    year <= analysis_end_year,
    !year %in% excluded_analysis_years
  )


# Prepare plot data
plot_df <- plot_master_df %>%
  select(country, year, health_def_ratio)

country_labels <- plot_df %>%
  filter(!is.na(health_def_ratio)) %>%
  group_by(country) %>%
  slice_max(year, n = 1, with_ties = FALSE) %>%
  ungroup() %>%
  arrange(health_def_ratio)

label_gap <- 0.35
label_y <- country_labels$health_def_ratio
for (i in seq_along(label_y)[-1]) {
  label_y[i] <- max(label_y[i], label_y[i - 1] + label_gap)
}

country_labels <- country_labels %>%
  mutate(
    label_year = max(plot_df$year, na.rm = TRUE) + 0.45,
    label_y = label_y
  )


# Plot health-to-defence spending ratio over time
health_def_ratio_plot <- plot_df %>%
  ggplot(aes(x = year, y = health_def_ratio, group = country, colour = country)) +
  geom_line(linewidth = 0.7, alpha = 0.85) +
  geom_point(size = 1, alpha = 0.7, na.rm = TRUE) +
  geom_segment(
    data = country_labels,
    aes(
      x = year,
      xend = label_year - 0.08,
      y = health_def_ratio,
      yend = label_y
    ),
    linewidth = 0.25,
    alpha = 0.65,
    show.legend = FALSE
  ) +
  geom_label(
    data = country_labels,
    aes(x = label_year, y = label_y, label = country),
    hjust = 0,
    size = 2.2,
    label.size = 0.15,
    label.padding = unit(0.12, "lines"),
    fill = "white",
    alpha = 0.9,
    show.legend = FALSE
  ) +
  scale_x_continuous(
    breaks = seq(
      min(plot_df$year, na.rm = TRUE),
      max(plot_df$year, na.rm = TRUE),
      by = 2
    ),
    limits = c(
      min(plot_df$year, na.rm = TRUE),
      max(plot_df$year, na.rm = TRUE) + 5
    )
  ) +
  coord_cartesian(clip = "off") +
  labs(
    title = "Health-to-Defence Spending Ratio Over Time",
    subtitle = paste(
      "Ratio of health spending share of GDP to defence spending share of GDP;",
      "2020-2021 excluded"
    ),
    x = "Year",
    y = "Health-to-defence spending ratio",
    colour = "Country"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 16),
    plot.subtitle = element_text(size = 10),
    legend.position = "none",
    panel.grid.minor = element_blank(),
    plot.background = element_rect(fill = "white", colour = NA),
    panel.background = element_rect(fill = "white", colour = NA),
    plot.margin = margin(10, 130, 10, 10)
  )


# Save plot
ggsave(
  filename = file.path(results_dir, "health_def_ratio_timeseries.png"),
  plot = health_def_ratio_plot,
  width = 14,
  height = 8,
  dpi = 300,
  bg = "white"
)

ggsave(
  filename = file.path(results_dir, "health_def_ratio_timeseries.pdf"),
  plot = health_def_ratio_plot,
  width = 14,
  height = 8,
  bg = "white"
)

cat("Saved health_def_ratio time-series plot to results/health_def_ratio_timeseries.png and .pdf\n")


# Plot average health and defence spending as a share of GDP by health-system type
system_spend_df <- plot_master_df %>%
  mutate(
    system_label = case_when(
      system == "BEV" ~ "Beveridge",
      system == "BIS" ~ "Bismarck",
      TRUE ~ system
    )
  ) %>%
  group_by(system_label, year) %>%
  summarise(
    health_pct_gdp = if_else(
      all(is.na(health_pct_gdp)),
      NA_real_,
      mean(health_pct_gdp, na.rm = TRUE)
    ),
    defence_pct_gdp = if_else(
      all(is.na(defence_pct_gdp)),
      NA_real_,
      mean(defence_pct_gdp, na.rm = TRUE)
    ),
    .groups = "drop"
  ) %>%
  pivot_longer(
    cols = c(health_pct_gdp, defence_pct_gdp),
    names_to = "spending_type",
    values_to = "spending_pct_gdp"
  ) %>%
  mutate(
    spending_label = case_when(
      spending_type == "health_pct_gdp" ~ "Health",
      spending_type == "defence_pct_gdp" ~ "Defence",
      TRUE ~ spending_type
    ),
    line_label = paste(system_label, spending_label)
  )

system_spend_labels <- system_spend_df %>%
  group_by(line_label) %>%
  slice_max(year, n = 1, with_ties = FALSE) %>%
  ungroup() %>%
  mutate(label_year = max(system_spend_df$year, na.rm = TRUE) + 0.35)

system_spend_plot <- system_spend_df %>%
  ggplot(
    aes(
      x = year,
      y = spending_pct_gdp,
      group = line_label,
      colour = line_label,
      linetype = spending_label
    )
  ) +
  geom_line(linewidth = 1) +
  geom_point(size = 1.8, na.rm = TRUE) +
  geom_segment(
    data = system_spend_labels,
    aes(
      x = year,
      xend = label_year - 0.08,
      y = spending_pct_gdp,
      yend = spending_pct_gdp
    ),
    linewidth = 0.3,
    show.legend = FALSE
  ) +
  geom_label(
    data = system_spend_labels,
    aes(x = label_year, label = line_label),
    hjust = 0,
    size = 3,
    label.size = 0.15,
    label.padding = unit(0.15, "lines"),
    fill = "white",
    show.legend = FALSE
  ) +
  scale_colour_manual(
    values = c(
      "Beveridge Defence" = "#1f77b4",
      "Beveridge Health" = "#2ca02c",
      "Bismarck Defence" = "#ff7f0e",
      "Bismarck Health" = "#d62728"
    )
  ) +
  scale_y_continuous(
    labels = function(x) paste0(round(x * 100, 1), "%")
  ) +
  scale_x_continuous(
    breaks = seq(
      min(system_spend_df$year, na.rm = TRUE),
      max(system_spend_df$year, na.rm = TRUE),
      by = 2
    ),
    limits = c(
      min(system_spend_df$year, na.rm = TRUE),
      max(system_spend_df$year, na.rm = TRUE) + 4
    )
  ) +
  coord_cartesian(clip = "off") +
  labs(
    title = "Average Health and Defence Spending as a Share of GDP",
    subtitle = paste0(
      "Beveridge and Bismarck country averages, ",
      min(system_spend_df$year, na.rm = TRUE),
      "-",
      max(system_spend_df$year, na.rm = TRUE),
      "; 2020-2021 excluded"
    ),
    x = "Year",
    y = "Average spending as a share of GDP"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 16),
    plot.subtitle = element_text(size = 10),
    legend.position = "none",
    panel.grid.minor = element_blank(),
    plot.background = element_rect(fill = "white", colour = NA),
    panel.background = element_rect(fill = "white", colour = NA),
    plot.margin = margin(10, 130, 10, 10)
  )

ggsave(
  filename = file.path(results_dir, "system_avg_spending_pct_gdp_timeseries.png"),
  plot = system_spend_plot,
  width = 12,
  height = 7,
  dpi = 300,
  bg = "white"
)

ggsave(
  filename = file.path(results_dir, "system_avg_spending_pct_gdp_timeseries.pdf"),
  plot = system_spend_plot,
  width = 12,
  height = 7,
  bg = "white"
)

cat("Saved system-average spending time-series plot to results/system_avg_spending_pct_gdp_timeseries.png and .pdf\n")
