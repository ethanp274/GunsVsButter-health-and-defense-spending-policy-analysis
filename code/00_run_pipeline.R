#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# RUN THE COMPLETE HEALTH AND DEFENCE SPENDING PIPELINE
# Harry Rourke & Ethan Phillips
# Last updated: 2026-08-13
# Core analysis years: 2000-2025; 1999 is read only for first-year changes/debt
# Headline sequence: pooled -> random-intercept -> moderation -> fully adjusted
# GEE and optimizer diagnostics remain sensitivity checks, not routine pipeline steps
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Run this script from the repository root:
# Rscript code/00_run_pipeline.R

# Check and install all packages used by the pipeline before running any stage.
# This keeps a fresh R installation from failing part-way through the workflow
# and makes the pipeline reproducible across machines.
required_packages <- c(
  "broom",
  "broom.mixed",
  "commonmark",
  "dplyr",
  "geepack",
  "ggplot2",
  "lme4",
  "nlme",
  "readr",
  "readxl",
  "tidyr"
)

missing_packages <- required_packages[
  !vapply(
    required_packages,
    requireNamespace,
    logical(1),
    quietly = TRUE
  )
]

if (length(missing_packages) > 0) {
  cat(
    "Installing missing R packages: ",
    paste(missing_packages, collapse = ", "),
    "\n",
    sep = ""
  )

  install.packages(
    missing_packages,
    repos = "https://cloud.r-project.org",
    dependencies = TRUE
  )
}

still_missing <- required_packages[
  !vapply(
    required_packages,
    requireNamespace,
    logical(1),
    quietly = TRUE
  )
]

if (length(still_missing) > 0) {
  stop(
    "The following required R packages could not be installed: ",
    paste(still_missing, collapse = ", ")
  )
}

# Keep the stage order explicit so the pipeline builds the panel first, then
# fits the main models, runs robustness checks, writes figures, and finally
# generates the human-readable summary from the saved outputs.
pipeline_steps <- c(
  "code/01_data_processing.R",
  "code/02_analysis.R",
  "code/03_sensitivity_analyses.R",
  "code/04_visualisation.R",
  "code/05_results_summary.R",
  "code/07_render_data_dictionary.R"
)


# Check that the script was started from the repository root so all relative
# file paths resolve correctly and the generated outputs land in the expected
# folders.
missing_steps <- pipeline_steps[!file.exists(pipeline_steps)]

if (length(missing_steps) > 0) {
  stop(
    "Run this script from the repository root. Missing: ",
    paste(missing_steps, collapse = ", ")
  )
}

# All contents of results/ are generated. Clear them before a full run so a
# publication-facing results directory cannot retain stale files from an older
# analysis. Each downstream stage recreates the directories it owns.
results_dir <- "results"
if (dir.exists(results_dir)) {
  unlink(list.files(results_dir, full.names = TRUE), recursive = TRUE)
}
dir.create(results_dir, showWarnings = FALSE)

# Run each stage in a fresh R session and stop if any stage fails
rscript_command <- file.path(
  R.home("bin"),
  if (.Platform$OS.type == "windows") "Rscript.exe" else "Rscript"
)

for (step in pipeline_steps) {
  cat("\nRunning ", step, "...\n", sep = "")
  flush.console()

  exit_status <- system2(
    command = rscript_command,
    args = shQuote(step)
  )

  if (exit_status != 0) {
    stop("Pipeline stopped because ", step, " failed.")
  }
}

cat("\nPipeline completed successfully.\n")
