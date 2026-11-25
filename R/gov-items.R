# Items for the 2023 governance index ------------------------------------------
#
# Sixteen binary practice items (1 = the recommended practice is present) and
# five risk indicators (1 = the risk event or exposure is reported). Coding
# matches the item definitions used to fit the 2023 anchor model; see
# vignette("making-gov-scores") and data-raw/fit-model-2023.R.

# Raw efile fields used by the 2023 items.
.gi_fields <- c(
  # Part IV
  "F9_04_AFS_IND_X", "F9_04_AFS_CONSOL_X", "F9_04_BIZ_TRANSAC_DTK_X",
  "F9_04_BIZ_TRANSAC_DTK_FAM_X", "F9_04_BIZ_TRANSAC_DTK_ENTITY_X",
  "F9_04_LOAN_DTK_X",
  # Part VI
  "F9_06_GVRN_NUM_VOTING_MEMB", "F9_06_GVRN_NUM_VOTING_MEMB_IND",
  "F9_06_GVRN_DTK_FAMBIZ_RELATION_X", "F9_06_GVRN_DELEGATE_MGMT_DUTY_X",
  "F9_06_GVRN_ASSET_DIVERSION_X", "F9_06_GVRN_DOC_GVRN_BODY_X",
  "F9_06_GVRN_DOC_COMMITTEE_X", "F9_06_POLICY_FORM990_GVRN_BODY_X",
  "F9_06_POLICY_COI_X", "F9_06_POLICY_COI_DISCLOSURE_X",
  "F9_06_POLICY_COI_MONITOR_X", "F9_06_POLICY_WHSTLBLWR_X",
  "F9_06_POLICY_DOC_RETENTION_X", "F9_06_POLICY_COMP_PROCESS_CEO_X",
  "F9_06_POLICY_COMP_PROCESS_OTH_X", "F9_06_DISCLOSURE_AVBL_OWN_WEB_X",
  # Part XII
  "F9_12_FINSTAT_COMPILE_X", "F9_12_FINSTAT_AUDIT_X",
  "F9_12_FINSTAT_AUDIT_COMMITTEE_X", "F9_12_FINSTAT_METHOD_ACC_ACCRU_X",
  "F9_12_FINSTAT_METHOD_ACC_CASH_X", "F9_12_FINSTAT_METHOD_ACC_OTH_X",
  "F9_12_FINSTAT_METHOD_ACC_OTH"
)

# The 16 practice items, in model order.
.gi_items <- c(
  "GI_REVIEW_AUDIT", "GI_AUDIT", "GI_AUDIT_CMTE", "GI_ACCRUAL", "GI_INDEP_MAJOR",
  "GI_MINUTES_BOARD", "GI_MINUTES_CMTE", "GI_990_BOARD", "GI_COI",
  "GI_COI_DISCLOSE", "GI_COI_MONITOR", "GI_WHISTLE", "GI_RETENTION",
  "GI_COMP_CEO", "GI_COMP_OTH", "GI_990_WEB"
)

.gi_risks <- c("RISK_INSIDER_BIZ", "RISK_LOAN", "RISK_FAM_TIES", "RISK_MGMT_CO",
               "RISK_DIVERSION")

# yes/no fields: "true"/"1" -> 1, "false"/"0" -> 0, blank -> NA (not answered)
.yn <- function(x) {
  x <- tolower(trimws(as.character(x)))
  out <- rep(NA_real_, length(x))
  out[x %in% c("x", "1", "true", "yes")] <- 1
  out[x %in% c("0", "false", "no")] <- 0
  out
}

# checkbox fields ("X" or blank): blank means unchecked
.cb <- function(x) as.numeric(toupper(trimws(as.character(x))) %in% c("X", "1", "TRUE"))

.pmax_na <- function(...) {
  m <- cbind(...)
  out <- suppressWarnings(apply(m, 1, max, na.rm = TRUE))
  out[!is.finite(out)] <- NA_real_
  out
}

# Build the 2023 items from raw fields. Fields that are absent are treated as
# blank (NA); get_features() reports which ones were missing.
.gi_build <- function(dat) {
  n <- nrow(dat)
  g <- function(v) if (v %in% names(dat)) dat[[v]] else rep(NA_character_, n)

  compile   <- .yn(g("F9_12_FINSTAT_COMPILE_X"))
  audit_any <- .pmax_na(.yn(g("F9_12_FINSTAT_AUDIT_X")), .yn(g("F9_04_AFS_IND_X")),
                        .yn(g("F9_04_AFS_CONSOL_X")))
  rev_audit <- .pmax_na(compile, audit_any)
  cmte      <- .yn(g("F9_12_FINSTAT_AUDIT_COMMITTEE_X"))
  oth_txt   <- g("F9_12_FINSTAT_METHOD_ACC_OTH")
  oth_txt   <- !is.na(oth_txt) & nzchar(trimws(oth_txt))
  accrual   <- ifelse(.cb(g("F9_12_FINSTAT_METHOD_ACC_ACCRU_X")) == 1, 1,
               ifelse(.cb(g("F9_12_FINSTAT_METHOD_ACC_CASH_X")) == 1 |
                      .cb(g("F9_12_FINSTAT_METHOD_ACC_OTH_X")) == 1 | oth_txt, 0, NA))
  nvote <- suppressWarnings(as.numeric(g("F9_06_GVRN_NUM_VOTING_MEMB")))
  nind  <- suppressWarnings(as.numeric(g("F9_06_GVRN_NUM_VOTING_MEMB_IND")))
  share <- ifelse(!is.na(nvote) & nvote > 0 & !is.na(nind) & nind <= nvote, nind / nvote, NA)
  coi  <- .yn(g("F9_06_POLICY_COI_X"))
  sub_coi <- function(v) ifelse(coi %in% 0, 0, ifelse(coi %in% 1, .yn(g(v)), NA))

  data.frame(
    GI_REVIEW_AUDIT  = rev_audit,
    GI_AUDIT         = audit_any,
    GI_AUDIT_CMTE    = ifelse(is.na(rev_audit), NA, as.numeric(rev_audit %in% 1 & cmte %in% 1)),
    GI_ACCRUAL       = accrual,
    GI_INDEP_MAJOR   = ifelse(is.na(share), NA, as.numeric(share >= 0.5)),
    GI_MINUTES_BOARD = .yn(g("F9_06_GVRN_DOC_GVRN_BODY_X")),
    GI_MINUTES_CMTE  = .yn(g("F9_06_GVRN_DOC_COMMITTEE_X")),
    GI_990_BOARD     = .yn(g("F9_06_POLICY_FORM990_GVRN_BODY_X")),
    GI_COI           = coi,
    GI_COI_DISCLOSE  = sub_coi("F9_06_POLICY_COI_DISCLOSURE_X"),
    GI_COI_MONITOR   = sub_coi("F9_06_POLICY_COI_MONITOR_X"),
    GI_WHISTLE       = .yn(g("F9_06_POLICY_WHSTLBLWR_X")),
    GI_RETENTION     = .yn(g("F9_06_POLICY_DOC_RETENTION_X")),
    GI_COMP_CEO      = .yn(g("F9_06_POLICY_COMP_PROCESS_CEO_X")),
    GI_COMP_OTH      = .yn(g("F9_06_POLICY_COMP_PROCESS_OTH_X")),
    GI_990_WEB       = .cb(g("F9_06_DISCLOSURE_AVBL_OWN_WEB_X")),
    RISK_INSIDER_BIZ = .pmax_na(.yn(g("F9_04_BIZ_TRANSAC_DTK_X")), .yn(g("F9_04_BIZ_TRANSAC_DTK_FAM_X")),
                                .yn(g("F9_04_BIZ_TRANSAC_DTK_ENTITY_X"))),
    RISK_LOAN        = .yn(g("F9_04_LOAN_DTK_X")),
    RISK_FAM_TIES    = .yn(g("F9_06_GVRN_DTK_FAMBIZ_RELATION_X")),
    RISK_MGMT_CO     = .yn(g("F9_06_GVRN_DELEGATE_MGMT_DUTY_X")),
    RISK_DIVERSION   = .yn(g("F9_06_GVRN_ASSET_DIVERSION_X"))
  )
}
