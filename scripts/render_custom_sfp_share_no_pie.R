# setup
library(here)
library(rmarkdown)

# You can find the correct directory by typing Sys.getenv("RSTUDIO_PANDOC")
Sys.setenv(RSTUDIO_PANDOC="C:/Program Files/RStudio/bin/")

source("scripts/load_groupshare_files.R")

# function to render parameters and save html output to file
render_report = function(data, ministry, share, quarter, fiscal, collected) {
  rmarkdown::render(
    here("scripts", "custom_sfp_share_no_pie.Rmd"), params = list(
      data = data,
      ministry = ministry,
      share = share,
      quarter = quarter,
      fiscal = fiscal,
      collected = collected
    ),
    output_file = paste0("SFP_Enhanced_Report_", ministry, "_", share, "_", quarter, "_", fiscal, ".html"),
    output_dir = here("output"),
  )
}

#render report on SFP share without using a pie chart to show coverage, stating parameters
render_report("2024_07_01_WLRS_SFP_Enhanced_Data.csv", "WLRS", "S09002", "Q2", "FY24-25", "2024-07-04")
render_report("2024_07_01_WLRS_SFP_Enhanced_Data.csv", "WLRS", "S09009", "Q2", "FY24-25", "2024-07-04")

