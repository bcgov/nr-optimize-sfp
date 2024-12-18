# r setup
library(lubridate)
library(openxlsx)

# date conversion
convert.date <- function(.data) {
  format(as.POSIXct(.data,format = '%m/%d/%Y %H:%M:%S'),format = '%Y-%m-%d')
}

wb.create <- function(x) {
  excel <- createWorkbook(x)
}

# excel sheet names
sheet.names <- function(.data) {
  addWorksheet(excel, .data)
}

# write data frame to excel sheet
dt.worksheets <- function(x, .data) {
  writeDataTable(excel, sheet = x, .data, startCol = 1, startRow = 3, colNames = TRUE, tableStyle = "none")
}

# freeze top row of excel sheets
freeze.panes <- function(x) {
  freezePane(excel, x, firstActiveRow = 4)
}

xl.disclaimer <- function(x, y) {
  writeData(x, y, "The content of this Division Storage Report is confidential and intended for the recipient specified. You should only see data for your work area.
If you received information about employees outside your work area, please delete that data immediately. Thank you for your cooperation and understanding.
Our Privacy Impact Assessment requires us to alert users of this report of potential inaccuracies.
If you identify any discrepancies between the report and an employee’s actual H Drive, please contact the Optimization Team at NRIDS.Optimize@gov.bc.ca.", startCol = 1, startRow = 1)
  writeData(x, y, "", startCol = 1, startRow = 2)
}

# create style for disclaimer text
disclaimStyle <- createStyle(
  fontSize = 12, fontColour = "#FFFFFF", halign = "left",
  fgFill = "#003366", border = "TopBottom", borderColour = "#663300",
  wrapText = TRUE
)

# apply style to disclaimer text
dc.style <- function(x, y) {
  addStyle(x, y, disclaimStyle, rows = 1, cols = 1, gridExpand = TRUE)
}

# apply conditional formatting to limit exceeded column
redfill <- createStyle(fontColour = "black", bgFill = "#FF0000")
limit.style <- function(x, y) {
  conditionalFormatting(x, y, cols = 5, rows = 4:200, type = 'contains', rule = "Yes", style = redfill)
}




