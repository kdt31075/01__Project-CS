# Identification ----------------------------------------------------------
# 00_01_DataImport.R
# kdt 2024-06-01

# Data import from KBO
# Functionality :
# 1. Import raw data from KBO Tables  
# 2. Save as .csv & .rds files 


# Clear all & Load packages ----------------------------------------------
# Clear
  rm(list = ls()) # remove all objects
  rm(list = ls(envir = globalenv()))
  gc() # call Garbage Collector and reclaim the memory used by the deleted objects.

# Load packages
  pacman::p_load(dplyr, data.table, tidyverse, stringr)
  

# Function remove governmental organisations & 2003 Nacecodes -------------
  clean_up <- function(tmp_) {
    tmp_non_gov <- tmp_ %>%
      filter(NaceVersion == 2008 & Classification == "MAIN") %>% 
      select(-NaceVersion, -Classification) %>% 
      filter(substr(EntityNumber, 1, 2) == "04" | substr(EntityNumber, 1, 2) == "05" | substr(EntityNumber, 1, 2) == "06" |
             substr(EntityNumber, 1, 2) == "07"| substr(EntityNumber, 1, 2) == "08")
  }

# Load files KBO-files - remove rows & columns - Bind dataframes ----------
  my_path <- 'D:/Documents/03__Coronasubsidies/10   Data Files/10.02   Raw Data - KBO/Files 2020-10/activity.csv'
  tmp_1 <- fread(my_path, colClasses = list(character = "NaceCode"))
  tmp_1 <- clean_up(tmp_1)  # Clean up dataframe
  
  my_path = 'D:/Documents/03__Coronasubsidies/10   Data Files/10.02   Raw Data - KBO/Files 2024-05 Full/activity.csv'
  tmp_2 <- fread(my_path, colClasses = list(character = "NaceCode"))
  tmp_2 <- clean_up(tmp_2)
  
  # Bind the dataframes & Keep only distinct rows
  dta_activity <- bind_rows(tmp_1, tmp_2) %>% 
    distinct()
 
  # Clean up
  rm(list = ls(pattern = "^tmp_"))
  gc()

 
# Move Nacecode into columns ------------------------------------------------------
  # pivot_wider
  # Aggregate Nacecode values for each EntityNumber and ActivityGroup combination
  dta_activity <- dta_activity %>%
    arrange(EntityNumber) %>% 
    group_by(EntityNumber, ActivityGroup) %>%
    # choose an option : (1) or only the first value
    #                    (2) or a list of value for each column
    # summarize(NaceCode = paste(NaceCode, collapse = ", "), .groups = 'drop') # option 2
    summarize(NaceCode = first(NaceCode), .groups = 'drop') # option 1
  
  # Reshape the data to wider format
  dta_activity_wide <- dta_activity %>%
    pivot_wider(names_from = ActivityGroup, values_from = NaceCode)
  
  # Change table header
  names(dta_activity_wide) <- c("EntityNumber", "BTW", "RSZ", "OLK", "RSZPPO", "EDRL")

  # Function to find the most frequent value
  most_frequent <- function(x) {
    table_x <- table(x)
    max_count <- max(table_x)
    most_frequent_values <- as.numeric(names(table_x[table_x == max_count]))
    
    # If there are ties in frequencies, return the first value in the original order
    if(length(most_frequent_values) > 1) {
      return(as.character(most_frequent_values[1]))   # to ensure character type (otherwise loosing leading zero's)
    } else {
      return(as.character(most_frequent_values))      # to ensure character type
    }
  }
  
  # Apply the function row-wise using rowwise() and mutate()
  dta_activity_wide_nc <- dta_activity_wide %>%
    rowwise(EntityNumber) %>%  # specify Entitynumber so it gets out of any calculation
    mutate(NaceCode = most_frequent(c_across(`BTW`:`EDRL`)))
  
  # Handle lost leading zero's
  dta_activity_wide_ncAll <- dta_activity_wide_nc %>%
    mutate(NaceCode = ifelse(nchar(NaceCode) == 4, str_pad(NaceCode, width = 5, pad = "0"), NaceCode))
 
  # Save output [all Nacecode]
  output_path <- 'D:/Documents/12__Projects/01__Project-CS/Data/Processed Data/00_01_dta_Ac_wide_ncAll.csv'
  rds_path <- 'D:/Documents/12__Projects/01__Project-CS/Data/Processed Data/00_01_dta_Ac_wide_ncAll.rds'
    
  setDT(dta_activity_wide_ncAll)
  
  fwrite(dta_activity_wide_ncAll, output_path)
  saveRDS(dta_activity_wide_ncAll, file = rds_path)
  
  # Drop specified columns
  # Columns to drop
  dta_activity_nc <- dta_activity_wide_ncAll
  cols_to_drop <- c("BTW", "RSZ", "OLK", "RSZPPO", "EDRL")
  
  # Drop specified columns
  dta_activity_nc[, (cols_to_drop) := NULL]
  
  output_path <- 'D:/Documents/12__Projects/01__Project-CS/Data/Processed Data/00_01_dta_Ac_nc.csv'
  rds_path <- 'D:/Documents/12__Projects/01__Project-CS/Data/Processed Data/00_01_dta_Ac_nc.rds'
  
  fwrite(dta_activity_nc, output_path)
  saveRDS(dta_activity_nc, file = rds_path)
  
  
# Load subsidies ----------------------------------------------------------
  rds_path <- 'D:/Documents/12__Projects/01__Project-CS/Data/Processed Data/00_00_dta_En.rds'
  dta_entities <- readRDS(rds_path)
  
# Merge entities & activity -----------------------------------------------

  # Use table.express for joins  (data.table )
  # https://asardaes.github.io/table.express/articles/joins.html
  
  # Convert to data.table
  setDT(dta_activity_wide_nc)
  setDT(dta_entities)
  
  dta_entities_activity <- dta_activity_wide_nc[dta_entities, on = "EntityNumber"]
  
  rds_path <- 'D:/Documents/12__Projects/01__Project-CS/Data/Processed Data/00_01_dta_EnAc.rds'
  saveRDS(dta_entities_activity, file = rds_path)
  
 