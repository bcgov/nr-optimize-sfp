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
  writeDataTable(excel, sheet = x, .data, colNames = TRUE, withFilter = TRUE)
}

# freeze top row of excel sheets
freeze.panes <- function(x) {
  freezePane(excel, x, firstRow = TRUE)
}

# create a BCGOV colour palette
bc_colours <- c("#234075", "#e3a82b", "#65799e", "#FFFFFF")
