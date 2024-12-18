# r setup
library(tidyverse)
library(magrittr)
library( dplyr)
library(readr)
library(here)
library(data.table); setDTthreads(percent = 65)
here::here()

# load enhanced SFP data from multiple csv files
sfp.file.list <- list.files(here("source"), pattern = '*SFP_Enhanced_Data.csv', full.names = TRUE) # names every enhanced SFP .csv file in the folder

# get Ministry acronym from file name
sfp.ministry.names <- vapply(strsplit(as.character(sfp.file.list), split = '_'), `[`, 5, FUN.VALUE = character(1))

# convert data to 1 list per file
#sfp.df1.list <- lapply(sfp.file.list, read_csv, col_types = cols())
sfp.df1.list <- lapply(sfp.file.list, data.table::fread, na.strings = c(""," ","NULL"))

# assign ministry column & acronymns to lists
sfp.df1.list <- Map(cbind, sfp.df1.list, ministry = sfp.ministry.names)

# concatenate all lists into one list
sfp.df <- do.call(rbind, sfp.df1.list)

# convert list to a dataframe
sfp.df <- data.frame(sfp.df)

###clean up the dataframe###

# drop the unnecessary container and file_owner columns
sfp.df <- sfp.df %>%
  select(-c("container", "file_owner"))

# rename the remaining columns for funtionality (remove blank spaces etc.)
colnames(sfp.df)[4] = "category"
colnames(sfp.df)[7] = "last_modify_date"
colnames(sfp.df)[8] = "creation_date"

# replace BCWS with FOR in ministry column
sfp.df$ministry[sfp.df$ministry == 'BCWS'] <- 'FOR'
