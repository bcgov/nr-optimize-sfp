# r setup
library(tidyverse)
library(magrittr)
library(dplyr)
library(readxl)
library(here)
here::here()

# load group share sheets from multiple excel files
owner.list <- list.files(here("source/ownership"), pattern = '*.xlsx', full.names = TRUE) # names every Excel file in the folder that starts with SharedDriveOwnershipReport

# take sheet 4 from each file in list and convert data to 1 list per file
owner.list <- lapply(owner.list, read_excel, sheet = 4)

# concatenate all sheet 4 lists into one list
owner.df <- do.call(rbind, owner.list)

# convert sheet 4 list to a dataframe
owner.df1 <- data.frame(owner.df)

# merge the 2 dataframes together
# groupshare_df <- data.frame(rbind(df1, df2))

###clean up the dataframe###

# drop the unnecessary columns
owner.df1 <- owner.df1 %>%
  select(c(2,3,9))

# rename the remaining columns for funtionality (remove blank spaces etc.)
colnames(owner.df1)[1] = "ministry"
colnames(owner.df1)[2] = "share"
colnames(owner.df1)[3] = "possible_owner"

# drop rows where the share name is duplicated & keep only the first row
owner.df1 <- owner.df1 %>%
  distinct(share, .keep_all = TRUE)
