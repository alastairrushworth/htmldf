context("Twitter handles")

test_that("Get twitter handles from embedded page links", {
  # example
  tt <- twitter_handles_from_urls('https://twitter.com/blahblahblah')
  expect_equal(tt, '@blahblahblah')
})

test_that("Resolve user from status url", {
  # example
  tt <- twitter_handles_from_urls('https://twitter.com/rushworth_a/status/1264143140799369216?ref_src=twsrc%5Egoogle%7Ctwcamp%5Eserp%7Ctwgr%5Etweet')
  expect_equal(tt, '@rushworth_a')
})


test_that("Resolve user from status url", {
  # example
  tt <- twitter_handles_from_urls('https://twitter.com/icymi_r/with_replies')
  expect_equal(tt, '@icymi_r')
})

