context("Publication date detection")

# read list of available test pages
source(paste0(normalizePath('testdata'), '/page_attrs.R'))
# vector of pages to read
pgs_html <- names(url_list)
page_vec <- paste0('file://', normalizePath('testdata'), '/', pgs_html, '.html')

# Test for inferred code content in pages
for(i in seq_along(page_vec)){
  test_that(paste(pgs_html[i], 'detection of published date'), {
    # grab page source from test data
    pg_htm       <- xml2::read_html(file(page_vec[i]))
    pg_tim       <- get_time(pg_htm, url = url_list[[pgs_html[i]]]$url)
    if(any(is.na(url_list[[pgs_html[i]]]$pdate))){
      expect_equal(pg_tim, NA_character_)
    } else {
      expect_equal(pg_tim, url_list[[pgs_html[i]]]$pdate)
    }
  })
}


