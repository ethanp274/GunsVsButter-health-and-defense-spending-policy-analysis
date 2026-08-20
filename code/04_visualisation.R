#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# VISUALISATION OF HEALTH AND DEFENCE SPENDING TRADEOFF
# Harry Rourke & Ethan Phillips
# Last updated: 2026-08-13
# Result figures use the headline model estimates and interaction slopes
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Load packages
suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(readr)
  library(tidyr)
})

plot_theme <- function() {
  theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(face = "bold", size = 15, colour = "#1f2933"),
      plot.subtitle = element_text(size = 10, colour = "#52606d"),
      axis.title = element_text(colour = "#1f2933", size = 11),
      axis.text = element_text(colour = "#1f2933", size = 9),
      legend.title = element_text(colour = "#1f2933", size = 10),
      legend.text = element_text(colour = "#1f2933", size = 9),
      panel.grid.major = element_line(colour = "#e5e7eb", linewidth = 0.35),
      panel.grid.minor = element_blank(),
      panel.background = element_rect(fill = "white", colour = NA),
      plot.background = element_rect(fill = "white", colour = NA),
      legend.position = "bottom"
    )
}

# Set the common colour palette for the system and spending-time-series plots.
viz_palette <- c(
  "Beveridge" = "#2c7fb8",
  "Bismarck" = "#d95f0e",
  "Health" = "#2c7fb8",
  "Defence" = "#d95f0e"
)

# Read the machine-generated model outputs so the figures stay aligned with the
# fitted results rather than manually typed estimates.
main_model_coefficients <- read_csv("results/main_model_coefficients.csv", show_col_types = FALSE)
main_interaction_slopes <- read_csv("results/main_interaction_slopes.csv", show_col_types = FALSE)

results_dir <- "results"
dir.create(results_dir, showWarnings = FALSE)

# Load processed data for the original descriptive plots
master_df <- read_csv("processed_data/primary_analysis.csv", na = c(""), show_col_types = FALSE)

excluded_analysis_years <- c(2020L, 2021L)
analysis_end_year <- max(master_df$year, na.rm = TRUE)

plot_master_df <- master_df %>%
  filter(
    year <= analysis_end_year,
    !year %in% excluded_analysis_years
  )

# Original plot 1: health-to-defence spending ratio over time.
# This panel tracks each country's ratio while showing the COVID gap as a shaded
# exclusion band so the primary-analysis sample is visually clear.
plot_df <- plot_master_df %>%
  select(country, year, health_def_ratio)

country_style_map <- tibble(
  country = sort(unique(plot_df$country)),
  country_line_type = rep(c("solid", "dashed"), length.out = dplyr::n_distinct(plot_df$country)),
  country_colour = colorRampPalette(c("#1f77b4", "#2ca02c", "#ff7f0e", "#d62728", "#9467bd", "#17becf", "#8c564b", "#bcbd22", "#e377c2", "#7f7f7f"))(dplyr::n_distinct(plot_df$country))
)

plot_df <- plot_df %>%
  left_join(country_style_map, by = "country")

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
  left_join(country_style_map, by = "country") %>%
  mutate(
    label_year = max(plot_df$year, na.rm = TRUE) + 0.45,
    label_y = label_y
  )

covid_excluded_rect <- tibble(
  xmin = 2019.5,
  xmax = 2021.5,
  ymin = -Inf,
  ymax = Inf
)

health_def_ratio_plot <- ggplot(
  data = plot_df,
  aes(x = year, y = health_def_ratio, group = country, colour = country)
) +
  geom_rect(
    data = covid_excluded_rect,
    aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
    inherit.aes = FALSE,
    fill = "#b0b7c3",
    alpha = 0.18,
    show.legend = FALSE
  ) +
  geom_line(aes(linetype = country_line_type), linewidth = 0.7, alpha = 0.85) +
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
  scale_colour_manual(values = setNames(country_style_map$country_colour, country_style_map$country)) +
  scale_linetype_manual(values = c("solid" = "solid", "dashed" = "dashed")) +
  labs(
    title = "Health-to-defence spending ratio over time",
    subtitle = paste(
      "Ratio of health spending share of GDP to defence spending share of GDP;",
      "2020-2021 excluded"
    ),
    x = "Year",
    y = "Health-to-defence spending ratio",
    colour = "Country"
  ) +
  plot_theme() +
  theme(
    legend.position = "none",
    plot.margin = margin(10, 130, 10, 10)
  )

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

# Original plot 2: average health and defence spending as a share of GDP by
# health-system type. The lines separate system-level averages and spending type
# while keeping the same styling conventions as the other plots.
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
      colour = system_label,
      linetype = spending_label
    )
  ) +
  geom_rect(
    data = covid_excluded_rect,
    aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
    inherit.aes = FALSE,
    fill = "#b0b7c3",
    alpha = 0.18,
    show.legend = FALSE
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
      "Beveridge" = "#2c7fb8",
      "Bismarck" = "#d95f0e"
    )
  ) +
  scale_linetype_manual(values = c("Health" = "solid", "Defence" = "dashed")) +
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
    title = "Average health and defence spending as a share of GDP",
    subtitle = paste0(
      "Beveridge and Bismarck country averages, ",
      min(system_spend_df$year, na.rm = TRUE),
      "-",
      max(system_spend_df$year, na.rm = TRUE),
      "; 2020-2021 excluded"
    ),
    x = "Year",
    y = "Average spending as a share of GDP",
    colour = "System / spending",
    linetype = "Spending type"
  ) +
  plot_theme() +
  theme(
    legend.position = "none",
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

# New plot 1: forest plot of key coefficients in the fully adjusted mixed model.
# This summary focuses on the core terms for interpretation without crowding the
# graphic with the full year-effects block.
forest_df <- main_model_coefficients %>%
  filter(
    model == "model_5_fully_adjusted",
    term %in% c(
      "defence_change_10pct",
      "previous_debt_10pp_c",
      "log2_gdp_percap_c",
      "defence_change_10pct:systemBIS",
      "defence_change_10pct:previous_debt_10pp_c"
    )
  ) %>%
  mutate(
    term_label = case_when(
      term == "defence_change_10pct" ~ "Defence change",
      term == "previous_debt_10pp_c" ~ "Previous debt",
      term == "log2_gdp_percap_c" ~ "GDP per capita",
      term == "defence_change_10pct:systemBIS" ~ "Defence change x Bismarck",
      term == "defence_change_10pct:previous_debt_10pp_c" ~ "Defence change x debt",
      TRUE ~ term
    ),
    term_order = factor(term_label, levels = rev(c(
      "Defence change",
      "Defence change x Bismarck",
      "Defence change x debt",
      "Previous debt",
      "GDP per capita"
    )))
  ) %>%
  arrange(term_order)

forest_plot <- ggplot(forest_df, aes(y = term_order, x = estimate)) +
  geom_vline(xintercept = 0, linetype = "dashed", colour = "#52606d") +
  geom_errorbarh(
    aes(xmin = conf_low, xmax = conf_high),
    height = 0.25,
    linewidth = 0.7,
    colour = "#2c3e50"
  ) +
  geom_point(size = 3.2, colour = "#2c7fb8") +
  labs(
    title = "Headline model coefficients",
    subtitle = "Fully adjusted mixed model, 2000-2025 excluding 2020-2021",
    x = "Estimated coefficient",
    y = NULL
  ) +
  plot_theme() +
  theme(
    axis.text.y = element_text(size = 10),
    axis.title.x = element_text(size = 11)
  )

ggsave(
  filename = file.path(results_dir, "main_model_forest_plot.png"),
  plot = forest_plot,
  width = 9,
  height = 5,
  dpi = 300,
  bg = "white"
)

ggsave(
  filename = file.path(results_dir, "main_model_forest_plot.pdf"),
  plot = forest_plot,
  width = 9,
  height = 5,
  bg = "white"
)

cat("Saved headline forest plot to results/main_model_forest_plot.png and .pdf\n")

# New plot 2: marginal-effects plot for defence-change slopes across debt values
# by health-system type. The figure turns the interaction into a more readable
# slope summary across the observed debt range.
slopes_df <- main_interaction_slopes %>%
  mutate(
    system_label = if_else(system == "BEV", "Beveridge", "Bismarck")
  )

slopes_plot <- ggplot(
  slopes_df,
  aes(x = previous_debt_pct_gdp, y = estimate, colour = system_label)
) +
  geom_ribbon(
    aes(ymin = conf_low, ymax = conf_high, fill = system_label),
    alpha = 0.12,
    colour = NA
  ) +
  geom_line(linewidth = 1.1) +
  geom_point(size = 2.3) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "#52606d") +
  scale_colour_manual(values = c("Beveridge" = "#2c7fb8", "Bismarck" = "#d95f0e")) +
  scale_fill_manual(values = c("Beveridge" = "#2c7fb8", "Bismarck" = "#d95f0e")) +
  labs(
    title = "Defence-change association by public debt and health-system type",
    subtitle = "Estimated slope of health-spending change per 10% relative defence increase",
    x = "Previous-year public debt (% of GDP)",
    y = "Estimated association",
    colour = "Health system",
    fill = "Health system"
  ) +
  plot_theme()

ggsave(
  filename = file.path(results_dir, "main_interaction_slopes_plot.png"),
  plot = slopes_plot,
  width = 9,
  height = 6,
  dpi = 300,
  bg = "white"
)

ggsave(
  filename = file.path(results_dir, "main_interaction_slopes_plot.pdf"),
  plot = slopes_plot,
  width = 9,
  height = 6,
  bg = "white"
)

cat("Saved interaction slopes plot to results/main_interaction_slopes_plot.png and .pdf\n")

# New plot 3: system-level annual-change scatter with model-predicted trendlines
# Points are system-level (Beveridge/Bismarck) yearly averages of annual
# defence-change (x) and health-change (y). Trendlines use the fully-adjusted
# model slope estimated at the median previous-year debt for each system.
system_change_df <- plot_master_df %>%
  # Ensure the change variables exist in the plotting frame. Use the same
  # transformations as the analysis scripts so derived measures match.
  mutate(
    defence_change_10pct = if_else(!is.na(change_def_gdp), change_def_gdp / 0.10, NA_real_),
    health_change_percent = if_else(!is.na(change_health_gdp), 100 * change_health_gdp, NA_real_),
    system_label = case_when(
      system == "BEV" ~ "Beveridge",
      system == "BIS" ~ "Bismarck",
      TRUE ~ as.character(system)
    )
  ) %>%
  group_by(system_label, year) %>%
  summarise(
    mean_defence_change_10pct = mean(defence_change_10pct, na.rm = TRUE),
    mean_health_change_percent = mean(health_change_percent, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  filter(!is.na(mean_defence_change_10pct), !is.na(mean_health_change_percent))

# Grab the median-debt slopes from the interaction slopes table produced by
# the analysis step. Handle common label variants for the 50th percentile.
median_slopes <- main_interaction_slopes %>%
  filter(grepl("50", debt_percentile)) %>%
  transmute(
    system = if_else(system == "BEV", "Beveridge", "Bismarck"),
    slope = estimate,
    slope_low = conf_low,
    slope_high = conf_high
  )

# If the median row wasn't found by label, fall back to the middle quantile by
# taking the median previous-debt value per system.
if (nrow(median_slopes) < 2) {
  median_slopes <- main_interaction_slopes %>%
    group_by(system) %>%
    slice_min(abs(previous_debt_pct_gdp - median(previous_debt_pct_gdp, na.rm = TRUE)), n = 1) %>%
    ungroup() %>%
    transmute(
      system = if_else(system == "BEV", "Beveridge", "Bismarck"),
      slope = estimate,
      slope_low = conf_low,
      slope_high = conf_high
    )
}

# Compute intercepts so trendlines pass through each system's mean point.
intercepts <- system_change_df %>%
  group_by(system_label) %>%
  summarise(
    mean_x = mean(mean_defence_change_10pct, na.rm = TRUE),
    mean_y = mean(mean_health_change_percent, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  left_join(median_slopes, by = c("system_label" = "system")) %>%
  mutate(
    intercept = mean_y - slope * mean_x,
    intercept_low = mean_y - slope_low * mean_x,
    intercept_high = mean_y - slope_high * mean_x
  )

scatter_plot <- ggplot(system_change_df, aes(x = mean_defence_change_10pct, y = mean_health_change_percent, colour = system_label)) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "#52606d") +
  geom_vline(xintercept = 0, linetype = "dashed", colour = "#52606d") +
  geom_point(size = 3, alpha = 0.9) +
  # Add main trendlines from the fully-adjusted model at median debt
  geom_abline(
    data = intercepts,
    aes(slope = slope, intercept = intercept, colour = system_label),
    linewidth = 1.1
  ) +
  # Add dashed lines for the slope confidence bounds
  geom_abline(
    data = intercepts,
    aes(slope = slope_low, intercept = intercept_low, colour = system_label),
    linetype = "dashed",
    alpha = 0.45
  ) +
  geom_abline(
    data = intercepts,
    aes(slope = slope_high, intercept = intercept_high, colour = system_label),
    linetype = "dashed",
    alpha = 0.45
  ) +
  scale_colour_manual(values = c("Beveridge" = viz_palette[["Beveridge"]], "Bismarck" = viz_palette[["Bismarck"]])) +
  labs(
    title = "System-level annual changes: Defence vs Health",
    subtitle = "Yearly system averages; trendlines show model slope at median previous-year debt",
    x = "Mean defence change (per 10% relative increase)",
    y = "Mean health change (percentage points)",
    colour = "System"
  ) +
  plot_theme()

ggsave(
  filename = file.path(results_dir, "system_change_scatter.png"),
  plot = scatter_plot,
  width = 9,
  height = 6,
  dpi = 300,
  bg = "white"
)

ggsave(
  filename = file.path(results_dir, "system_change_scatter.pdf"),
  plot = scatter_plot,
  width = 9,
  height = 6,
  bg = "white"
)

cat("Saved system-change scatter plot to results/system_change_scatter.png and .pdf\n")
