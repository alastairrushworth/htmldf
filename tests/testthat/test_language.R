context("Natural language inference")

# read list of available test pages
source(paste0(normalizePath('testdata'), '/page_attrs.R'))
# vector of pages to read
pgs_html <- names(url_list)
page_vec <- paste0('file://', normalizePath('testdata'), '/', pgs_html, '.html')

# Test for inferred language in pages
for(i in seq_along(page_vec)){
  test_that(paste(pgs_html[i], 'has correct inferred language'), {
    # grab page source from test data
    z         <- html_df(page_vec[i])
    
    if(is.na(url_list[[pgs_html[i]]]$lang)){
      expect_equal(z$lang, NA)
    } else {
      expect_equal(as.vector(z$lang), url_list[[pgs_html[i]]]$lang)
    }
  })
}