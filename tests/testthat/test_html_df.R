context("html_df")


test_that("html_df works", {
  urlx <- c("https://github.com/alastairrushworth/inspectdf",
            "https://ropensci.org/blog/2020/02/21/ropensci-leadership/",
            "https://es.wikipedia.org/wiki/Wikipedia_en_espa%C3%B1ol",
            'www.sjdhjshf.com')
  z <- html_df(urlx)
  expect_equal(z$lang[3], 'es')
  expect_that(is.na(z$lang[4]), equals(TRUE))
})


