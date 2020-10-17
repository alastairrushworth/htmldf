library(tidyverse)

# gather current test list
html_files <- 
  list.files('tests/testthat/testdata', pattern = '.html$') %>%
  gsub('.html', '', .)

# gather test file names from the attributes file
source('tests/testthat/testdata/page_attrs.R')
# see if there are any new tests to fetch
new_tests <- names(url_list)[!names(url_list) %in% html_files]

for(i in seq_along(new_tests)){
  print(i)
  download.file(url_list[[new_tests[i]]]$url,
                destfile = paste0('tests/testthat/testdata/', new_tests[i], '.html'))
}
