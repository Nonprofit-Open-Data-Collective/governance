# Write dat_example out as the four source efile tables in a local directory,
# so panel990 can "download" them from a local root -- no network needed.
write_local_source <- function(dir, year = 2022, ez_rows = 0) {
  utils::data("dat_example", package = "governance", envir = environment())
  # Add EIN2 (formatted) as the real efile tables carry it.
  dat_example$EIN2 <- paste0("EIN-", substr(dat_example$ORG_EIN, 1, 2), "-",
                             substr(dat_example$ORG_EIN, 3, 9))
  if (ez_rows > 0) dat_example$RETURN_TYPE[seq_len(ez_rows)] <- "990EZ"
  keys <- c("EIN2", "OBJECTID", "ORG_EIN", "ORG_NAME_L1", "RETURN_TYPE", "TAX_YEAR")
  groups <- list(
    "F9-P04-T00-REQUIRED-SCHEDULES"   = grep("^F9_04", names(dat_example), value = TRUE),
    "F9-P06-T00-GOVERNANCE"           = grep("^F9_06", names(dat_example), value = TRUE),
    "F9-P12-T00-FINANCIAL-REPORTING"  = grep("^F9_12", names(dat_example), value = TRUE),
    "SM-P01-T00-NONCASH-CONTRIBUTIONS" = grep("^SM_",  names(dat_example), value = TRUE)
  )
  for (table in names(groups)) {
    utils::write.csv(
      dat_example[, c(keys, groups[[table]])],
      file.path(dir, paste0(table, "-", year, ".CSV")),
      row.names = FALSE
    )
  }
  invisible(dir)
}

test_that("get_governance_data imports and assembles the required fields", {
  skip_if_not_installed("panel990")
  root <- tempfile("efsrc"); dir.create(root)
  write_local_source(root, year = 2022)

  dat <- get_governance_data(
    years = 2022, source = panel990::data_source(root = root), verbose = FALSE
  )

  expect_s3_class(dat, "data.frame")
  expect_true("ORG_EIN" %in% names(dat))
  expect_true(all(governance:::.gov_fields %in% names(dat)))
  expect_gt(nrow(dat), 0)
})

test_that("imported data yields the same features as the bundled example", {
  skip_if_not_installed("panel990")
  root <- tempfile("efsrc"); dir.create(root)
  write_local_source(root, year = 2022)
  data("dat_example", package = "governance")

  dat <- get_governance_data(
    years = 2022, source = panel990::data_source(root = root), verbose = FALSE
  )

  feats <- c("P12_LINE_1", "P4_LINE_12", "P4_LINE_28", "P4_LINE_29_30",
             "P6_LINE_1", "P6_LINE_11A", "P6_LINE_15A", "P6_LINE_18",
             "P6_LINE_2", "P6_LINE_3", "P6_LINE_8A", "P6_LINE_12_13_14")
  a <- get_features(dat)
  b <- get_features(dat_example)
  a <- a[order(a$ORG_EIN), feats]; rownames(a) <- NULL
  b <- b[order(b$ORG_EIN), feats]; rownames(b) <- NULL
  expect_equal(a, b)
})

test_that("get_governance_data keeps only full-990 filers", {
  skip_if_not_installed("panel990")
  root <- tempfile("efsrc"); dir.create(root)
  write_local_source(root, year = 2022, ez_rows = 25)

  dat <- get_governance_data(
    years = 2022, source = panel990::data_source(root = root), verbose = FALSE
  )
  expect_true(all(dat$RETURN_TYPE == "990"))
  expect_false(any(dat$RETURN_TYPE == "990EZ"))
})

test_that("get_governance_scores runs the full pipeline", {
  skip_if_not_installed("panel990")
  root <- tempfile("efsrc"); dir.create(root)
  write_local_source(root, year = 2022)

  scores <- get_governance_scores(
    years = 2022, source = panel990::data_source(root = root), verbose = FALSE
  )
  expect_true("total.score" %in% names(scores))
  expect_gt(nrow(scores), 0)
})

test_that("get_governance_data errors clearly when panel990 is missing", {
  # Simulate absence by masking requireNamespace within the function's namespace.
  skip_if_not_installed("mockery")
  mockery::stub(get_governance_data, "requireNamespace", function(...) FALSE)
  expect_error(get_governance_data(2022), "panel990")
})
