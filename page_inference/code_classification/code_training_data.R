library(rtweet)
library(htmldf)
library(rvest)
library(tidyverse)
library(stringr)
source("page_inference/code_classification/helper_functions.R")

# gather tweets from icmyi_r
t_r    <- get_timeline('icymi_r', n = 3200)
urls_r <- unique(unlist(t_r$urls_expanded_url))
urls_r <- urls_r[!is.na(urls_r)]

# gather tweets from icymi_py
t_py   <- get_timeline('icymi_py', n = 3200)
urls_p <- unique(unlist(t_py$urls_expanded_url))
urls_p <- urls_p[!is.na(urls_p)]

# add GH language info
# add mentions in text to R, RStudio, 
# create a test set that is independent of the above?s


# gather julia tweets from #julialang hashtag
# TODO

# gather html for r
html_r <- html_df(urls_r)
html_p <- html_df(urls_p)
html_r$code_lang <- 'r'
html_p$code_lang <- 'py'
ddf    <- bind_rows(html_r, html_p)

# get code from blogs, create new dfs
code_text <- lapply(ddf$source, get_code_text)
ddf$code_text <- code_text

# create data frames from each bit of data
ddf <- ddf %>% filter(!is.na(code_text) & nchar(code_text) > 0)

# save this dataframe for later use
save(ddf, file = paste0('page_inference/code_classification/ddf', Sys.Date(), '.RData'))