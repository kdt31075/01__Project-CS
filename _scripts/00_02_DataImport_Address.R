# Identification ----------------------------------------------------------
# 00_02_DataImport_Adrress.R
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
      filter(TypeOfAddress == "REGO") %>%
      filter(substr(EntityNumber, 1, 2) == "04" | substr(EntityNumber, 1, 2) == "05" | substr(EntityNumber, 1, 2) == "06" |
             substr(EntityNumber, 1, 2) == "07"| substr(EntityNumber, 1, 2) == "08")
  }

# Load files KBO-files - remove rows & columns - Bind dataframes ----------
  my_path <- 'D:/Documents/03__Coronasubsidies/10   Data Files/10.02   Raw Data - KBO/Files 2020-10/address.csv'
  tmp_1 <- fread(my_path)
  tmp_1 <- clean_up(tmp_1)  # Clean up dataframe
  
  my_path = 'D:/Documents/03__Coronasubsidies/10   Data Files/10.02   Raw Data - KBO/Files 2024-05 Full/address.csv'
  tmp_2 <- fread(my_path)
  tmp_2 <- clean_up(tmp_2)
  
  # Bind the dataframes & Keep only distinct rows
  dta_address <- rbind(tmp_1, tmp_2) %>% 
    distinct()
 
  # Clean up
  rm(list = ls(pattern = "^tmp_"))
  gc()

  # Drop specified columns
  # Columns to drop
  cols_to_drop <- c("TypeOfAddress", "CountryFR", "MunicipalityFR", "StreetFR", "Box", "ExtraAddressInfo")
  
  # Drop columns using set
  for (col in cols_to_drop) {
    set(dta_address, j = col, value = NULL)
  }
  
  # Change table header
  names(dta_address) <- c("EntityNumber", "Country", "Zipcode", "Municipality", "Street", "HouseNumber", "DatestrikingOff")

 
# Load subsidies ----------------------------------------------------------
  rds_path <- 'D:/Documents/12__Projects/01__Project-CS/Data/Processed Data/00_00_dta_En.rds'
  dta_entities <- readRDS(rds_path)
  
# Merge entities & activity -----------------------------------------------

  # Use table.express for joins  (data.table )
  # https://asardaes.github.io/table.express/articles/joins.html
  
  # Convert to data.table
  setDT(dta_address)
  setDT(dta_entities)
  
  # Left-join dta_entities and dta_address + unique() (equivalent of dplyr's distinct())
  dta_address <- dta_address[dta_entities, on = "EntityNumber"]
  dta_address <- unique(dta_address, by = "EntityNumber")
  
  # Save output 
  output_path <- 'D:/Documents/12__Projects/01__Project-CS/Data/Processed Data/00_02_dta_EnAd.csv'
  rds_path <- 'D:/Documents/12__Projects/01__Project-CS/Data/Processed Data/00_02_dta_EnAd.rds'
  
  fwrite(dta_address, output_path)
  saveRDS(dta_address, file = rds_path)
  
  # Clean up
  rm(list = ls()) # remove all objects
  rm(list = ls(envir = globalenv()))
  gc() # call Garbage Collector and reclaim the memory used by the deleted objects.
  
 