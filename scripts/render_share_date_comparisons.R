
# ------------------------------------------------------------
# Function: render_share_date_comparisons
# Purpose : Render the SFP comparison RMarkdown report using params
# Notes   : Designed for reuse and automation
# ------------------------------------------------------------

render_share_date_comparisons <- function(
    old_data,
    new_data,
    ministry,
    share,
    subline,
    rmd_file = "scripts/share_date_comparisons.Rmd",
    output_dir = NULL
) {

  # -----------------------------
  # Resolve output directory
  # -----------------------------
  if (is.null(output_dir)) {
    output_dir <- here::here("output")
  }

  # -----------------------------
  # Dependency checks
  # -----------------------------
  if (!requireNamespace("rmarkdown", quietly = TRUE)) {
    stop("Package 'rmarkdown' is required but not installed.")
  }

  if (!requireNamespace("here", quietly = TRUE)) {
    stop("Package 'here' is required but not installed.")
  }

  # -----------------------------
  # Input validation
  # -----------------------------
  if (!file.exists(old_data)) {
    stop("old_data file does not exist: ", old_data)
  }

  if (!file.exists(new_data)) {
    stop("new_data file does not exist: ", new_data)
  }

  # -----------------------------
  # Ensure Pandoc path (safe)
  # -----------------------------
  if (Sys.getenv("RSTUDIO_PANDOC") == "") {
    pandoc_path <- "C:/Program Files/RStudio/bin/"
    if (dir.exists(pandoc_path)) {
      Sys.setenv(RSTUDIO_PANDOC = pandoc_path)
    }
  }

  # -----------------------------
  # Params
  # -----------------------------
  params_list <- list(
    old_data = old_data,
    new_data = new_data,
    ministry = ministry,
    share    = share,
    subline  = subline,
    output_dir = output_dir
  )

  # -----------------------------
  # File naming
  # -----------------------------
  safe_subline <- gsub("[^A-Za-z0-9_]", "_", subline)

  output_excel <- paste0(
    ministry, "_",
    "SFP_Report_Comparison_",
    share, "_",
    safe_subline,
    ".xlsx"
  )

  # -----------------------------
  # Ensure output directory exists
  # -----------------------------
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  # -----------------------------
  # Render (discard HTML)
  # -----------------------------
  tryCatch({
    rmarkdown::render(
      input       = rmd_file,
      params      = params_list,
      output_file = tempfile(pattern = "ignore_", fileext = ".html"),
      output_dir  = tempdir(),
      envir       = new.env(),
      quiet       = TRUE
    )
  }, error = function(e) {
    stop("Render failed: ", e$message)
  })

  # -----------------------------
  # Return expected Excel path
  # -----------------------------
  return(file.path(output_dir, output_excel))
}

# ---- NOTES ----
# Ensure:
# 1. Working directory is project root (so here() works)
# 2. Input CSV files exist
# 3. custom_sfp_functions.R is present in /scripts

# example render, stating parameters
render_share_date_comparisons(
  here::here("source/archival_source", "2025-09-26_BCWS_SFP_Enhanced_Data.csv"),
  here::here("source", "2026-03-31_BCWS_SFP_Enhanced_Data.csv"),
  "BCWS",
  "S65002",
  "2025-09_vs_2026-03"
)
