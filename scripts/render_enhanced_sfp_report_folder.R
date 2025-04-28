# setup
library(here)
library(rmarkdown)

# You can find the correct directory by typing Sys.getenv("RSTUDIO_PANDOC")
Sys.setenv(RSTUDIO_PANDOC="C:/Program Files/RStudio/bin/")

# Use for all NR Ministries except for BCWS
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

#render, stating parameters
render_report("YYYY_MM_DD_MINISTRY_SFP_Enhanced_Data.csv", "MINISTRY", "/ifs/sharedfile/top_level/C##/S#####/Main_Folder/Sub_Folder", "Sub_Folder", "YYYY-MM-DD")


# Use only for BCWS
# function to render parameters and save html output to file - BCWS
render_report = function(data, ministry, path, folder, collected) {
  rmarkdown::render(
    here("scripts", "enhanced_sfp_report_folder_bcws.rmd"), params = list(
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

#render, stating parameters
render_report("YYYY_MM_DD_BCWS_SFP_Enhanced_Data.csv", "BCWS", "\\\\\\\\FIRELINE\\\\SF_LETTER[$]\\\\C##\\\\S#####\\\\Main_Folder\\\\Sub_Folder", "Sub_Folder", "YYYY-MM-DD")


