
here::i_am("code/model.R")

library(glmnet)
library(dplyr)

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

saveRDS(
  model_coeffs,
  file = here::here("output/model_coeffs.rds")
)
