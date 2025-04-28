# setup
library(here)
library(rmarkdown)

# You can find the correct directory by typing Sys.getenv("RSTUDIO_PANDOC")
Sys.setenv(RSTUDIO_PANDOC = "C:/Program Files/RStudio/bin/")

source("scripts/load_groupshare_files.R")

# function to render parameters and save html output to file
render_report = function(data, ministry, collected) {
  rmarkdown::render(
    here("scripts", "enhanced_sfp_report_overview.rmd"), params = list(
      data = data,
      ministry = ministry,
      collected = collected
    ),
    output_file = paste0("SFP_Enhanced_Report_", ministry, "_", collected, ".pdf"),
    output_dir = here("output"),
  )
}

#render, stating parameters
render_report("YYYY_MM_DD_AF_SFP_Enhanced_Data.csv", "AF", "YYYY-MM-DD")
render_report("YYYY_MM_DD_EMLI_SFP_Enhanced_Data.csv", "EMLI", "YYYY-MM-DD")
render_report("YYYY_MM_DD_ENV_SFP_Enhanced_Data.csv", "ENV", "YYYY-MM-DD")
render_report("YYYY_MM_DD_IRR_SFP_Enhanced_Data.csv", "IRR", "YYYY-MM-DD")
render_report("YYYY_MM_DD_WLRS_SFP_Enhanced_Data.csv", "WLRS", "YYYY-MM-DD")
render_report("YYYY_MM_DD_FOR_SFP_Enhanced_Data.csv", "FOR", "YYYY-MM-DD")

# function to render parameters and save html output to file
render_report_bcws = function(data, ministry, collected) {
  rmarkdown::render(
    here("scripts", "enhanced_sfp_report_overview_bcws.rmd"), params = list(
      data = data,
      ministry = ministry,
      collected = collected
    ),
    output_file = paste0("SFP_Enhanced_Report_", ministry, "_", collected, ".pdf"),
    output_dir = here("output"),
  )
}

#render, stating parameters
render_report_bcws("YYYY_MM_DD_BCWS_SFP_Enhanced_Data.csv", "BCWS", "YYYY-MM-DD")