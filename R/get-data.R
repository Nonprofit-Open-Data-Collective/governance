# Raw 990 efile fields required to build the governance features, grouped by the
# table they come from. These are handed straight to get_features(), which does
# its own normalization -- so the tables are imported raw (not run through
# panel990::normalize(), which would coerce checkboxes to logicals).
.gov_tables <- c(
  "F9-P04-T00-REQUIRED-SCHEDULES",
  "F9-P06-T00-GOVERNANCE",
  "F9-P12-T00-FINANCIAL-REPORTING",
  "SM-P01-T00-NONCASH-CONTRIBUTIONS"
)

# Filing/header keys kept so panel990::merge_tables() can join the tables and so
# the result carries useful identifiers downstream.
.gov_keys <- c(
  "EIN2", "OBJECTID", "ORG_EIN", "ORG_NAME_L1", "RETURN_TYPE", "TAX_YEAR",
  "URL", "VERSION"
)

.gov_fields <- c(
  # Part IV
  "F9_04_AFS_IND_X", "F9_04_BIZ_TRANSAC_DTK_X", "F9_04_BIZ_TRANSAC_DTK_FAM_X",
  "F9_04_BIZ_TRANSAC_DTK_ENTITY_X", "F9_04_CONTR_NONCSH_MT_25K_X",
  "F9_04_CONTR_ART_HIST_X",
  # Part VI
  "F9_06_GVRN_NUM_VOTING_MEMB", "F9_06_GVRN_NUM_VOTING_MEMB_IND",
  "F9_06_GVRN_DTK_FAMBIZ_RELATION_X", "F9_06_GVRN_DELEGATE_MGMT_DUTY_X",
  "F9_06_GVRN_DOC_GVRN_BODY_X", "F9_06_POLICY_FORM990_GVRN_BODY_X",
  "F9_06_POLICY_COI_X", "F9_06_POLICY_COI_DISCLOSURE_X",
  "F9_06_POLICY_COI_MONITOR_X", "F9_06_POLICY_WHSTLBLWR_X",
  "F9_06_POLICY_DOC_RETENTION_X", "F9_06_POLICY_COMP_PROCESS_CEO_X",
  "F9_06_DISCLOSURE_AVBL_OTH_X", "F9_06_DISCLOSURE_AVBL_OTH_WEB_X",
  "F9_06_DISCLOSURE_AVBL_REQUEST_X", "F9_06_DISCLOSURE_AVBL_OWN_WEB_X",
  # Part XII
  "F9_12_FINSTAT_METHOD_ACC_OTH", "F9_12_FINSTAT_METHOD_ACC_ACCRU_X",
  "F9_12_FINSTAT_METHOD_ACC_CASH_X",
  # Schedule M
  "SM_01_REVIEW_PROCESS_UNUSUAL_X"
)

#' Import raw 990 governance fields via the panel990 package
#'
#' Downloads the IRS efile tables that hold the governance and management fields
#' (Form 990 Parts IV, VI, and XII and Schedule M), keeps the columns
#' \code{\link{get_features}} needs, merges them into one row per filing, and
#' drops 990EZ filers (who do not report these fields). The result is ready to
#' pass to \code{\link{get_features}}.
#'
#' Retrieval is delegated to the
#' \href{https://github.com/Nonprofit-Open-Data-Collective/panel990}{panel990}
#' package, which must be installed:
#' \code{remotes::install_github("Nonprofit-Open-Data-Collective/panel990")}.
#'
#' @param years Integer vector of tax years to import.
#' @param eins Optional character vector of formatted EINs (\code{EIN2}, e.g.
#'   \code{"EIN-43-2031361"}) to restrict the download to specific organizations.
#' @param source A \code{panel990::data_source()} configuration. Defaults to the
#'   NCCS efile v2.1 archive. Point \code{root} at a local directory to read
#'   already-downloaded tables.
#' @param cache Passed to \code{panel990::download_tables()}: \code{"temporary"}
#'   (default) uses a session temp directory; \code{"retain"} keeps a durable
#'   cache in \code{path}.
#' @param path Cache directory used when \code{cache = "retain"}.
#' @param verbose Print panel990 progress messages.
#'
#' @return A data.frame with one row per filing containing \code{ORG_EIN}, the
#'   raw governance fields, and identifier columns, ready for
#'   \code{\link{get_features}}.
#'
#' @seealso \code{\link{get_features}}, \code{\link{get_scores}},
#'   \code{\link{get_governance_scores}}.
#'
#' @examples
#' \dontrun{
#' dat <- get_governance_data(years = 2022)
#' features <- get_features(dat)
#' scores <- get_scores(features)
#' }
#'
#' @export
get_governance_data <- function(
    years,
    eins = NULL,
    source = NULL,
    cache = c("temporary", "retain"),
    path = "efdata",
    verbose = FALSE
) {
  if (!requireNamespace("panel990", quietly = TRUE)) {
    stop("The 'panel990' package is required to import efile data.\n",
         "Install it with:\n",
         "  remotes::install_github(\"Nonprofit-Open-Data-Collective/panel990\")",
         call. = FALSE)
  }
  cache <- match.arg(cache)
  if (is.null(source)) source <- panel990::data_source()

  downloads <- panel990::download_tables(
    years = years, tables = .gov_tables, source = source,
    cache = cache, path = path, verbose = verbose
  )

  filters <- if (!is.null(eins)) list(EIN2 = eins) else NULL
  reads <- panel990::read_tables(
    downloads, columns = c(.gov_keys, .gov_fields), filters = filters
  )

  merged <- panel990::merge_tables(reads)

  # One data frame per year -> a single stacked data frame.
  dat <- do.call(
    function(...) dplyr::bind_rows(...),
    merged$years
  )
  if (is.null(dat) || !nrow(dat)) {
    stop("No filings were imported for years ",
         paste(years, collapse = ", "), ".", call. = FALSE)
  }

  # Full-990 filers only; 990EZ returns lack these Parts.
  if ("RETURN_TYPE" %in% names(dat)) {
    dat <- dat[dat$RETURN_TYPE != "990EZ", , drop = FALSE]
  }
  rownames(dat) <- NULL
  dat
}

#' Import 990 data and compute governance scores in one call
#'
#' Convenience wrapper that chains \code{\link{get_governance_data}},
#' \code{\link{get_features}}, and \code{\link{get_scores}}.
#'
#' @inheritParams get_governance_data
#' @param ... Additional arguments passed to \code{\link{get_scores}} (for
#'   example \code{missing} or \code{impute}).
#'
#' @return The scored data frame returned by \code{\link{get_scores}}.
#'
#' @seealso \code{\link{get_governance_data}}, \code{\link{get_features}},
#'   \code{\link{get_scores}}.
#'
#' @examples
#' \dontrun{
#' scores <- get_governance_scores(years = 2022)
#' }
#'
#' @export
get_governance_scores <- function(
    years,
    eins = NULL,
    source = NULL,
    cache = c("temporary", "retain"),
    path = "efdata",
    verbose = FALSE,
    ...
) {
  dat <- get_governance_data(
    years = years, eins = eins, source = source,
    cache = match.arg(cache), path = path, verbose = verbose
  )
  get_scores(get_features(dat), ...)
}
