# r setup
library(tidyverse)
library(magrittr)
library( dplyr)
library(readxl)
library(here)
here::here()

# load group share sheets from multiple excel files
file.list <- list.files(here("source/homedrives"), pattern = '*.xlsx', full.names = TRUE) # names every Excel file in the folder

# get Ministry acronym from file name
ministry.names <- vapply(strsplit(as.character(file.list), split = ' '), `[`, 6, FUN.VALUE = character(1))

# take sheet 2 from each file in list and convert data to 1 list per file
df1.list <- lapply(file.list, read_excel, sheet = 2)

# assign ministry column & acronymns to sheet 3 lists
df1.list <- Map(cbind, df1.list, Ministry = ministry.names)

# concatenate all sheet 3 lists into one list
df <- do.call(rbind, df1.list)

# convert sheet 3 list to a dataframe
df1 <- data.frame(df)

# repeat for sheet 5 of the FOR excel file
df2.list <- lapply(file.list[[4]], read_excel, sheet = 4) # takes sheet 4 from the 4th file in list and converts data to list
df2 <- data.frame(df2.list) # converts sheet 4 (FOR - BCWS) to a dataframe
df2$Ministry <- "BCWS" # assigns BCWS to Ministry name column (following OCIO naming process, otherwise it would be categorized as FOR)

# merge the 2 dataframes together
homedrives_df <- data.frame(rbind(df1, df2))

### clean up the dataframe ###

# drop the unnecessary columns
homedrives_df <- homedrives_df %>%
  select(-c("Email",
            "Last.Name",
            "First.Name",
            "Mailbox.Org.Code",
            "User.ID"))

# rename the remaining columns for functionality (remove blank spaces etc.)
colnames(homedrives_df)[2] = "Division"
colnames(homedrives_df)[3] = "Branch"
colnames(homedrives_df)[4] = "Used"


