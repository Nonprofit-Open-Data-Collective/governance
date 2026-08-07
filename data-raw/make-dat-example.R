# ------------------------------------------------------------------
# Build the demo `dat_example` data set shipped with the package.
#
# One-off pull of NCCS 990 efile v2.1 tables directly from S3, for
# demonstration in the vignettes/README. When the `panel990` retrieval
# package is ready, regenerate `dat_example` from it instead.
#
# Source catalog: https://nccs.urban.org/nccs/catalogs/catalog-efile-v2_1.html
# URL pattern:    {root}/{TABLE}-{YEAR}.CSV
# ------------------------------------------------------------------

library( data.table )
library( dplyr )

ROOT <- "https://nccs-efile.s3.us-east-1.amazonaws.com/public/efile_v2_1/"
YEAR <- 2022                 # a recent, well-populated filing year
N_SAMPLE <- 5000             # orgs kept in the shipped example
set.seed( 57 )

get_table <- function( table.name, year, select = NULL ){
  options( timeout = max(600, getOption("timeout")) )
  url <- paste0( ROOT, table.name, "-", year, ".CSV" )
  data.table::fread( url, colClasses = "character", select = select,
                     showProgress = FALSE )
}

# Columns get_features() needs from each part (plus identifiers). ------------

id_cols <- c( "OBJECTID", "ORG_EIN" )

p04_vars <- c( "F9_04_AFS_IND_X", "F9_04_BIZ_TRANSAC_DTK_X",
               "F9_04_BIZ_TRANSAC_DTK_FAM_X", "F9_04_BIZ_TRANSAC_DTK_ENTITY_X",
               "F9_04_CONTR_NONCSH_MT_25K_X", "F9_04_CONTR_ART_HIST_X" )

p06_vars <- c( "F9_06_GVRN_NUM_VOTING_MEMB", "F9_06_GVRN_NUM_VOTING_MEMB_IND",
               "F9_06_GVRN_DTK_FAMBIZ_RELATION_X", "F9_06_GVRN_DELEGATE_MGMT_DUTY_X",
               "F9_06_GVRN_DOC_GVRN_BODY_X", "F9_06_POLICY_FORM990_GVRN_BODY_X",
               "F9_06_POLICY_COI_X", "F9_06_POLICY_COI_DISCLOSURE_X",
               "F9_06_POLICY_COI_MONITOR_X", "F9_06_POLICY_WHSTLBLWR_X",
               "F9_06_POLICY_DOC_RETENTION_X", "F9_06_POLICY_COMP_PROCESS_CEO_X",
               "F9_06_DISCLOSURE_AVBL_OTH_X", "F9_06_DISCLOSURE_AVBL_OTH_WEB_X",
               "F9_06_DISCLOSURE_AVBL_REQUEST_X", "F9_06_DISCLOSURE_AVBL_OWN_WEB_X" )

p12_vars <- c( "F9_12_FINSTAT_METHOD_ACC_OTH", "F9_12_FINSTAT_METHOD_ACC_ACCRU_X",
               "F9_12_FINSTAT_METHOD_ACC_CASH_X" )

sm_vars  <- c( "SM_01_REVIEW_PROCESS_UNUSUAL_X" )

# Metadata kept for the vignettes (org name / type / year).
meta_cols <- c( "ORG_NAME_L1", "RETURN_TYPE", "TAX_YEAR" )

# Pull each table (only the columns we need). -------------------------------

p06 <- get_table( "F9-P06-T00-GOVERNANCE",          YEAR, select = c(id_cols, meta_cols, p06_vars) )
p04 <- get_table( "F9-P04-T00-REQUIRED-SCHEDULES",  YEAR, select = c("OBJECTID", p04_vars) )
p12 <- get_table( "F9-P12-T00-FINANCIAL-REPORTING", YEAR, select = c("OBJECTID", p12_vars) )
m01 <- get_table( "SM-P01-T00-NONCASH-CONTRIBUTIONS", YEAR, select = c("OBJECTID", sm_vars) )

# Merge on OBJECTID (unique per filing). Parts IV/VI/XII are core 990 parts
# (inner join); Schedule M is filed only by some orgs (left join -> NA when
# absent, which get_features() handles).
dat <- p06 |>
  merge( p04, by = "OBJECTID" ) |>
  merge( p12, by = "OBJECTID" ) |>
  merge( m01, by = "OBJECTID", all.x = TRUE )

# Full-990 filers only, one row per org, then sample for a compact example.
dat_example <- dat |>
  filter( RETURN_TYPE != "990EZ" ) |>
  distinct( ORG_EIN, .keep_all = TRUE )

keep <- sample( seq_len(nrow(dat_example)), min(N_SAMPLE, nrow(dat_example)) )
dat_example <- as.data.frame( dat_example[ keep, ] )

# ------------------------------------------------------------------
usethis::use_data( dat_example, overwrite = TRUE )
