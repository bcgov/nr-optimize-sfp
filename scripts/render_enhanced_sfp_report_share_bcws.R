# setup
library(here)
library(rmarkdown)

# You can find the correct directory by typing Sys.getenv("RSTUDIO_PANDOC")
Sys.setenv(RSTUDIO_PANDOC="C:/Program Files/RStudio/bin/")

source("scripts/load_groupshare_files.R")

# function to render parameters and save html output to file
render_report = function(data, ministry, share, quarter, fiscal, collected) {
  rmarkdown::render(
    here("scripts", "enhanced_sfp_report_share_bcws.Rmd"), params = list(
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

#render, stating parameters
render_report("2023-01-01_BCWS_SFP_Enhanced_Data.csv", "BCWS", "S65005", "Q4", "FY22-23", "2023-01-04")

