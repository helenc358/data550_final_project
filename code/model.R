here::i_am("code/model.R")

library(gglasso)
library(dplyr)
library(broom)
library(doParallel)
library(gtsummary)
library(broom.helpers)
library(broom.mixed)

shoe_data <- read.csv(
  file = here::here("data/global_sports_footwear_sales_2018_2026.csv")
)

shoe_data$year <- as.integer(substr(shoe_data$order_date, 1, 4)) # create year variable
shoe_data_reorder <- shoe_data %>% relocate(revenue_usd)

# Look only at data from 2022-2026
final_data <- shoe_data_reorder %>%
  filter(year >= 2022) %>%
  select(revenue_usd, brand, category, gender, size, color, discount_percent, sales_channel, units_sold,
         payment_method, country, customer_income_level, customer_rating)

# Relevel variables
final_data$category <- factor(final_data$category, levels = c("Lifestyle", "Basketball", "Gym", "Running", "Training"))
final_data$sales_channel <- factor(final_data$sales_channel, levels = c("Retail Store", "Online"))
final_data$country <- factor(final_data$country, levels = c("USA", "Germany", "India", "Pakistan", "UAE", "UK"))
final_data$payment_method <- factor(final_data$payment_method, levels = c("Cash", "Card", "Wallet", "Bank Transfer"))
final_data$customer_income_level <- factor(final_data$customer_income_level, levels = c("Low", "Medium", "High"))

# For group lasso
num_brands <- length(unique(final_data$brand))
num_categories <- length(unique(final_data$category))
num_gender <- length(unique(final_data$gender))
num_color <- length(unique(final_data$color))
num_sales_channel <- length(unique(final_data$sales_channel))
num_payment_method <- length(unique(final_data$payment_method))
num_country <- length(unique(final_data$country))
num_customer_income_level <- length(unique(final_data$customer_income_level))

group_indices <- c(rep(1, num_brands-1), rep(2, num_categories-1), rep(3, num_gender-1), 4, rep(5, num_color-1), 6,
                   rep(7, num_sales_channel-1), 8, rep(9, num_payment_method-1), rep(10, num_country-1), rep(11, num_customer_income_level-1), 12)

set.seed(123)

shoe_Y <- final_data$revenue_usd
shoe_X <- model.matrix(revenue_usd ~ ., data = final_data)[, -1]
train_index <- sample(1:nrow(final_data), 0.7 * nrow(final_data)) # 70%/30% training/testing split

shoe_X_train <- shoe_X[train_index, ]
shoe_Y_train <- shoe_Y[train_index]

shoe_X_test <- shoe_X[-train_index, ]
shoe_Y_test <- shoe_Y[-train_index]

# Parallelism so code runs faster
num_cores <- detectCores() - 1
cluster_for_parallel_comp <- makeCluster(num_cores)
registerDoParallel(cluster_for_parallel_comp)

# Group lasso with 5-fold CV 
set.seed(123)
cv_fit <- cv.gglasso(shoe_X_train, shoe_Y_train, group_indices, loss = "ls", nfolds = 5)

stopCluster(cluster_for_parallel_comp)
# Source: https://www.r-bloggers.com/2024/01/r-doparallel-a-brain-friendly-introduction-to-parallelism-in-r/

# Get coefficients
model_coeffs <- as.matrix(coef(cv_fit$gglasso.fit, s = cv_fit$lambda.min))

# Test set CV RMSE
test_y <- predict(cv_fit, as.matrix(shoe_X_test), type = "link", s = "lambda.min")
sqrt(mean((as.matrix(test_y) - as.matrix(shoe_Y_test)) ^ 2))

# Re-run linear regression with the variables that had non-zero coefficients
# Renamed cols for clarity in the final table
final_data <- final_data %>%
  rename(Brand = brand,
         Gender = gender,
         Color = color,
         `Discount Percent` = discount_percent,
         `Units Sold` = units_sold,
         `Payment Method` = payment_method,
         `Customer Income Level` = customer_income_level,
         `Customer Rating` = customer_rating)

model <- lm(revenue_usd ~ Brand + Gender + Color + `Discount Percent` + `Units Sold` + `Payment Method` + `Customer Income Level` + `Customer Rating`, data = final_data)

# Make well-formatted table
model1_summ <- tbl_regression(model)

saveRDS(
  model_coeffs,
  file = here::here("output/model_coeffs.rds")
)

saveRDS(
  model1_summ,
  file = here::here("output/model1_summ.rds")
)
