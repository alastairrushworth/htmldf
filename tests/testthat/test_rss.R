context("RSS feeds")

# WORDPRESS
test_that("Wordpress RSS feeds", {
  # Mike Spencer
  urlx <- c('https://scottishsnow.wordpress.com/')
  z    <- html_df(urlx)
  expect_equal(z$rss[[1]],   
               c("https://scottishsnow.wordpress.com/feed/",  
                 "https://scottishsnow.wordpress.com/comments/feed/"))
  # Andrew Gelman
  urlx <- c('https://statmodeling.stat.columbia.edu/')
  z    <- html_df(urlx)
  expect_equal(z$rss[[1]],   
               c("https://statmodeling.stat.columbia.edu/feed/",         
                 "https://statmodeling.stat.columbia.edu/comments/feed/"))
})

# JEKYLL
test_that("Jekyll RSS feeds", {
  # Alastair Rushworth
  urlx <- c('https://alastairrushworth.github.io/')
  z    <- html_df(urlx)
  expect_equal(z$rss[[1]], "https://alastairrushworth.github.io/feed.xml")
  # Alastair Rushworth
  urlx <- c('http://varianceexplained.org/')
  z    <- html_df(urlx)
  expect_equal(z$rss[[1]], "http://varianceexplained.org/feed.xml")
})

# HUGO
test_that("Hugo RSS feeds", {
  # Maelle Salmon
  urlx <- c('https://masalmon.eu/post/')
  z    <- html_df(urlx)
  expect_equal(z$rss[[1]], "https://masalmon.eu/post/index.xml")
})

# BLOGSPOT
test_that("Hugo RSS feeds", {
  # Amy Hogan
  urlx <- c('http://alittlestats.blogspot.com/')
  z    <- html_df(urlx)
  expect_equal(z$rss[[1]], 
               c("http://alittlestats.blogspot.com/feeds/posts/default?alt=rss", 
                 "http://alittlestats.blogspot.com/feeds/posts/default",
                 "https://www.blogger.com/feeds/6875495717243167933/posts/default"))
})




