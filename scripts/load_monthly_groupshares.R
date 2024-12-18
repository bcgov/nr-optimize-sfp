# r setup
library(tidyverse)
library(magrittr)
library( dplyr)
library(readxl)
library(here)
here::here()

# load group share sheets from multiple excel files
grpshr.list <- list.files(here("source/homedrives"), pattern = '*.xlsx', full.names = TRUE) # names every Excel file in the folder

# get Ministry acronym from file name
grpshr.ministry.names <- vapply(strsplit(as.character(grpshr.list), split = ' '), `[`, 6, FUN.VALUE=character(1))

# take sheet 3 from each file in list and convert data to 1 list per file
grpshr.df1.list <- lapply(grpshr.list, read_excel, sheet = 3)

# assign ministry column & acronymns & date to sheet 3 lists
grpshr.df1.list <- Map(cbind, grpshr.df1.list, ministry = grpshr.ministry.names)

# concatenate all sheet 3 lists into one list
grpshr.df <- do.call(rbind, grpshr.df1.list)

# convert sheet 3 list to a dataframe
grpshr.df1 <- data.frame(grpshr.df)

# repeat for sheet 5 of the FOR excel file
grpshr.df2.list <- lapply(grpshr.list[[4]], read_excel, sheet = 5) # takes sheet 5 from the 4th file in list and converts data to list
grpshr.df2 <- data.frame(grpshr.df2.list) # converts sheet 5 (FOR - BCWS) to a dataframe
grpshr.df2$ministry <- "FOR" # assigns FOR to Ministry name column for BCWS

# merge the 2 dataframes together
grpshr_df <- data.frame(rbind(grpshr.df1, grpshr.df2))

###clean up the dataframe###

# drop the unnecessary Server Name column
grpshr_df <- grpshr_df %>%
  select(-c("Server"))

# rename the remaining columns for functionality (remove blank spaces etc.)
colnames(grpshr_df)[1] = "share"
colnames(grpshr_df)[2] = "used_gb"


