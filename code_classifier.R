library(rvest)
library(tidyverse)
library(ranger)
library(stringr)
source("page_inference/code_classification/helper_functions.R")
load("page_inference/code_classification/ddf.RData")

# get features from code vector
z      <- code_features(ddf$code_text)
z$lang <- as.factor(ddf$code_lang)

# create a train / test split
set.seed(1226)
sample_inds <- sample(1:nrow(z), 200)
train  <- z[-sample_inds, ]
test   <- z[ sample_inds, ]

# train the language classifier
code_lang_classifier <- ranger(lang ~ ., num.trees = 500, data = train)
test_pred <- predict(code_lang_classifier, data = test)
# save the language classifier
save(code_lang_classifier, file = "R/sysdata.rda")

# table(test_pred$predictions, test$lang)
# xx <- ddf[as.integer(rownames(test[which(as.character(test_pred$predictions) != test$lang), ])), ]
# xx$url2



