library(here)
library(rmarkdown)
library(openxlsx)
library(glue)

# load custom functions from external scripts
source(here("scripts", glue('custom_bcws_functions.R')), local = knitr::knit_global())
source(here("scripts", glue("bcws_accountability.R")), local = knitr::knit_global())

# ------------------------------------------------------------
# Function: render_bcws_programarea_comparisons
# Purpose : Render the SFP and Training comparison RMarkdown reports using params
# Notes   : Added `envir` parameter to fix scoping issues
# ------------------------------------------------------------
render_bcws_quarterly_comparisons <- function(
    old_data,
    new_data,
    rmd_file,
    envir, # Accepts the targeted environment
    output_dir = NULL
) {

  if (is.null(output_dir)) {
    output_dir <- here::here("output")
  }

  if (!requireNamespace("rmarkdown", quietly = TRUE)) {
    stop("Package 'rmarkdown' is required but not installed.")
  }

  if (!requireNamespace("here", quietly = TRUE)) {
    stop("Package 'here' is required but not installed.")
  }

  if (!file.exists(old_data)) {
    stop("old_data file does not exist: ", old_data)
  }

  if (!file.exists(new_data)) {
    stop("new_data file does not exist: ", new_data)
  }

  if (Sys.getenv("RSTUDIO_PANDOC") == "") {
    pandoc_path <- "C:/Program Files/RStudio/bin/"
    if (dir.exists(pandoc_path)) {
      Sys.setenv(RSTUDIO_PANDOC = pandoc_path)
    }
  }

  params_list <- list(
    old_data  = old_data,
    new_data  = new_data,
    output_dir = output_dir
  )

  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  if (!file.exists(rmd_file)) {
    stop("Rmd file does not exist: ", rmd_file)
  }

  # Only render ONCE per function call, passing the assigned environment
  tryCatch({
    rmarkdown::render(
      input       = rmd_file,
      params      = params_list,
      output_file = tempfile(pattern = "ignore_", fileext = ".html"),
      output_dir  = tempdir(),
      envir       = envir, # Correctly mapped to passed environment
      quiet       = FALSE
    )
  }, error = function(e) {
    stop("Render failed: ", e$message)
  })

}

# =========================================================================
# 1. Initialize a single consolidated workbook
# =========================================================================
excel <- createWorkbook()
comparison_dates = "2026-03-31_vs_2026-09-30" # Human: update this each time the report is run
output_file <- here::here("output", paste0("BCWS_ProgramAreas_Comparison_Report_",comparison_dates,".xlsx"))

# =========================================================================
# 2. RENDER & EXTRACT FROM THE FIRST .Rmd (7 Data Frames -> 7 Sheets)
# =========================================================================
env_rmd0 <- new.env()

message("Starting SFP Fire Centre report...")
report0 <- render_bcws_quarterly_comparisons(
  old_data = here::here("source/archival_source", "2026-03-31_BCWS_SFP_Enhanced_Data.csv"), # Human: update this each time the report is run
  new_data = here::here("source", "2026-09-30_BCWS_SFP_Enhanced_Data.csv"), # Human: update this each time the report is run
  rmd_file = here::here("scripts/bcws_fc_quarterly_comparisons.Rmd"),
  envir = env_rmd0
)

# Extract data frames directly from env_rmd0
fc_reports <- env_rmd0$fc_reports_1

# create sheet names - done in bcws_fc_quarterly_comparisons.Rmd

# add worksheets to workbook
for (sheet_name in names(fc_reports)) {
  sheet.names(sheet_name)
}

# assign data tables to worksheets
for (i in seq_along(fc_reports)) {
  dt.worksheets(i, fc_reports[[i]])
}

# freeze top row of all sheets

for (i in seq_along(fc_reports)) {
  freeze.panes(i)
}

# (Optional) Add filter
for (i in seq_along(fc_reports)) {
  column.filter(i)
}

# set conditional colour format on columns 7, 10, 13, and 15 for values < 0
for (i in seq_along(fc_reports)) {
  cond.colour(i, nrow(fc_reports[[i]]))
}

# set custom column widths for all sheets
for (i in seq_along(fc_reports)) {

  setColWidths(
    excel,
    sheet = i,
    cols = c(1, 2, 3, 4, 5, 6:14),
    widths = c(20, 36, 36, 15, 75, 25, 25, 25, 25, 25, 25, 25, 25)
  )

}

# =========================================================================
# 3. RENDER & EXTRACT FROM THE SECOND .Rmd (2 Data Frames -> 2 Sheets)
# =========================================================================
env_rmd1 <- new.env()

message("Starting SFP Program Area report...")
report1 <- render_bcws_quarterly_comparisons(
  old_data = here::here("source/archival_source", "2026-03-31_BCWS_SFP_Enhanced_Data.csv"), # Human: update this each time the report is run
  new_data = here::here("source", "2026-09-30_BCWS_SFP_Enhanced_Data.csv"), # Human: update this each time the report is run
  rmd_file = here::here("scripts/bcws_quarterly_comparisons1.Rmd"),
  envir = env_rmd1
)

# Extract data frames directly from env_rmd1
# Note: This assumes 'joined_totals' is a list inside your Rmd containing these items
df1_a <- env_rmd1$joined_totals$hq_victoria
df1_b <- env_rmd1$joined_totals$hq_kam_pwcc

# create sheet names
eighthSheet = "HQ Victoria S65011"
ninthSheet = "HQ Kamloops S65002"

# add worksheets to workbook
sheet.names(eighthSheet)
sheet.names(ninthSheet)

# assign data tables to worksheets
dt.worksheets(8, df1_a)
dt.worksheets(9, df1_b)

# freeze top row of all sheets
freeze.panes(8)
freeze.panes(9)

# (Optional) Add filter
column.filter(8)
column.filter(9)

# set conditional colour format on columns 7, 10, 13, and 15 for values < 0
cond.colour(8, nrow(df1_a))
cond.colour(9, nrow(df1_b))

# set currency format on column (not being used right now)
# currency.format(1, nrow(df1_a))
# currency.format(2, nrow(df1_b))

# set custom column widths for all sheets
column.width(8)
column.width(9)

# =========================================================================
# 4. RENDER & EXTRACT FROM THE THIRD .Rmd (1 Data Frame -> 1 Sheet)
# =========================================================================
env_rmd2 <- new.env()

message("Starting SAN Training report...")
report2 <- render_bcws_quarterly_comparisons(
  old_data = here::here("source/archival_source", "bcws_training_report_2026-04-15.csv"), # Human: update this each time the report is run
  new_data = here::here("source", "bcws_training_report_2026-09-22_1542.csv"), # Human: update this each time the report is run
  rmd_file = here::here("scripts/bcws_training_quarterly_comparisons1.Rmd"),
  envir = env_rmd2
)

# Extract data frame directly from env_rmd2
df2_main <- env_rmd2$join_totals

# create sheet names
tenthSheet = "Training Drive"

# add worksheets to workbook
sheet.names(tenthSheet)

# assign data tables to worksheets, apply filter across all sheets
dt.worksheets(10, df2_main)

# freeze top row of all sheets
freeze.panes(10)

# (Optional) Add filter
column.filter(10)

# Apply formats to Sheet 4 (Training)
sty1 <- createStyle(fontColour = "#000080")
conditionalFormatting(
  excel, sheet = 10, cols = c(7, 9, 13, 15, 19),
  rows = 2:(nrow(df2_main) + 1), rule = "<0", style = sty1
)

# set currency format on Sheet 4 (not being used right now)
# sty2 <- createStyle(numFmt = "$0.00")
# addStyle(excel, sheet = 4, sty2, rows = 2:(nrow(df2_main) + 1), cols = 8:13, gridExpand = TRUE)
setColWidths(excel, sheet = 10, cols = c(1:3, 4, 5:19), widths = c(36, 38, 15, 55, rep(25, 15)))

# =========================================================================
# Apply header styling to all worksheets
# =========================================================================

headerStyle <- createStyle(
  textDecoration = "bold",
  fgFill = "#4472C4",
  fontColour = "#FFFFFF",
  halign = "center",
  border = "bottom"
)

sheet_data <- c(
  fc_reports,
  list(
    df1_a,
    df1_b,
    df2_main
  )
)

for (i in seq_along(sheet_data)) {
  addStyle(
    wb = excel,
    sheet = i,
    style = headerStyle,
    rows = 1,
    cols = 1:ncol(sheet_data[[i]]),
    gridExpand = TRUE,
    stack = TRUE
  )
}

# =========================================================================
# 5. SAVE THE FINAL COMBINED EXCEL FILE
# =========================================================================
saveWorkbook(excel, file = output_file, overwrite = TRUE)
message("Workbook saved to: ", output_file)
