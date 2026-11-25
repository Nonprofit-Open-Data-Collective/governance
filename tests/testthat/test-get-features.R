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

test_that("consolidated audited statements (Part IV 12b) count as audited", {
  raw <- make_raw(4)
  raw$F9_04_AFS_IND_X    <- c("true", "false", "false", "1")
  raw$F9_04_AFS_CONSOL_X <- c("false", "true", "", "0")
  f <- get_features(raw)
  expect_equal(f$P4_LINE_12, c(1, 1, 0, 1))
})

test_that("without F9_04_AFS_CONSOL_X, P4_LINE_12 falls back to line 12a with a message", {
  raw <- make_raw(2)
  raw$F9_04_AFS_IND_X <- c("true", "false")
  raw$F9_04_AFS_CONSOL_X <- NULL
  msgs <- character()
  f <- withCallingHandlers(get_features(raw), message = function(m) {
    msgs <<- c(msgs, conditionMessage(m)); invokeRestart("muffleMessage")
  })
  expect_true(any(grepl("line 12a only", msgs)))
  expect_equal(f$P4_LINE_12, c(1, 0))
})

test_that("get_features appends the 16 index items and 5 risk indicators", {
  f <- get_features(make_raw(1))
  expect_true(all(gi_cols %in% names(f)))
  expect_equal(unname(unlist(f[1, gi_cols])), rep(1, 16))
  risks <- c("RISK_INSIDER_BIZ", "RISK_LOAN", "RISK_FAM_TIES", "RISK_MGMT_CO", "RISK_DIVERSION")
  expect_equal(unname(unlist(f[1, risks])), rep(0, 5))
})

test_that("COI sub-items are 0 without a policy and NA when blank", {
  raw <- make_raw(3)
  raw$F9_06_POLICY_COI_X <- c("true", "false", "")
  raw$F9_06_POLICY_COI_DISCLOSURE_X <- c("false", "", "")
  f <- get_features(raw)
  expect_equal(f$GI_COI, c(1, 0, NA))
  expect_equal(f$GI_COI_DISCLOSE, c(0, 0, NA))
})

test_that("audit committee is 0 when there is no review or audit", {
  raw <- make_raw(2)
  raw$F9_12_FINSTAT_AUDIT_X <- "false"; raw$F9_12_FINSTAT_COMPILE_X <- "false"
  raw$F9_04_AFS_IND_X <- "false"; raw$F9_04_AFS_CONSOL_X <- "false"
  raw$F9_12_FINSTAT_AUDIT_COMMITTEE_X <- c("", "true")
  f <- get_features(raw)
  expect_equal(f$GI_REVIEW_AUDIT, c(0, 0))
  expect_equal(f$GI_AUDIT_CMTE, c(0, 0))
})

test_that("missing 2023 fields give a message, not an error", {
  raw <- make_raw(1)
  raw$F9_12_FINSTAT_AUDIT_COMMITTEE_X <- NULL
  expect_message(f <- get_features(raw), "F9_12_FINSTAT_AUDIT_COMMITTEE_X")
  expect_true(is.na(f$GI_AUDIT_CMTE) || f$GI_AUDIT_CMTE == 0)
})
