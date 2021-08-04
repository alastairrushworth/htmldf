context("Social profiles")
# read list of available test pages
source(paste0(normalizePath('testdata'), '/page_attrs.R'))
# vector of pages to read
pgs_html <- names(url_list)
page_vec <- paste0('file://', normalizePath('testdata'), '/', pgs_html, '.html')

# Test for social profiles content in pages
for(i in seq_along(page_vec)){
  test_that(paste('\n', page_vec[i], 'detected social profiles'), {
    # grab page source from test data
    z         <- html_df(page_vec[i])
    profiles  <- url_list[[pgs_html[i]]]$social
    if(length(profiles) == 0){
      expect_equal(length(z$social[[1]]$profile), 0)
    } else {
      expect_equal(
        sort(tolower(z$social[[1]]$profile)), 
        sort(tolower(profiles))
      )
    }
  })
}


