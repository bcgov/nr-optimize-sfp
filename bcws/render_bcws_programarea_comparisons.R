library(here)
library(rmarkdown)
library(openxlsx)
library(glue)

# load custom functions from external scripts
source(here("bcws", glue('custom_bcws_functions.R')), local = knitr::knit_global())

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
# 2. RENDER & EXTRACT FROM THE FIRST .Rmd (3 Data Frames -> 3 Sheets)
# =========================================================================
env_rmd1 <- new.env()

message("Starting SFP report...")
report1 <- render_bcws_quarterly_comparisons(
  old_data = here::here("source/archival_source", "2026-03-31_BCWS_SFP_Enhanced_Data.csv"), # Human: update this each time the report is run
  new_data = here::here("source", "2026-09-30_BCWS_SFP_Enhanced_Data.csv"), # Human: update this each time the report is run
  rmd_file = here::here("bcws/bcws_quarterly_comparisons1.Rmd"),
  envir = env_rmd1
)

# Extract data frames directly from env_rmd1
# Note: This assumes 'joined_totals' is a list inside your Rmd containing these items
df1_a <- env_rmd1$joined_totals$depot
df1_b <- env_rmd1$joined_totals$hq_victoria
df1_c <- env_rmd1$joined_totals$hq_kam_pwcc

# create sheet names
firstSheet = "Depot"
secondSheet = "HQ Victoria"
thirdSheet = "HQ Kamloops PWCC"

# add worksheets to workbook
sheet.names(firstSheet)
sheet.names(secondSheet)
sheet.names(thirdSheet)

# assign data tables to worksheets
dt.worksheets(1, df1_a)
dt.worksheets(2, df1_b)
dt.worksheets(3, df1_c)

# freeze top row of all sheets
freeze.panes(1)
freeze.panes(2)
freeze.panes(3)

# (Optional) Add filter
column.filter(1)
column.filter(2)
column.filter(3)

# set conditional colour format on columns 7, 10, 13, and 15 for values < 0
cond.colour(1, nrow(df1_a))
cond.colour(2, nrow(df1_b))
cond.colour(3, nrow(df1_c))

# set currency format on column (not being used right now)
# currency.format(1, nrow(df1_a))
# currency.format(2, nrow(df1_b))
# currency.format(3, nrow(df1_c))

# set custom column widths for all sheets
column.width(1)
column.width(2)
column.width(3)


# =========================================================================
# 3. RENDER & EXTRACT FROM THE SECOND .Rmd (1 Data Frame -> 1 Sheet)
# =========================================================================
env_rmd2 <- new.env()

message("Starting Training report...")
report2 <- render_bcws_quarterly_comparisons(
  old_data = here::here("source/archival_source", "bcws_training_report_2026-04-15.csv"), # Human: update this each time the report is run
  new_data = here::here("source", "bcws_training_report_2026-09-22_1542.csv"), # Human: update this each time the report is run
  rmd_file = here::here("bcws/bcws_training_quarterly_comparisons1.Rmd"),
  envir = env_rmd2
)

# Extract data frame directly from env_rmd2
df2_main <- env_rmd2$join_totals

# create sheet names
fourthSheet = "Training$"

# add worksheets to workbook
sheet.names(fourthSheet)

# assign data tables to worksheets, apply filter across all sheets
dt.worksheets(4, df2_main)

# freeze top row of all sheets
freeze.panes(4)

# (Optional) Add filter
column.filter(4)

# Apply formats to Sheet 4 (Training)
sty1 <- createStyle(fontColour = "#000080")
conditionalFormatting(
  excel, sheet = 4, cols = c(7, 9, 13, 15, 19),
  rows = 2:(nrow(df2_main) + 1), rule = "<0", style = sty1
)

# set currency format on Sheet 4 (not being used right now)
# sty2 <- createStyle(numFmt = "$0.00")
# addStyle(excel, sheet = 4, sty2, rows = 2:(nrow(df2_main) + 1), cols = 8:13, gridExpand = TRUE)
# setColWidths(excel, sheet = 4, cols = c(1:3, 4, 5:19), widths = c(36, 38, 15, 55, rep(25, 15)))

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

sheet_data <- list(
  df1_a,
  df1_b,
  df1_c,
  df2_main
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

addStyle(
  wb = excel,
  sheet = 4,
  style = headerStyle,
  rows = 1,
  cols = 1:ncol(df2_main),
  gridExpand = TRUE,
  stack = TRUE
)

# =========================================================================
# 4. SAVE THE FINAL COMBINED EXCEL FILE
# =========================================================================
saveWorkbook(excel, file = output_file, overwrite = TRUE)
message("Workbook saved to: ", output_file)
