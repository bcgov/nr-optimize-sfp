# setup
library(here)
library(rmarkdown)

# You can find the correct directory by typing Sys.getenv("RSTUDIO_PANDOC")
Sys.setenv(RSTUDIO_PANDOC="C:/Program Files/RStudio/bin/")

# function to render parameters and save html output to file
render_report = function(data, ministry, path, folder, quarter, fiscal, collected) {
  rmarkdown::render(
    here("scripts", "enhanced_sfp_report_folder.rmd"), params = list(
      data = data,
      ministry = ministry,
      path = path,
      folder = folder,
      quarter = quarter,
      fiscal = fiscal,
      collected = collected
    ),
    output_file = paste0("SFP_Enhanced_Report_", ministry, "_", folder, "_", quarter, "_", fiscal, ".html"),
    output_dir = here("output"),
  )
}

#render, stating parameters
render_report("2024-02-01_ENV_SFP_Enhanced_Data.csv", "ENV", "/ifs/sharedfile/top_level/C40/S40007/RPAB/RPAB/12 CISF", "12 CISF", "Q4", "FY23-24", "2024-02-15")
