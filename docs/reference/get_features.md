# Function to calculate features matrix

This function takes input from raw 990 Part IV, VI, and XII, then output
a original data frame appended with columns as features needed to
calculate governance score.

## Usage

``` r
get_features(dat)
```

## Arguments

- dat:

  A data.frame containing columns ORG_EIN and correct inputs from 990
  Part IV, VI, and XII. See details below. ORG_EIN must be a character
  string of 9 digits. (This data.frame can contain other columns). See
  details below for which variable from the 990 efile data must be
  included to run this function.

## Value

A data.frame appended with features needed to run the
[`get_scores`](https://nonprofit-open-data-collective.github.io/governance/reference/get_scores.md)
function.

## Details

990 Efiler data can be downloaded from the NCCS website
[here](https://nccs.urban.org/nccs/catalogs/catalog-efile.html).
Documentation for the 990 Efiler data can be found
[here](https://nccs.urban.org/nccs/datasets/efile/) with the data
dictionary found
[here](https://nonprofit-open-data-collective.github.io/irs990efile/data-dictionary/data-dictionary.html).

These are the variables from each Part/Schedule that are needed as
inputs to run this function:

Variables from Part IV:

- F9_04_AFS_IND_X

- F9_04_AFS_CONSOL_X (recommended; see below)

- F9_04_BIZ_TRANSAC_DTK_X

- F9_04_BIZ_TRANSAC_DTK_FAM_X

- F9_04_BIZ_TRANSAC_DTK_ENTITY_X

- F9_04_CONTR_NONCSH_MT_25K_X

- F9_04_CONTR_ART_HIST_X

Variables from Part VI:

- F9_06_GVRN_NUM_VOTING_MEMB

- F9_06_GVRN_NUM_VOTING_MEMB_IND

- F9_06_GVRN_DTK_FAMBIZ_RELATION_X

- F9_06_GVRN_DELEGATE_MGMT_DUTY_X

- F9_06_GVRN_DOC_GVRN_BODY_X

- F9_06_POLICY_FORM990_GVRN_BODY_X

- F9_06_POLICY_COI_X

- F9_06_POLICY_COI_DISCLOSURE_X

- F9_06_POLICY_COI_MONITOR_X

- F9_06_POLICY_WHSTLBLWR_X

- F9_06_POLICY_DOC_RETENTION_X

- F9_06_POLICY_COMP_PROCESS_CEO_X

- F9_06_DISCLOSURE_AVBL_OTH_X

- F9_06_DISCLOSURE_AVBL_OTH_WEB_X

- F9_06_DISCLOSURE_AVBL_REQUEST_X

- F9_06_DISCLOSURE_AVBL_OWN_WEB_X

Variables from Part XII:

- F9_12_FINSTAT_METHOD_ACC_OTH

- F9_12_FINSTAT_METHOD_ACC_ACCRU_X

- F9_12_FINSTAT_METHOD_ACC_CASH_X

Variables from Schedule M:

- SM_01_REVIEW_PROCESS_UNUSUAL_X

Input values may be encoded as `"true"`/`"false"`, `"1"`/`"0"`, `"X"`
flags, or blanks; blanks may arrive as `NA` or `""` depending on how the
tables were read. Blank or missing yes/no responses are treated as `0`
(the governance property is absent), and the result does not depend on
the blank encoding. Two derived features can still be `NA` when their
inputs are genuinely unavailable: `P6_LINE_1` (share of independent
voting members, undefined when the voting-member count is 0 or missing)
and `P12_LINE_1` (accounting method, when none is reported);
[`get_scores`](https://nonprofit-open-data-collective.github.io/governance/reference/get_scores.md)
imputes these.

`P4_LINE_12` (audited financial statements) is 1 when the organization
obtained separate (Part IV line 12a, `F9_04_AFS_IND_X`) *or*
consolidated (line 12b, `F9_04_AFS_CONSOL_X`) independently audited
financial statements. This matches how the feature was coded when the
factor model was trained. Earlier versions used line 12a only, which
scored organizations audited on a consolidated basis as unaudited. If
`F9_04_AFS_CONSOL_X` is not supplied, a message is shown and line 12a
alone is used.

## 2023 index items

`get_features()` also appends the 16 practice items used by the 2023
governance index (`model = "2023"` in
[`get_scores`](https://nonprofit-open-data-collective.github.io/governance/reference/get_scores.md)),
coded 1 when the practice is present, 0 when absent, and `NA` when the
question was left blank:

- GI_REVIEW_AUDIT:

  financial statements compiled, reviewed, or audited (XII-2a/2b,
  IV-12a/b)

- GI_AUDIT:

  financial statements audited (XII-2b, IV-12a/b)

- GI_AUDIT_CMTE:

  audit committee oversees the audit or review (XII-2c; 0 if no review
  or audit)

- GI_ACCRUAL:

  accrual accounting (XII-1)

- GI_INDEP_MAJOR:

  at least half of voting members are independent (VI-1a/1b)

- GI_MINUTES_BOARD, GI_MINUTES_CMTE:

  meetings of the board and of committees documented (VI-8a/8b)

- GI_990_BOARD:

  Form 990 provided to the board before filing (VI-11a)

- GI_COI, GI_COI_DISCLOSE, GI_COI_MONITOR:

  written conflict-of-interest policy; annual disclosure; monitoring
  (VI-12a/b/c; b and c are 0 without a policy)

- GI_WHISTLE, GI_RETENTION:

  whistleblower and document retention policies (VI-13, VI-14)

- GI_COMP_CEO, GI_COMP_OTH:

  independent pay-setting process for the CEO and for other officers
  (VI-15a/15b)

- GI_990_WEB:

  Form 990 posted on the organization's own website (VI-18)

It also appends five risk indicators, coded 1 when the event is
reported: `RISK_INSIDER_BIZ` (IV-28a/b/c), `RISK_LOAN` (IV-26),
`RISK_FAM_TIES` (VI-2), `RISK_MGMT_CO` (VI-3) and `RISK_DIVERSION`
(VI-5). They are not part of the index, because they record disclosures
and exposures rather than practices, but are useful alongside it. The
extra raw fields these items need are retrieved by
[`get_governance_data`](https://nonprofit-open-data-collective.github.io/governance/reference/get_governance_data.md);
any that are absent are treated as blank, with a message.

## Examples

``` r
# get data
data("dat_example", package = "governance")
set.seed(57)
keep_rows <- sample(1:nrow(dat_example), 200)
dat_example <- dat_example[keep_rows, ]

# get features
features_example <- get_features(dat_example)
```
