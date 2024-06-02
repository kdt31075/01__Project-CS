

# Test pivot_wide----------------------------------------------------------------------------  

df <- data.frame(
  EntityNumber = c(1, 1, 2, 2, 2, 2, 3, 3, 3),
  ActivityGroup = c("BTW", "RSZ", "BTW", "BTW", "BTW" ,"OLK", "RSZ", "RSZ","OLK"),
  NaceCode = c("A", "B", "C", "D", "E", "F", "G", "H", "I")
)
df

tmp_A <- df %>%
  group_by(EntityNumber, ActivityGroup) %>%
  summarize(NaceCode = paste(NaceCode, collapse = ", "), .groups = 'drop')

tmp_B <- tmp_A %>%
  pivot_wider(names_from = ActivityGroup, values_from = NaceCode)

tmp_B