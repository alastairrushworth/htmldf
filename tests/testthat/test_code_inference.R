context("Code language inference")

#
# r tests
test_that("Test R (1)", {
  # example
  x <- html_df("https://alastairrushworth.github.io/Visualising-Tour-de-France-data-in-R/")
  expect_equal(x$code_lang, 'r')
})

test_that("Test R (2)", {
  # example
  x <- html_df("https://www.robertmylesmcdonnell.com/content/posts/mtcars/")
  expect_equal(x$code_lang, 'r')
})

test_that("Test R (3)", {
  # example
  x <- html_df("https://blog.revolutionanalytics.com/2020/05/azurevision.html")
  expect_equal(x$code_lang, 'r')
})


#
# python tests
test_that("Test Python (1)", {
  # example
  x <- html_df("https://www.tensorflow.org/tutorials/images/cnn")
  expect_equal(x$code_lang, 'py')
})

test_that("Test Python (2)", {
  # example
  x <- html_df("https://www.machinelearningplus.com/plots/matplotlib-tutorial-complete-guide-python-plot-examples/")
  expect_equal(x$code_lang, 'py')
})

test_that("Test Python (3)", {
  # example
  x <- html_df("https://jakevdp.github.io/PythonDataScienceHandbook/02.02-the-basics-of-numpy-arrays.html")
  expect_equal(x$code_lang, 'py')
})





