context("RSS feed detection")

# WORDPRESS
test_that("Wordpress RSS feeds", {
  # Mike Spencer
  z    <- html_df(paste0('file://', normalizePath('testdata'), '/spencer.html'))
  expect_equal(z$rss[[1]],   
               c("https://scottishsnow.wordpress.com/feed/",  
                 "https://scottishsnow.wordpress.com/comments/feed/"))
  # Andrew Gelman
  z    <- html_df(paste0('file://', normalizePath('testdata'), '/gelman.html'))
  expect_equal(z$rss[[1]],
               c("https://statmodeling.stat.columbia.edu/feed/",
                 "https://statmodeling.stat.columbia.edu/comments/feed/"))
})

# JEKYLL
test_that("Jekyll RSS feeds", {
  # Alastair Rushworth
  z    <- html_df(paste0('file://', normalizePath('testdata'), '/rushworth.html'))
  expect_equal(z$rss[[1]], "https://alastairrushworth.github.io/feed.xml")
  # David Robinson
  z    <- html_df(paste0('file://', normalizePath('testdata'), '/robinson.html'))
  expect_equal(z$rss[[1]], "http://varianceexplained.org/feed.xml")
})


# # HUGO
test_that("Hugo RSS feeds", {
  # Maelle Salmon
  z    <- html_df(paste0('file://', normalizePath('testdata'), '/salmon.html'))
  expect_equal(z$rss[[1]], "https://masalmon.eu/post/index.xml")
})


# BLOGSPOT
test_that("Hugo RSS feeds", {
  # Amy Hogan
  z    <- html_df(paste0('file://', normalizePath('testdata'), '/hogan.html'))
  expect_equal(z$rss[[1]],
               c("http://alittlestats.blogspot.com/feeds/posts/default?alt=rss",
                 "http://alittlestats.blogspot.com/feeds/posts/default",
                 "https://www.blogger.com/feeds/6875495717243167933/posts/default"))
})




