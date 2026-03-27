here::i_am("code/make_boxplots.R")

shoe_data <- read.csv(
  file = here::here("data/global_sports_footwear_sales_2018_2026.csv")
)

library(ggplot2)
library(forcats)

boxplot1 <- ggplot(shoe_data, aes(x = fct_reorder(brand, revenue_usd, .fun = median), 
                                     y = revenue_usd, color = brand)) + 
  geom_boxplot() + 
  theme_bw() + 
  labs(x = "Shoe Brand", y = "Revenue (in USD)", color = "Shoe Brand",
       title = "Boxplot of Revenue (in USD) by Shoe Brand")

boxplot2 <- ggplot(shoe_data, aes(x = fct_reorder(category, revenue_usd, .fun = median), 
                      y = revenue_usd, color = category)) + 
  geom_boxplot() + 
  theme_bw() + 
  labs(x = "Shoe Category", y = "Revenue (in USD)", color = "Shoe Category",
       title = "Boxplot of Revenue (in USD) by Shoe Category")

ggsave(
  here::here("output/boxplot1.png"), 
  plot = boxplot1,
  device = "png"
)

ggsave(
  here::here("output/boxplot2.png"), 
  plot = boxplot2,
  device = "png"
)
