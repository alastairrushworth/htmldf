context("RSS feed detection")

# read list of available test pages
source(paste0(normalizePath('testdata'), '/page_attrs.R'))
# vector of pages to read
pgs_html <- names(url_list)
page_vec <- paste0('file://', normalizePath('testdata'), '/', pgs_html, '.html')

# Test for inferred code content in pages
for(i in seq_along(page_vec)){
  test_that(paste(pgs_html[i], 'finds RSS feeds'), {
    # grab page source from test data
    pg_htm       <- xml2::read_html(file(page_vec[i]))
    pg_rss       <- get_rss(pg_htm, url = url_list[[pgs_html[i]]]$url)
    if(any(is.na(url_list[[pgs_html[i]]]$rss))){
      expect_equal(pg_rss, NA)
    } else {
      expect_equal(as.vector(pg_rss), url_list[[pgs_html[i]]]$rss)
    }
  })
}


