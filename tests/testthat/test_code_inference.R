context("Code language inference")

#
# r tests
test_that("Test R (1)", {
  # example
  z    <- html_df(paste0('file://', normalizePath('testdata'), '/ar_tdf.html'))
  expect_gt(z$code_lang, 0.6)
})

test_that("Test R (2)", {
  # example
  z    <- html_df(paste0('file://', normalizePath('testdata'), '/mcdonnell.html'))
  expect_gt(z$code_lang, 0.6)
})

test_that("Test R (3)", {
  # example
  z    <- html_df(paste0('file://', normalizePath('testdata'), '/revo.html'))
  expect_gt(z$code_lang, 0.6)
})


#
# python tests
test_that("Test Python (1)", {
  # example
  z    <- html_df(paste0('file://', normalizePath('testdata'), '/tflow.html'))
  expect_lt(z$code_lang, -0.6)
})

test_that("Test Python (2)", {
  # example
  z    <- html_df(paste0('file://', normalizePath('testdata'), '/mlplus.html'))
  expect_lt(z$code_lang, -0.6)
})

test_that("Test Python (3)", {
  # example
  z    <- html_df(paste0('file://', normalizePath('testdata'), '/vdp.html'))
  expect_lt(z$code_lang, -0.5)
})





