test_that("get_scores appends six factor scores and a total", {
  f <- get_features(get_dat_example_sample())
  s <- get_scores(f)
  expect_true("total.score" %in% names(s))
  # six factor-score columns are appended beyond the input
  expect_equal(ncol(s) - ncol(f), 7L)
  expect_equal(nrow(s), nrow(f))
})

test_that("scores are reproducible", {
  f  <- get_features(get_dat_example_sample())
  s1 <- get_scores(f)
  s2 <- get_scores(f)
  expect_equal(s1$total.score, s2$total.score)
})

test_that("an entirely-NA feature column is caught, not silently scored", {
  f <- get_features(get_dat_example_sample())
  f$P12_LINE_1 <- NA
  expect_error(get_scores(f), "entirely NA")
})
