# setup
library(here)
library(rmarkdown)

# You can find the correct directory by typing Sys.getenv("RSTUDIO_PANDOC")
Sys.setenv(RSTUDIO_PANDOC="C:/Program Files/RStudio/bin/")

# function to render parameters and save html output to file
render_report = function(ministry, month, year) {
  rmarkdown::render(
    here("scripts", "nrm_hdrive_category_tops.Rmd"), params = list(
      ministry = ministry,
      month = month,
      year = year
    ),
    output_file = paste0("H_Enhanced_Report_", ministry, "_", month, "_", year, ".html"),
    output_dir = here("output"),
  )
}

#render, stating parameters
render_report("AF", "February", "2024")
render_report("BCWS", "February", "2024")
render_report("EMLI", "February", "2024")
render_report("ENV", "February", "2024")
render_report("FOR", "February", "2024")
render_report("IRR", "February", "2024")
render_report("WLRS", "February", "2024")