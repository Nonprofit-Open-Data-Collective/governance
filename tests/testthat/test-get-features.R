test_that("get_features returns the 12 binary features", {
  f <- get_features(make_raw(3))
  expect_true(all(feature_cols %in% names(f)))
  vals <- unlist(f[, feature_cols])
  expect_true(all(vals %in% c(0, 1, NA)))
})

test_that("the all-1 fixture scores 1 on every feature", {
  f <- get_features(make_raw(1))
  expect_equal(unname(unlist(f[1, feature_cols])), rep(1, length(feature_cols)))
})

test_that("Part XII accrual is detected when 'other' is blank (regression)", {
  # F9_12_FINSTAT_METHOD_ACC_OTH is "" (as read by fread), not NA. The old code
  # tested is.na() and mislabeled every filer as 'other', zeroing P12_LINE_1.
  raw <- make_raw(1)
  expect_equal(get_features(raw)$P12_LINE_1, 1)

  cash <- make_raw(1)
  cash$F9_12_FINSTAT_METHOD_ACC_ACCRU_X <- ""
  cash$F9_12_FINSTAT_METHOD_ACC_CASH_X  <- "X"
  expect_equal(get_features(cash)$P12_LINE_1, 0)

  other <- make_raw(1)
  other$F9_12_FINSTAT_METHOD_ACC_ACCRU_X <- ""
  other$F9_12_FINSTAT_METHOD_ACC_OTH     <- "MODIFIED CASH"
  expect_equal(get_features(other)$P12_LINE_1, 0)
})

test_that("features do not depend on blank encoding (NA vs \"\")", {
  raw_blank <- make_raw(5)
  raw_na    <- raw_blank
  raw_na[raw_na == ""] <- NA          # same data, blanks as NA
  f_blank <- get_features(raw_blank)[, feature_cols]
  f_na    <- get_features(raw_na)[, feature_cols]
  expect_equal(f_blank, f_na)
})

test_that("ORG_EIN is normalized to a 9-digit string", {
  raw <- make_raw(1)
  raw$ORG_EIN <- "EIN-43-2031361"        # formatted style
  expect_equal(get_features(raw)$ORG_EIN, "432031361")

  raw2 <- make_raw(1)
  raw2$ORG_EIN <- 12345L                  # integer, leading zeros dropped
  expect_equal(get_features(raw2)$ORG_EIN, "000012345")
})

test_that("a missing input column errors and names the right column", {
  raw <- make_raw(1)
  raw$F9_06_POLICY_COI_X <- NULL
  expect_error(get_features(raw), "F9_06_POLICY_COI_X")
})
