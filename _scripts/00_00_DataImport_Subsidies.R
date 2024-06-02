# Script: 00_00_DataImport.R
#______________________________________________________________________________
#  Data import from KBO & VLAIO

#  Functionality :
#  1. Import raw data from VLAIO & KBO Tables  
#  2. Save as .rds files that are used as datasource for tables and figures in 
#     the introduction chapter 'INL'
# ______________________________________________________________________________



# Clear all & Load packages ----------------------------------------------

# Clear
  rm(list = ls()) # remove all objects
  rm(list = ls(envir = globalenv()))
  gc() # call Garbage Collector and reclaim the memory used by the deleted objects.
  
  
# Load packages
  pacman::p_load(dplyr, data.table, table.express, tidyverse, stringr)
  

# Load subsidies ----------------------------------------------------------
  my_path = 'D:/Documents/03__Coronasubsidies/10   Data Files/10.01   Raw Data - Vlaio/Coronasubsidies - Update 2022-11-14/Subsidies.csv' 
 
  # Explicit defining of column class
  col_classes <- c("character", "numeric", "character") #col_classes <- c("character", rep("numeric", 17))
  
  # Read the CSV file
  dta_subsidies <- fread(my_path, colClasses = col_classes)

  # Write csv to .rds
  rds_path <- 'D:/Documents/12__Projects/01__Project-CS/Data/Processed Data/00_00_dta_Su.rds'
  saveRDS(dta_subsidies, file = rds_path)
  
    
  # WARNING !
  # Opgelet: Verschillende ondernemingen hebben 2 bedragen voor V12
  # Eerste bedrag is voorschot. Tweede bedrag is afrekening!
  
  # dta_subsidies %>% 
  #   dplyr::count(EntityNumber,Type) %>% 
  #   dplyr::filter(n >1) %>% 
  #   print()
  
  
  # Reshape the data to wider format
  dta_subsidies_wide <- dta_subsidies %>%
      pivot_wider(names_from = Type, values_from = Amount, values_fn =sum)

  # Ensure columns 2 to 18 are numeric
  dta_subsidies_wide[2:18] <- lapply(dta_subsidies_wide[2:18], as.numeric)
  
  # Create Total-column
  dta_subsidies_wide <- dta_subsidies_wide %>%
  mutate(Total = rowSums(across(2:18), na.rm = TRUE))
  
  # Fix the order of the columns in the table >> factors 
  # vector aanmaken met naam premies en volgnummer voor ordening
  tmp_vc1 <- c("EntityNumber", "Total", "CHP", "CCP", "COP", "V01", "V02", "V03", "V04", "V05",
               "V06", "V07", "V08", "V09", "V10", "V11", "V12", "GM1", "GM2")
  
  # Make categoricals and sort
  dta_subsidies_wide <- dta_subsidies_wide %>% 
    select(all_of(tmp_vc1))

  # create table 'entities'
  dta_entities <- dta_subsidies_wide
  setDT(dta_entities)
  
  # Drop specified columns
  dta_entities[, (2:19) := NULL]
  
  
# Save files subsidies_wide -----------------------------------------------
  csv_path <- 'D:/Documents/12__Projects/01__Project-CS/Data/Processed Data/00_00_dta_Su_wide.csv'
  rds_path <- 'D:/Documents/12__Projects/01__Project-CS/Data/Processed Data/00_00_dta_Su_wide.rds'
  
  fwrite(dta_subsidies_wide, csv_path)
  saveRDS(dta_subsidies_wide, file = rds_path)
  
# Save file entities ------------------------------------------------------  
  csv_path <- 'D:/Documents/12__Projects/01__Project-CS/Data/Processed Data/00_00_dta_En.csv'
  rds_path <- 'D:/Documents/12__Projects/01__Project-CS/Data/Processed Data/00_00_dta_En.rds'
  
  fwrite(dta_entities, csv_path)
  saveRDS(dta_entities, file = rds_path)

# Clean up ----------------------------------------------------------------
  rm(list = ls()) # remove all objects
  rm(list = ls(envir = globalenv()))
  gc() # call Garbage Collector and reclaim the memory used by the deleted objects.
  