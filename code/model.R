
here::i_am("code/model.R")

library(glmnet)
library(dplyr)
library(broom)

shoe_data <- read.csv(
  file = here::here("data/global_sports_footwear_sales_2018_2026.csv")
)

shoe_data$year <- as.integer(substr(shoe_data$order_date, 1, 4))
shoe_data_reorder <- shoe_data %>% relocate(revenue_usd)

shoe_Y <- shoe_data_reorder$revenue_usd
final_data <- shoe_data_reorder %>% select(revenue_usd, brand, category, gender, size, color, discount_percent, sales_channel, units_sold,
                                           payment_method, sales_channel, country, customer_income_level, customer_rating, year)
shoe_X <- model.matrix(revenue_usd ~ ., data = final_data)[, -1]

set.seed(123)
train_index <- sample(1:nrow(final_data), 0.7 * nrow(final_data))

shoe_X_train <- shoe_X[train_index, ]
shoe_Y_train <- shoe_Y[train_index]
shoe_X_test <- shoe_X[-train_index, ]
shoe_Y_test <- shoe_Y[-train_index]

# Coefficients chosen
fit_model <- cv.glmnet(shoe_X_train, shoe_Y_train, nfolds = 5)
model_coeffs <- as.matrix(coef(fit_model, s = 'lambda.min'))

# Modeling:
library(lmerTest)
mod <- lmer(revenue_usd ~ (1 | units_sold), data = final_data)
performance::icc(mod) # since ICC was quite large, we should consider doing a model with a random intercept for units_sold

final_data$category <- factor(final_data$category, levels = c("Lifestyle", "Basketball", "Gym", "Running", "Training"))
final_data$sales_channel <- factor(final_data$sales_channel, levels = c("Retail Store", "Online"))
final_data$country <- factor(final_data$country, levels = c("USA", "Germany", "India", "Pakistan", "UAE", "UK"))
final_data$payment_method <- factor(final_data$payment_method, levels = c("Cash", "Card", "Wallet", "Bank Transfer"))
final_data$customer_income_level <- factor(final_data$customer_income_level, levels = c("Low", "Medium", "High"))

model <- lmer(revenue_usd ~ brand + category + gender + size + color + discount_percent +
                sales_channel + country + payment_method + customer_income_level + customer_rating + year + (1|units_sold), data = final_data)

library(gtsummary)
library(broom.helpers)
library(broom.mixed)
model1_summ <- tbl_regression(model)

saveRDS(
  model_coeffs,
  file = here::here("output/model_coeffs.rds")
)

saveRDS(
  model1_summ,
  file = here::here("output/model1_summ.rds")
)