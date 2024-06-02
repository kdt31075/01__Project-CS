# TEST
pacman::p_load(DBI, RMySQL, tidyverse, rio, here, skimr, lubridate, knitr,
               scales, cowplot, grid, magick, tidyr, janitor, officer,
               flextable, ggplot2, ggrepel, stringr, patchwork,
               plotly, DT, RColorBrewer)

A <- c("a", "b", "c", "d", "e", "f", "g")
B <- c("1", "02", "c","3", "04","e", "5")
df <- data.frame("Kolom_A"= A, "Kolom_B" = B)

# -------------------------------------------------------------------------------
# SOLUTION 1

value <- df$"Kolom_B"
newvalue <- lapply(value, function(val) {
            switch(val,
                    "1" = "01",
                    "2" = "02",
                    "3" = "03",
                    "4" = "04",
                    "5" = "05",
                    "6" = "06",
                    "7" = "07",
                    "8" = "08",
                    "9" = "09",
                    val  # default case, returns the original value if not matched
                    )
                    })

newvalue


# -------------------------------------------------------------------------------
# SOLUTION 2

df$NewValue <- ifelse(df$Kolom_B %in% c("1", "2", "3", "4", "5", "6", "7", "8", "9"),
                      sprintf("%02d", as.numeric(df$Kolom_B)),
                      df$Kolom_B)

df








