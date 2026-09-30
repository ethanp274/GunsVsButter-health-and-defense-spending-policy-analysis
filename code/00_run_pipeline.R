#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# RUN THE COMPLETE HEALTH AND DEFENCE SPENDING PIPELINE
# HR & EP
# Last updated: 2026-08-13
# Core analysis years: 2000-2025; 1999 is read only for first-year changes/debt
# Headline sequence: pooled -> random-intercept -> moderation -> fully adjusted
# GEE and optimizer diagnostics remain sensitivity checks, not routine pipeline steps
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Run this script from the repository root:
# Rscript code/00_run_pipeline.R

# The project profile activates renv for the command the user launches. Restart
# once without profile startup, carrying that active project library forward,
# so package checks and analysis stages do not repeatedly pay the startup cost.
if (!identical(Sys.getenv("PIPELINE_RENV_BOOTSTRAPPED"), "true")) {
  rscript_command <- file.path(
    R.home("bin"),
    if (.Platform$OS.type == "windows") "Rscript.exe" else "Rscript"
  )

  pipeline_status <- system2(
    command = rscript_command,
    args = c("--no-init-file", shQuote("code/00_run_pipeline.R")),
    env = c(
      paste0("R_LIBS_USER=", .libPaths()[1]),
      "PIPELINE_RENV_BOOTSTRAPPED=true"
    )
  )

  quit(save = "no", status = pipeline_status)
}

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

# Keep existing generated files in place. Pipeline stages overwrite outputs
# with the same filenames and create any missing output directories.
results_dir <- "results"
dir.create(results_dir, showWarnings = FALSE)

# Run stages in isolated environments in this R session. This avoids repeated
# R startup and renv activation while keeping objects from one stage from
# leaking into the next.
for (step in pipeline_steps) {
  cat("\nRunning ", step, "...\n", sep = "")
  flush.console()

  stage_environment <- new.env(parent = globalenv())
  tryCatch(
    sys.source(step, envir = stage_environment),
    error = function(error) {
      stop("Pipeline stopped because ", step, " failed: ", error$message)
    }
  )
}

cat("\nPipeline completed successfully.\n")
