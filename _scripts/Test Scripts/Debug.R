# Test
# Load packages
pacman::p_load(DBI, RMySQL, tidyverse, rio, here, skimr, lubridate, knitr,
               tidyr, janitor)

# Use source to call the code from '00 Data Import'
flt_1 <- here("Data", "Processed Data", "s_join_EnDeAdAcSu.rds")

# Check if the file exists  "!" reverse the result from TRUE to FALSE
if (!file.exists(flt_1)) {
  tmp_2 = here("Scripts", "00_DataImport.R")
  source(tmp_2)
}

setwd("D:/Documents/12__Projects/01__Project-CS")
tmp_1 <- import("Data/Processed Data/f_join_EnDeAd.rds")
tmp_2 <- import("Data/Processed Data/f_join_EnDeAdAc.rds")
tmp_3 <- import("Data/Processed Data/s_join_EnDeAdAcSu.rds")              
tmp_4<- import("Data/Processed Data/subsidies.rds")




# Create summary 
dfr_s_join <- import(here("Data", "Processed Data", "s_join_EnDeAdAcSu.rds"))
dfr_nacebel <- import(here("Data", "Raw Data", "nacebel_2008.csv"))

tmp_1 <- dfr_s_join %>%
  mutate(L4 = substr(Nacecode,1,4))

tmp_2 <- tmp_1 %>%
  filter(CHP >= 0) %>%
  group_by(L4) %>%
  summarize(count = n(), max_amount = max(CHP)) %>%
  arrange(desc(max_amount), desc(count))

sum_total <- tmp_2 %>%
  summarize(total=sum(count))

sum_1 <- left_join(tmp_2, dfr_nacebel,  join_by (L4 == Code)) %>%
  select(L4, Label_NL, count, max_amount)

colnames(sum_1) <- c("NaceC.", "Omschrijving", "Aantal", "Max bedrag")
