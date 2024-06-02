# Load packages
pacman::p_load(dplyr, data.table, table.express, tidyverse, stringr)


dt1 <- data.table(id = c("AC", "B", "CC"), value1 = 1:3)
dt2 <- data.table(id = c("AC", "CC", "D"), value2 = 41:43)

print(dt1)
print(dt2)

# Inner join
result_inner1 <- dt1[dt2, on = "id"]
print(result_inner1)
result_inner2 <- dt2[dt1, on = "id"]
print(result_inner2)

result_inner3 <- dt1 %>%
  inner_join(dt2, "id")
print(result_inner3)
