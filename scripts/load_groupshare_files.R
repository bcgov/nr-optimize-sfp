# r setup
library(tidyverse)
library(magrittr)
library( dplyr)
library(readxl)
library(here)
here::here()

# load group share sheets from multiple excel files
file.list <- list.files(here("source"), pattern = '*.xlsx', full.names = TRUE) # names every Excel file in the folder

# get Ministry acronym from file name
ministry.names <- vapply(strsplit(as.character(file.list), split = ' '), `[`, 6, FUN.VALUE=character(1))

# take sheet 3 from each file in list and convert data to 1 list per file
df1.list <- lapply(file.list, read_excel, sheet = 3)

# assign ministry column & acronymns to sheet 3 lists
df1.list <- Map(cbind, df1.list, ministry = ministry.names)

# concatenate all sheet 3 lists into one list
df <- do.call(rbind, df1.list)

# convert sheet 3 list to a dataframe
df1 <- data.frame(df)

# repeat for sheet 5 of the FOR excel file
df2.list <- lapply(file.list[[4]], read_excel, sheet = 5) # takes sheet 5 from the 4th file in list and converts data to list
df2 <- data.frame(df2.list) # converts sheet 5 (FOR - BCWS) to a dataframe
df2$ministry <- "BCWS" # assigns BCWS to Ministry name column (following OCIO naming process for enhanced sfp data, otherwise it would be categorized as FOR)

# merge the 2 dataframes together
groupshare_df <- data.frame(rbind(df1, df2))

###clean up the dataframe###

# drop the unnecessary Server Name column
groupshare_df <- groupshare_df %>%
  select(-c("Server"))

# rename the remaining columns for funtionality (remove blank spaces etc.)
colnames(groupshare_df)[1] = "share_name"
colnames(groupshare_df)[2] = "used_gb"


