context("Natural language inference")

# gather the names of all of the test files
test_html <- 
  list.files(normalizePath('testdata'), pattern = '\\.html', full.names = TRUE) %>%
  paste0('file://', .)


test_that("Spanish language", {
  z <- html_df(test_html, show_progress = FALSE)
  expect_equal(z$lang, c("en", "en", "en", "en", "en", "en", "en", "en", NA,
                         "en", "en", "en", "en", "en", "en", NA,  "en", "en",
                         "en", "en", "en", "en", "en", "en", "en", NA,  "en", 
                         "en", "es"))
})

