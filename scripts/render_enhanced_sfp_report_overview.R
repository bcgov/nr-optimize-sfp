# setup
library(here)
library(rmarkdown)

# You can find the correct directory by typing Sys.getenv("RSTUDIO_PANDOC")
Sys.setenv(RSTUDIO_PANDOC = "C:/Program Files/RStudio/bin/")

source("scripts/load_groupshare_files.R")

# function to render parameters and save html output to file
render_report = function(data, ministry, quarter, fiscal, collected) {
  rmarkdown::render(
    here("scripts", "enhanced_sfp_report_overview.rmd"), params = list(
      data = data,
      ministry = ministry,
      quarter = quarter,
      fiscal = fiscal,
      collected = collected
    ),
    output_file = paste0("SFP_Enhanced_Report_", ministry, "_", quarter, "_", fiscal, ".html"),
    output_dir = here("output"),
  )
}

#render, stating parameters
render_report("2024-02-01_AF_SFP_Enhanced_Data.csv", "AF", "Q4", "FY23-24", "2024-02-07")
render_report("2024-02-01_EMLI_SFP_Enhanced_Data.csv", "EMLI", "Q4", "FY23-24", "2024-02-08")
render_report("2024-02-01_ENV_SFP_Enhanced_Data.csv", "ENV", "Q4", "FY23-24", "2024-02-15")
render_report("2024-02-01_IRR_SFP_Enhanced_Data.csv", "IRR", "Q4", "FY23-24", "2024-02-10")
render_report("2024-02-01_WLRS_SFP_Enhanced_Data.csv", "WLRS", "Q4", "FY23-24", "2024-02-07")
render_report("2024-02-01_FOR_SFP_Enhanced_Data.csv", "FOR", "Q4", "FY23-24", "2024-02-15")

# function to render parameters and save html output to file
render_report_bcws = function(data, ministry, quarter, fiscal, collected) {
  rmarkdown::render(
    here("scripts", "enhanced_sfp_report_overview_bcws.rmd"), params = list(
      data = data,
      ministry = ministry,
      quarter = quarter,
      fiscal = fiscal,
      collected = collected
    ),
    output_file = paste0("SFP_Enhanced_Report_", ministry, "_", quarter, "_", fiscal, ".html"),
    output_dir = here("output"),
  )
}

#render, stating parameters
render_report("2024-02-01_BCWS_SFP_Enhanced_Data.csv", "BCWS", "Q4", "FY23-24", "2024-02-10")
