# Build a minimal, valid raw-990 input row for get_features(), with every field
# set so the organization scores 1 on all 12 features and the accounting method
# is accrual. Callers override individual fields to test specific behavior.
make_raw <- function(n = 1) {
  data.frame(
    ORG_EIN                          = sprintf("%09d", seq_len(n)),
    # Part IV
    F9_04_AFS_IND_X                  = "true",
    F9_04_AFS_CONSOL_X               = "false",
    F9_04_BIZ_TRANSAC_DTK_X          = "false",
    F9_04_BIZ_TRANSAC_DTK_FAM_X      = "false",
    F9_04_BIZ_TRANSAC_DTK_ENTITY_X   = "false",
    F9_04_CONTR_NONCSH_MT_25K_X      = "false",
    F9_04_CONTR_ART_HIST_X           = "false",
    F9_04_LOAN_DTK_X                 = "false",
    # Part VI
    F9_06_GVRN_NUM_VOTING_MEMB       = "10",
    F9_06_GVRN_NUM_VOTING_MEMB_IND   = "8",
    F9_06_GVRN_DTK_FAMBIZ_RELATION_X = "false",
    F9_06_GVRN_DELEGATE_MGMT_DUTY_X  = "false",
    F9_06_GVRN_DOC_GVRN_BODY_X       = "true",
    F9_06_POLICY_FORM990_GVRN_BODY_X = "true",
    F9_06_POLICY_COI_X               = "true",
    F9_06_POLICY_COI_DISCLOSURE_X    = "true",
    F9_06_POLICY_COI_MONITOR_X       = "true",
    F9_06_POLICY_WHSTLBLWR_X         = "true",
    F9_06_POLICY_DOC_RETENTION_X     = "true",
    F9_06_POLICY_COMP_PROCESS_CEO_X  = "true",
    F9_06_DISCLOSURE_AVBL_OTH_X      = "",
    F9_06_DISCLOSURE_AVBL_OTH_WEB_X  = "",
    F9_06_DISCLOSURE_AVBL_REQUEST_X  = "",
    F9_06_DISCLOSURE_AVBL_OWN_WEB_X  = "X",
    F9_06_GVRN_DOC_COMMITTEE_X       = "true",
    F9_06_POLICY_COMP_PROCESS_OTH_X  = "true",
    F9_06_GVRN_ASSET_DIVERSION_X     = "false",
    # Part XII (accrual)
    F9_12_FINSTAT_METHOD_ACC_OTH     = "",
    F9_12_FINSTAT_METHOD_ACC_ACCRU_X = "X",
    F9_12_FINSTAT_METHOD_ACC_CASH_X  = "",
    F9_12_FINSTAT_METHOD_ACC_OTH_X   = "",
    F9_12_FINSTAT_COMPILE_X          = "false",
    F9_12_FINSTAT_AUDIT_X            = "true",
    F9_12_FINSTAT_AUDIT_COMMITTEE_X  = "true",
    # Schedule M
    SM_01_REVIEW_PROCESS_UNUSUAL_X   = "",
    stringsAsFactors = FALSE
  )
}

gi_cols <- c("GI_REVIEW_AUDIT", "GI_AUDIT", "GI_AUDIT_CMTE", "GI_ACCRUAL", "GI_INDEP_MAJOR",
             "GI_MINUTES_BOARD", "GI_MINUTES_CMTE", "GI_990_BOARD", "GI_COI",
             "GI_COI_DISCLOSE", "GI_COI_MONITOR", "GI_WHISTLE", "GI_RETENTION",
             "GI_COMP_CEO", "GI_COMP_OTH", "GI_990_WEB")

feature_cols <- c("P12_LINE_1", "P4_LINE_12", "P4_LINE_28", "P4_LINE_29_30",
                  "P6_LINE_1", "P6_LINE_11A", "P6_LINE_15A", "P6_LINE_18",
                  "P6_LINE_2", "P6_LINE_3", "P6_LINE_8A", "P6_LINE_12_13_14")

# A small deterministic slice of the shipped example data for scoring tests.
get_dat_example_sample <- function(n = 100) {
  utils::data("dat_example", package = "governance", envir = environment())
  set.seed(57)
  dat_example[sample(seq_len(nrow(dat_example)), n), ]
}
