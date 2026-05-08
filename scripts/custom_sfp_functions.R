# date conversion
convert.date <- function(.data) {
  format(as.POSIXct(.data,format='%m/%d/%Y %H:%M:%S'),format='%Y-%m-%d')
}

# excel sheet names
sheet.names <- function(.data) {
  addWorksheet(excel, .data)
}

# write df to excel sheet
dt.worksheets <- function(x, .data) {
  writeDataTable(excel, sheet = x, .data, colNames = TRUE, withFilter = TRUE, tableStyle = "TableStyleLight2")
}

# freeze top row of excel sheets
freeze.panes <- function(x) {
  freezePane(excel, x, firstRow = TRUE)
}

# create a BCGOV colour palette
bc_colours <- c("#234075", "#e3a82b", "#65799e", "#FFFFFF")

# ------------------------------------------------------------------------------
# remap_substrings
#
# Remaps known legacy filesystem path prefixes to canonical SFP UNC paths.
# Designed for large vectors (millions of rows) and safe reuse across scripts.
#
# Rules implemented:
#   1. /ifs/sharedfile/top_level/*  -> \\sfp.idir.bcgov\s***
#   2. \\FIRELINE\SF_F$–SF_M$\C65\  -> \\sfp.idir.bcgov\s165\
#   3. Final slash normalization to backslashes
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

  # ---------------------------------------------------------------------------
  # 1. Unix /ifs paths -> UNC (fixed replacement)
  # ---------------------------------------------------------------------------
  ifs_map <- c(
    "/ifs/sharedfile/top_level/C04/" = "\\\\sfp.idir.bcgov\\s104\\",
    "/ifs/sharedfile/top_level/C09/" = "\\\\sfp.idir.bcgov\\s109\\",
    "/ifs/sharedfile/top_level/C40/" = "\\\\sfp.idir.bcgov\\s140\\",
    "/ifs/sharedfile/top_level/C64/" = "\\\\sfp.idir.bcgov\\s164\\",
    "/ifs/sharedfile/top_level/C61/" = "\\\\sfp.idir.bcgov\\s161\\",
    "/ifs/sharedfile/top_level/C53/" = "\\\\sfp.idir.bcgov\\s153\\",
    "/ifs/sharedfile/top_level/C92/" = "\\\\sfp.idir.bcgov\\s192\\"
  )

  paths <- stringi::stri_replace_all_fixed(
    paths,
    names(ifs_map),
    unname(ifs_map),
    vectorize_all = FALSE
  )

  # ---------------------------------------------------------------------------
  # 2. FIRELINE SF_F–SF_M remapping (pre-filtered, fixed, fast)
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

# ------------------------------------------------------------------------------
# records_management_text
#
# Returns ministry-specific Markdown text for Records Management guidance.
#
# Arguments:
#   ministry : single character string (e.g. "AF", "BCWS", etc.)
#
# Returns:
#   character string containing Markdown-formatted text
# ------------------------------------------------------------------------------

records_management_text <- function(ministry) {

  if (identical(ministry, "BCWS")) {
    return(
      paste0(
        "- Do you have questions about appropriate Records Management for your data? ",
        "Visit [BC Wildfire Intranet Records and Information Management]",
        "(https://intranet.gov.bc.ca/bcws/corporate-governance/wildfire-risk/records-and-information-management) ",
        "and scroll to the bottom for a current list of BCWS Records Clerks you can contact.\n\n",
        "- Do you want to learn how to clean up your data? Visit the ",
        "[BC Wildfire Service (BCWS) Shared Drive Cleanup Project]",
        "(https://intranet.gov.bc.ca/bcws/corporate-governance/wildfire-risk/risk-projects/shared-drive-cleanup) ",
        "under Training for step-by-step PDFs and videos."
      )
    )
  }

  # Default (all non-BCWS ministries)
  paste0(
    "- Do you have questions about appropriate Records Management for your data? ",
    "Visit the [Government Information Management Branch]",
    "(https://www2.gov.bc.ca/gov/content/governments/services-for-government/",
    "information-management-technology/records-management) ",
    "or [Contact the GIM Team](mailto:gim@gov.bc.ca)."
  )
}

# ------------------------------------------------------------------------------
# file_age_threshold
#
# Returns a date threshold for "old files" based on ministry rules.
#
# Rules:
#   - BCWS  : files older than 5 years
#   - Other : files older than 2.5 years
#
# Notes:
#   - Uses day-based difftime to support fractional years safely
# ------------------------------------------------------------------------------

file_age_threshold <- function(collected_date, ministry) {

  collected_date <- as.Date(collected_date)

  if (is.na(collected_date)) {
    stop("file_age_threshold(): 'collected_date' must be a valid date")
  }

  if (identical(ministry, "BCWS")) {
    # 5 years = 5 * 365.25 days
    return(collected_date - as.difftime(5 * 365.25, units = "days"))
  }

  # Default: 2.5 years = 2.5 * 365.25 days
  collected_date - as.difftime(2.5 * 365.25, units = "days")
}

# ------------------------------------------------------------------------------
# file_age_label
#
# Returns a human-readable age label for "old files" based on ministry rules.
#
# Arguments:
#   ministry : character string (e.g. "BCWS", "AF", etc.)
#
# Returns:
#   character string (e.g. "2.5 years" or "5 years")
# ------------------------------------------------------------------------------

file_age_label <- function(ministry) {
  if (identical(ministry, "BCWS")) {
    return("5 years")
  }

  "2.5 years"
}
