# setup
library(here)
library(rmarkdown)

# You can find the correct directory by typing Sys.getenv("RSTUDIO_PANDOC")
Sys.setenv(RSTUDIO_PANDOC = "C:/Program Files/RStudio/bin/")

source("scripts/load_groupshare_files.R")
source("scripts/custom_sfp_functions.R")

# function to render parameters and save html output to file
render_report = function(data, ministry, share, collected) {
  rmarkdown::render(
    here("scripts", "enhanced_sfp_report_share.Rmd"), params = list(
      data = data,
      ministry = ministry,
      share = share,
      collected = collected
    ),
    output_file = paste0("SFP_Enhanced_Report_", ministry, "_", share, "_", collected, ".pdf"),
    output_dir = here("output"),
  )
}


# render example, stating parameters
render_report("SOURCE_DATA.csv", "MINISTRY", "SHARE", "YYYY-MM_DD")
