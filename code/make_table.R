here::i_am("code/make_table.R")

shoe_data <- read.csv(
  file = here::here("data/global_sports_footwear_sales_2018_2026.csv")
)

library(knitr)
library(dplyr)

shoe_data_by_country <- shoe_data %>% 
  group_by(country) %>%
  summarize(total_units_sold = sum(units_sold), total_rev = sum(revenue_usd)) %>% 
  arrange(total_rev)

df <- data.frame(shoe_data_by_country)
names(df) <- c("Country", "Total Units Sold", "Total Revenue (in USD)") # rename cols
table_1 <- kable(df, caption = "Total Units Sold and Total Revenue by Country") # format table with kable

saveRDS(
  table_1, here::here("output/table_1.rds")
)