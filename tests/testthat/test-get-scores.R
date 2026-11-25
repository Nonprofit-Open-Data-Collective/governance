# ---- 2023 model (default) ---------------------------------------------------

score_cols <- c("gov_score", "gov_score_se", "gov_score_bf", "gov_s_finance", "gov_s_minutes",
                "gov_s_policy", "gov_s_comp", "gov_count", "gov_n_items")

test_that("get_scores appends the 2023 index columns by default", {
  f <- get_features(get_dat_example_sample())
  s <- get_scores(f)
  expect_true(all(score_cols %in% names(s)))
  expect_equal(ncol(s) - ncol(f), length(score_cols))
  expect_equal(nrow(s), nrow(f))
  expect_true(all(s$gov_count >= 0 & s$gov_count <= 16, na.rm = TRUE))
  expect_true(all(s$gov_score_se > 0, na.rm = TRUE))
})

test_that("2023 scores are reproducible", {
  f  <- get_features(get_dat_example_sample())
  expect_equal(get_scores(f)$gov_score, get_scores(f)$gov_score)
})

test_that("scores do not depend on which other organizations are scored", {
  f <- get_features(get_dat_example_sample(60))
  all_rows <- get_scores(f)$gov_score
  first_ten <- get_scores(f[1:10, ])$gov_score
  expect_equal(first_ten, all_rows[1:10], tolerance = 1e-6)
})

test_that("more practices give a higher general score", {
  f <- get_features(make_raw(2))
  f[2, gi_cols] <- 0
  s <- get_scores(f)
  expect_gt(s$gov_score[1], s$gov_score[2])
  expect_equal(s$gov_count, c(16, 0))
})

test_that("rows with no answered items get NA scores", {
  f <- get_features(make_raw(2))
  f[2, gi_cols] <- NA
  s <- get_scores(f)
  expect_true(is.na(s$gov_score[2]))
  expect_equal(s$gov_n_items, c(16, 0))
  expect_false(is.na(s$gov_score[1]))
})

test_that("a missing 2023 item column errors and names it", {
  f <- get_features(make_raw(1))
  f$GI_COI <- NULL
  expect_error(get_scores(f), "GI_COI")
})

test_that("the shipped model has the expected structure", {
  m <- gov_model_2023
  expect_equal(m$items, gi_cols)
  expect_equal(m$year, 2023L)
  expect_gt(m$n, 100000)
})

# ---- legacy 2018 model ------------------------------------------------------

test_that("legacy model appends six factor scores and a total", {
  f <- get_features(get_dat_example_sample())
  s <- get_scores(f, model = "legacy-2018")
  expect_true("total.score" %in% names(s))
  expect_equal(ncol(s) - ncol(f), 7L)
  expect_equal(nrow(s), nrow(f))
})

test_that("legacy scores are reproducible", {
  f  <- get_features(get_dat_example_sample())
  expect_equal(get_scores(f, model = "legacy-2018")$total.score,
               get_scores(f, model = "legacy-2018")$total.score)
})

test_that("an entirely-NA legacy feature column is caught, not silently scored", {
  f <- get_features(get_dat_example_sample())
  f$P12_LINE_1 <- NA
  expect_error(get_scores(f, model = "legacy-2018"), "entirely NA")
})

# ---- the governance index ----------------------------------------------------

gi_frame <- function(v) as.data.frame(matrix(v, nrow = 1, ncol = 16, dimnames = list(NULL, gi_cols)))

test_that("the index runs from about 67 (no practices) to about 128 (all 16)", {
  s <- get_scores(rbind(gi_frame(0), gi_frame(1)))
  expect_equal(s$gov_score, c(67.33, 128.29), tolerance = 1e-3)
  expect_equal(s$gov_count, c(0, 16))
  expect_true(all(s$gov_score_se > 0))
})

test_that("adding a practice never lowers the index", {
  set.seed(2023)
  X <- as.data.frame(matrix(rbinom(16 * 40, 1, .6), ncol = 16, dimnames = list(NULL, gi_cols)))
  # respect nesting on the form: disclosure and monitoring need a COI policy,
  # an audit or audit committee needs a compilation, review, or audit
  X$GI_COI[X$GI_COI_DISCLOSE == 1 | X$GI_COI_MONITOR == 1] <- 1
  X$GI_REVIEW_AUDIT[X$GI_AUDIT == 1 | X$GI_AUDIT_CMTE == 1] <- 1
  base <- get_scores(X)$gov_score
  for (v in gi_cols) {
    off <- which(X[[v]] == 0)
    if (!length(off)) next
    Y <- X[off, ]
    Y[[v]] <- 1
    if (v %in% c("GI_COI_DISCLOSE", "GI_COI_MONITOR")) Y$GI_COI <- 1
    if (v %in% c("GI_AUDIT", "GI_AUDIT_CMTE")) Y$GI_REVIEW_AUDIT <- 1
    expect_true(all(get_scores(Y)$gov_score > base[off]), label = v)
  }
})

test_that("gov_index_2023 has the expected structure", {
  m <- gov_index_2023
  expect_length(m$items, 10)
  expect_setequal(unlist(m$bundles), gi_cols)
  expect_equal(m$year, 2023L)
  expect_gt(m$n, 100000)
  expect_true(m$sd > 0)
})
