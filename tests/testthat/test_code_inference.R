context("Code language inference")
# read list of available test pages
source(paste0(normalizePath('testdata'), '/page_attrs.R'))
# vector of pages to read
pgs_html <- names(url_list)
page_vec <- paste0('file://', normalizePath('testdata'), '/', pgs_html, '.html')

# Test for inferred code content in pages
for(i in seq_along(page_vec)){
  test_that(paste(pgs_html[i], 'has correct inferred code'), {
    # grab page source from test data
    z         <- html_df(page_vec[i])
    true_code <- url_list[[pgs_html[i]]]$code
    if(is.na(true_code)){
      expect_equal(z$code_lang, NA)
    } else if(true_code == 'py'){
      expect_lt(z$code_lang, -0.5)
    } else if(true_code == 'r'){
      expect_gt(z$code_lang, -0.5)
    } 
  })
}


