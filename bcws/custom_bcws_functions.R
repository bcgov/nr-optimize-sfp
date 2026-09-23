# date conversion
convert.date <- function(.data) {
  format(as.POSIXct(.data,format='%m/%d/%Y %H:%M:%S'),format='%Y-%m-%d')
}

# excel sheet names
sheet.names <- function(.data) {
  addWorksheet(excel, .data)
}

# write df to excel sheet
# write df to excel sheet as a formatted Excel Table
dt.worksheets <- function(x, .data) {
  writeData(
    excel,
    sheet = x,
    .data,
    colNames = TRUE
  )

  addFilter(
    excel,
    sheet = x,
    rows = 1,
    cols = 1:ncol(.data)
  )
}

# freeze top row of excel sheets
freeze.panes <- function(x) {
  freezePane(excel, x, firstRow = TRUE)
}

# add column filters to excel sheet
column.filter <- function(x) {
  addFilter(excel, x, row = 1, cols = 1:4)
}

# set conditional colour format on columns 7, 10, 13, 15, and 18 for values < 0
sty1 <- createStyle(fontColour = "#000080")

cond.colour <- function(sheet, rows) {
  conditionalFormatting(
    excel,
    sheet = sheet,
    cols = c(7, 10, 13, 15, 18),
    rows = 2:(rows + 1),
    rule = "<0",
    style = sty1
  )
}

# set currency format on column
sty2 <- createStyle(numFmt = "$0.00")

currency.format <- function(sheet_num, n_rows) {

  addStyle(
    wb = excel,
    sheet = sheet_num,
    style = sty2,
    rows = 2:(n_rows + 1),
    cols = c(8, 9, 10),
    gridExpand = TRUE
  )

}

# set custom column widths for all sheets
column.width <- function(x) {
  setColWidths(excel,
               sheet = x,
               cols = c(1:3, 4, 3:19),
               widths = c(38, 36, 15, 55, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25)
               )
}

# ------------------------------------------------------------------------------
# remap_substrings
#
# Remaps known legacy filesystem path prefixes to canonical SFP UNC paths.
# Designed for large vectors (millions of rows) and safe reuse across scripts.
#
# Rules implemented:
#   1. \\FIRELINE\SF_F$–SF_M$\C65\  -> \\sfp.idir.bcgov\s165\
#   2. Final slash normalization to backslashes
#
# Arguments:
#   paths : character vector of paths to normalize/remap
#
# Returns:
#   character vector with remapped, canonicalized UNC paths
#
# Dependencies:
#   stringi
#
# ------------------------------------------------------------------------------

remap_substrings <- function(paths) {

  # Defensive check
  if (!is.character(paths)) {
    stop("remap_substrings(): 'paths' must be a character vector")
  }

  if (all(is.na(paths))) {
    return(paths)
  }

  # ---------------------------------------------------------------------------
  # FIRELINE SF_F–SF_M remapping (pre-filtered, fixed, fast)
  # ---------------------------------------------------------------------------
  fireline_prefixes <- c(
    "\\\\FIRELINE\\SF_F$\\C65\\",
    "\\\\FIRELINE\\SF_G$\\C65\\",
    "\\\\FIRELINE\\SF_H$\\C65\\",
    "\\\\FIRELINE\\SF_I$\\C65\\",
    "\\\\FIRELINE\\SF_J$\\C65\\",
    "\\\\FIRELINE\\SF_K$\\C65\\",
    "\\\\FIRELINE\\SF_L$\\C65\\",
    "\\\\FIRELINE\\SF_M$\\C65\\"
  )


  idx_fireline <- stringi::stri_detect_fixed(
    paths,
    "\\\\FIRELINE\\",
    case_insensitive = TRUE
  )

  idx_fireline <- tidyr::replace_na(idx_fireline, FALSE)

  if (any(idx_fireline)) {
    paths[idx_fireline] <- stringi::stri_replace_all_fixed(
      paths[idx_fireline],
      fireline_prefixes,
      rep("\\\\sfp.idir.bcgov\\s165\\", length(fireline_prefixes)),
      vectorize_all = FALSE,
      case_insensitive = TRUE
    )
  }

  # ---------------------------------------------------------------------------
  # 3. FINAL slash direction correction (last step only)
  # ---------------------------------------------------------------------------
  paths <- stringi::stri_replace_all_fixed(
    paths,
    "/",
    "\\"
  )

  return(paths)
}