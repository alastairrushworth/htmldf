library(rtweet)
library(htmldf)
library(rvest)
library(tidyverse)
library(ranger)
library(stringr)

load("page_inference/code_classification/ddf.RData")

get_code_text <- function(x){
  if('xml_document' %in% class(x)){
    # combine pre, code and text area tags
    pre_tags  <- html_text(html_nodes(x, "pre"))
    code_tags <- html_text(html_nodes(x, "code"))
    area_tags <- html_text(html_nodes(x, "textarea"))
    code      <- c(pre_tags, code_tags, area_tags)
    # remove everything between # and \n - these are usually comments
    code <- gsub("#.*?\n", " ", code)
    # split by \n
    code <- unlist(strsplit(code, "\n"))
    # remove \r code
    code <- paste(gsub("\r", "", code), collapse = " ")
  } else {
    code <- NA
  }
  # return code text
  code
}

code_features <- function(code){
    # get the number of occurences of certain syntaxes
    items <- c("<-", "::", "\\.", "%>%", "\\(\\)", "\\(", "\\)", 
               "\\[", "\\]", "__", " + ", "\\{", "\\}", 
               "\\$", "function\\((.*?)\\)", 
               "library\\((.*?)\\)", "install.packages\\((.*?)\\)",
               "import ", "def ", "pandas", "from ",  "numpy",
               "geom_", "pip install", "python", "dplyr",
               "\\.py", "\\.r")
    # count up the number of occurences of the patterns above
    code_pattern_counts <- lapply(tolower(code), str_count, pattern = items)
    xout           <- as.data.frame(do.call("rbind", code_pattern_counts))
    cnts           <- rowSums(xout)
    cnts[cnts == 0] <- 1
    xout           <- xout / cnts
    xout
}


# get features from code vector
z      <- code_features(ddf$code_text)
z$lang <- as.factor(ddf$code_lang)

# create a train / test split
set.seed(1226)
sample_inds <- sample(1:nrow(z), 200)
train  <- z[-sample_inds, ]
test   <- z[ sample_inds, ]

# train the language classifier
code_lang_classifier <- ranger(lang ~ ., num.trees = 1000, data = train)
test_pred <- predict(code_lang_classifier, data = test)
save(code_lang_classifier, file = "/Users/alastairrushworth/Documents/git_repositories/htmldf/R/sysdata.rda")

table(test_pred$predictions, test$lang)
xx <- ddf[as.integer(rownames(test[which(as.character(test_pred$predictions) != test$lang), ])), ]
xx$url2



# gather tweets from icmyi_r
t_r    <- get_timeline('icymi_r', n = 3200)
urls_r <- unique(unlist(t_r$urls_expanded_url))
urls_r <- urls_r[!is.na(urls_r)]

# gather tweets from icymi_py
t_py   <- get_timeline('icymi_py', n = 3200)
urls_p <- unique(unlist(t_py$urls_expanded_url))
urls_p <- urls_p[!is.na(urls_p)]

# gather julia tweets from #julialang hashtag


# gather html for r
html_r <- html_df(urls_r)
html_p <- html_df(urls_p)
html_r$code_lang <- 'r'
html_p$code_lang <- 'py'
ddf    <- bind_rows(html_r, html_p)


get_code_text <- function(x){
  if('xml_document' %in% class(x)){
    # combine pre, code and text area tags
    pre_tags  <- html_text(html_nodes(x, "pre"))
    code_tags <- html_text(html_nodes(x, "code"))
    area_tags <- html_text(html_nodes(x, "textarea"))
    code      <- c(pre_tags, code_tags, area_tags)
    # remove everything between # and \n - these are usually comments
    code <- gsub("#.*?\n", " ", code)
    # split by \n
    code <- unlist(strsplit(code, "\n"))
    # remove \r code
    code <- paste(gsub("\r", "", code), collapse = " ")
  } else {
    code <- NA
  }
  # return code text
  code
}

# get code from blogs, create new dfs
code_text <- lapply(ddf$source, get_code_text)
ddf$code_text <- code_text

# create data frames from each bit of data
ddf <- ddf %>% filter(!is.na(code_text) & nchar(code_text) > 0)

# save this dataframe for later use
save(ddf, file = 'ddf.RData')



# tt  <- tibble(as.data.frame(zz$importance), nm = rownames(zz$importance)) 
# wft <- tt %>% arrange(MeanDecreaseGini) %>% slice(1:5) %>% .$nm %>% gsub('V', '', .) %>% as.integer
# items[wft]

