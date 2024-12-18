# setup
library(here)
library(rmarkdown)

# You can find the correct directory by typing Sys.getenv("RSTUDIO_PANDOC")
Sys.setenv(RSTUDIO_PANDOC = "C:/Program Files/RStudio/bin/")

source("scripts/load_homedrive_files.R")
source("scripts/custom_script_functions.R")

# function to render parameters and save html output to file
rmarkdown::render(here("scripts/experimental", "branchstoragereports.Rmd"), params = "ask")