
# ------------------------------------------------------------
# Function: render_bcws_quarterly_comparisons
# Purpose : Render the SFP comparison RMarkdown report using params
# Notes   : Designed for reuse and automation
# ------------------------------------------------------------

render_bcws_quarterly_comparisons <- function(
    old_data,
    new_data,
    subline,
    rmd_file,
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
    old_data  = old_data,
    new_data  = new_data,
    subline   = subline,
    output_dir = output_dir
  )


  # -----------------------------
  # Ensure output directory exists
  # -----------------------------
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  # -----------------------------
  # Ensure rmd file exists
  # -----------------------------
  if (!file.exists(rmd_file)) {
    stop("Rmd file does not exist: ", rmd_file)
  }

  # -----------------------------
  # Render (discard HTML)
  # -----------------------------
  message("Rendering report for subline: ", subline)

  tryCatch({
    rmarkdown::render(
      input       = rmd_file,
      params      = params_list,
      output_file = tempfile(pattern = "ignore_", fileext = ".html"),
      output_dir  = tempdir(),
      envir       = new.env(),
      quiet       = FALSE
    )
  }, error = function(e) {
    stop("Render failed: ", e$message)
  })

  # -----------------------------
  # Expected Excel path
  # -----------------------------
  safe_subline <- gsub("[^A-Za-z0-9_]", "_", subline)

  output_excel <- paste0(
    "BCWS_Drive_Comparison_Report_",
    safe_subline,
    ".xlsx"
  )

  excel_path <- file.path(
    output_dir,
    output_excel
  )

  # Verify workbook was created
  if (!file.exists(excel_path)) {
    stop("Excel file was not created: ", excel_path)
  }

  message("Excel report created: ", excel_path)

  return(excel_path)
}

message("Start report rendering...")
message("Starting SFP report...")
report1 <- render_bcws_quarterly_comparisons(
  old_data = here::here(
    "source/archival_source", # Human: double check your file location
    "2025_09_26_BCWS_SFP_Enhanced_Data.csv"
  ),
  new_data = here::here(
    "source/archival_source", # Human: double check your file location
    "2026-03-31_BCWS_SFP_Enhanced_Data.csv"
  ),
  subline = "2025-Sept_to_2026-Mar", # Human: double check your comparison dates
  rmd_file = "bcws/bcws_quarterly_comparisons.Rmd"
)

message("Starting Training report...")
report2 <- render_bcws_quarterly_comparisons(
  old_data = here::here(
    "source/archival_source", # Human: double check your file location
    "2025-09-18_bcwsdata_training.csv"
  ),
  new_data = here::here(
    "source/archival_source", # Human: double check your file location
    "bcws_training_report_2026-04-15.csv"
  ),
  subline = "Training_2025-Sept_to_2026-Mar", # Human: double check your comparison dates
  rmd_file = "bcws/bcws_training_quarterly_comparisons.Rmd"
)

message("Created:")
message(report1)
message(report2)
