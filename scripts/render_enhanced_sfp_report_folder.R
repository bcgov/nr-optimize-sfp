# setup
library(here)
library(rmarkdown)

# You can find the correct directory by typing Sys.getenv("RSTUDIO_PANDOC")
Sys.setenv(RSTUDIO_PANDOC="C:/Program Files/RStudio/bin/")

# function to render parameters and save html output to file
render_report = function(data, ministry, path, folder, collected) {
  rmarkdown::render(
    here("scripts", "enhanced_sfp_report_folder.rmd"), params = list(
      data = data,
      ministry = ministry,
      path = path,
      folder = folder,
      collected = collected
    ),
    output_file = paste0("SFP_Enhanced_Report_", ministry, "_", folder, "_", collected, ".pdf"),
    output_dir = here("output"),
  )
}

# render examples, stating parameters
render_report("SOURCE_DATA.csv","BCWS","\\\\FIRELINE\\SF_I$\\C65\\SHARE\\FOLDER\\SUBFOLDER","FOLDER NAME","2026-03-31")
render_report("SOURCE_DATA.csv","FOR","/ifs/sharedfile/top_level/C64/SHARE/FOLDER/SUBFOLDER","FOLDER NAME","2026-03-31")
