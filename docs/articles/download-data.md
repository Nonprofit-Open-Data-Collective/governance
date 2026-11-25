# Getting 990 Data with panel990

## governance and panel990

The **governance** package *scores* nonprofit governance; it does not
retrieve data. Retrieving, normalizing, and assembling IRS 990 efile
tables is the job of the companion
[panel990](https://github.com/Nonprofit-Open-Data-Collective/panel990)
package.

| Package | Role |
|----|----|
| **panel990** | Download efile tables, filter to a sample frame, merge to one row per filing, build panels. |
| **governance** | Normalize the governance fields into a feature matrix ([`get_features()`](https://nonprofit-open-data-collective.github.io/governance/reference/get_features.md)) and compute the governance index ([`get_scores()`](https://nonprofit-open-data-collective.github.io/governance/reference/get_scores.md)). |

`governance` calls `panel990` for you through
[`get_governance_data()`](https://nonprofit-open-data-collective.github.io/governance/reference/get_governance_data.md)
and
[`get_governance_scores()`](https://nonprofit-open-data-collective.github.io/governance/reference/get_governance_scores.md),
so most users never touch `panel990` directly. This vignette shows both
the one-call path and the underlying `panel990` workflow for when you
want more control. Install `panel990` first:

``` r
remotes::install_github( "Nonprofit-Open-Data-Collective/panel990" )
```

## Required 990 tables

The governance index is built from four efile tables: Form 990 Parts IV,
VI and XII and Schedule M. Each is a `panel990` table name you pass to
[`panelize()`](https://nonprofit-open-data-collective.github.io/panel990/reference/panelize.html)
(Part XII also has the short alias `"P12"`).

| Part / Schedule | Governance information it contains | panel990 table name |
|----|----|----|
| Part IV | Audited financial statements; business transactions and loans with insiders; non-cash and art contributions | `F9-P04-T00-REQUIRED-SCHEDULES` |
| Part VI | Board size and independence; family ties, management companies, asset diversions; minutes; conflict-of-interest, whistleblower, retention and pay-setting policies; how the 990 is made public | `F9-P06-T00-GOVERNANCE` |
| Part XII | Accounting method; compilation, review and audit; audit committee | `F9-P12-T00-FINANCIAL-REPORTING` |
| Schedule M | Review process for unusual non-cash gifts (legacy model only) | `SM-P01-T00-NONCASH-CONTRIBUTIONS` |

> **Full 990 filers only.** The governance index does not apply to 990EZ
> returns, which omit these Parts. Restrict the data to
> `RETURN_TYPE == "990"` (shown below).
> [`get_governance_data()`](https://nonprofit-open-data-collective.github.io/governance/reference/get_governance_data.md)
> does this for you.

## Option 1: one call (recommended)

[`get_governance_data()`](https://nonprofit-open-data-collective.github.io/governance/reference/get_governance_data.md)
builds the full-990 sample frame, downloads the four tables, keeps the
needed columns, and merges them to one row per filing — ready for
[`get_features()`](https://nonprofit-open-data-collective.github.io/governance/reference/get_features.md).

``` r
library( governance )

# raw fields for one tax year, full 990 filers only
dat <- get_governance_data( years = 2023 )

features <- get_features( dat )
scores   <- get_scores( features )

# or the whole pipeline in one call
scores <- get_governance_scores( years = 2023 )
```

Restrict to specific organizations with `eins` (formatted `EIN2`
values), or read tables you have already downloaded by pointing the
source at a directory:

``` r
scores <- get_governance_scores( years = 2023, eins = "EIN-43-2031361" )

# tables already on disk
src <- panel990::data_source( root = "path/to/efile/csvs" )
dat <- get_governance_data( years = 2023, source = src )
```

## Option 2: the panel990 workflow

Under the hood,
[`get_governance_data()`](https://nonprofit-open-data-collective.github.io/governance/reference/get_governance_data.md)
assembles a **sample frame** and calls
[`panel990::panelize()`](https://nonprofit-open-data-collective.github.io/panel990/reference/panelize.html).
Doing it yourself gives full control — additional filters, multiple
years, BMF traits, DuckDB backends, and so on.

The `form_type` filter is how you keep only full 990 filers: it is a
built-in sample-frame alias mapping to the `RETURN_TYPE` column, so
`form_type = "990"` keeps only `RETURN_TYPE == "990"`.

``` r
library( panel990 )

gov_tables <- c( "F9-P04-T00-REQUIRED-SCHEDULES",
                 "F9-P06-T00-GOVERNANCE",
                 "F9-P12-T00-FINANCIAL-REPORTING",
                 "SM-P01-T00-NONCASH-CONTRIBUTIONS" )

# sample frame that keeps full 990 filers (RETURN_TYPE == "990")
sfw <- create_sfw( "governance panel", form_type = "990" )

# download, filter and merge the tables into one row per filing
panel <- panelize( sfw = sfw, tables = gov_tables, years = 2023 )

dat    <- as.data.frame( panel )
scores <- get_scores( get_features(dat) )
```

[`create_sfw()`](https://nonprofit-open-data-collective.github.io/panel990/reference/create_sfw.html)
accepts other convenience filters too — for example `state = "CA"` or
`years = 2018:2022` — which
[`panelize()`](https://nonprofit-open-data-collective.github.io/panel990/reference/panelize.html)
pushes down to the download step. See
[`?panel990::create_sfw`](https://nonprofit-open-data-collective.github.io/panel990/reference/create_sfw.html)
and
[`?panel990::panelize`](https://nonprofit-open-data-collective.github.io/panel990/reference/panelize.html).

### A note on normalization

[`get_features()`](https://nonprofit-open-data-collective.github.io/governance/reference/get_features.md)
performs the governance-specific normalization itself (blank checkboxes
and counts become `0` regardless of how the source encoded them), so the
tables are imported **raw**.

[`panel990::panel_normalize()`](https://nonprofit-open-data-collective.github.io/panel990/reference/panel_normalize.html)
only rewrites blank *financial* fields (revenue, expenses, balance
sheet) to zero; it leaves the governance checkbox and count fields
untouched. It is therefore safe to include in a shared pipeline but is
neither required nor sufficient for the governance features —
[`get_features()`](https://nonprofit-open-data-collective.github.io/governance/reference/get_features.md)
is what normalizes them. (Do **not** run the general
[`panel990::normalize()`](https://nonprofit-open-data-collective.github.io/panel990/reference/normalize.html)
on the governance checkboxes before
[`get_features()`](https://nonprofit-open-data-collective.github.io/governance/reference/get_features.md):
it converts them to logicals, which
[`get_features()`](https://nonprofit-open-data-collective.github.io/governance/reference/get_features.md)
does not expect.)

## The input contract

However you obtain the data,
[`get_features()`](https://nonprofit-open-data-collective.github.io/governance/reference/get_features.md)
expects a data frame with one row per filing containing `ORG_EIN` plus
the raw fields below. Values may be encoded as `"true"`/`"false"`,
`"1"`/`"0"`, `"X"` flags, or blanks (`NA` or `""`);
[`get_features()`](https://nonprofit-open-data-collective.github.io/governance/reference/get_features.md)
normalizes all of these.

The **2023** column marks the fields read by the 16 `GI_*` practice
items and the five `RISK_*` indicators. The **2018** column marks the
fields required by the legacy features. A missing legacy field stops
[`get_features()`](https://nonprofit-open-data-collective.github.io/governance/reference/get_features.md)
with an error, except `F9_04_AFS_CONSOL_X`, which falls back to line 12a
with a message. A missing 2023 field is treated as blank, with a
message, so the items that use it are `NA`.

| Part | Variable | Line | Question | 2023 | 2018 |
|----|----|----|----|:--:|:--:|
| IV | `F9_04_AFS_IND_X` | 12a | Separate independently audited financial statements? | x | x |
| IV | `F9_04_AFS_CONSOL_X` | 12b | Included in consolidated audited financial statements? | x | x |
| IV | `F9_04_LOAN_DTK_X` | 26 | Loan to or from a current or former officer, director, trustee or key employee (DTK)? | x |  |
| IV | `F9_04_BIZ_TRANSAC_DTK_X` | 28a | Business transaction with a DTK? | x | x |
| IV | `F9_04_BIZ_TRANSAC_DTK_FAM_X` | 28b | …with a family member of a DTK? | x | x |
| IV | `F9_04_BIZ_TRANSAC_DTK_ENTITY_X` | 28c | …with an entity a DTK controls? | x | x |
| IV | `F9_04_CONTR_NONCSH_MT_25K_X` | 29 | More than \$25,000 in non-cash contributions? |  | x |
| IV | `F9_04_CONTR_ART_HIST_X` | 30 | Contributions of art or historical treasures? |  | x |
| VI | `F9_06_GVRN_NUM_VOTING_MEMB` | 1a | Number of voting members of the governing body | x | x |
| VI | `F9_06_GVRN_NUM_VOTING_MEMB_IND` | 1b | Number of independent voting members | x | x |
| VI | `F9_06_GVRN_DTK_FAMBIZ_RELATION_X` | 2 | Family or business relationship among DTKs? | x | x |
| VI | `F9_06_GVRN_DELEGATE_MGMT_DUTY_X` | 3 | Management duties delegated to a management company? | x | x |
| VI | `F9_06_GVRN_ASSET_DIVERSION_X` | 5 | Significant diversion of assets? | x |  |
| VI | `F9_06_GVRN_DOC_GVRN_BODY_X` | 8a | Board meetings documented? | x | x |
| VI | `F9_06_GVRN_DOC_COMMITTEE_X` | 8b | Committee meetings documented? | x |  |
| VI | `F9_06_POLICY_FORM990_GVRN_BODY_X` | 11a | Form 990 provided to the board before filing? | x | x |
| VI | `F9_06_POLICY_COI_X` | 12a | Written conflict-of-interest policy? | x | x |
| VI | `F9_06_POLICY_COI_DISCLOSURE_X` | 12b | Annual disclosure of interests? | x | x |
| VI | `F9_06_POLICY_COI_MONITOR_X` | 12c | Policy regularly monitored and enforced? | x | x |
| VI | `F9_06_POLICY_WHSTLBLWR_X` | 13 | Written whistleblower policy? | x | x |
| VI | `F9_06_POLICY_DOC_RETENTION_X` | 14 | Written document retention and destruction policy? | x | x |
| VI | `F9_06_POLICY_COMP_PROCESS_CEO_X` | 15a | Independent pay-setting process for the top executive? | x | x |
| VI | `F9_06_POLICY_COMP_PROCESS_OTH_X` | 15b | …for other officers and key employees? | x |  |
| VI | `F9_06_DISCLOSURE_AVBL_OWN_WEB_X` | 18 | Form 990 available on own website | x | x |
| VI | `F9_06_DISCLOSURE_AVBL_OTH_WEB_X` | 18 | …on another organization’s website |  | x |
| VI | `F9_06_DISCLOSURE_AVBL_REQUEST_X` | 18 | …upon request |  | x |
| VI | `F9_06_DISCLOSURE_AVBL_OTH_X` | 18 | …other |  | x |
| XII | `F9_12_FINSTAT_METHOD_ACC_ACCRU_X` | 1 | Accounting method: accrual | x | x |
| XII | `F9_12_FINSTAT_METHOD_ACC_CASH_X` | 1 | Accounting method: cash | x | x |
| XII | `F9_12_FINSTAT_METHOD_ACC_OTH_X` | 1 | Accounting method: other (checkbox) | x |  |
| XII | `F9_12_FINSTAT_METHOD_ACC_OTH` | 1 | Accounting method: other (description) | x | x |
| XII | `F9_12_FINSTAT_COMPILE_X` | 2a | Financial statements compiled or reviewed by an independent accountant? | x |  |
| XII | `F9_12_FINSTAT_AUDIT_X` | 2b | Financial statements audited by an independent accountant? | x |  |
| XII | `F9_12_FINSTAT_AUDIT_COMMITTEE_X` | 2c | Committee oversees the audit, review or compilation? | x |  |
| Sched. M | `SM_01_REVIEW_PROCESS_UNUSUAL_X` | 31 | Review process for unusual non-cash gifts? |  | x |

[`get_governance_data()`](https://nonprofit-open-data-collective.github.io/governance/reference/get_governance_data.md)
retrieves every field in this table. For a full data dictionary see the
[irs990efile data
dictionary](https://nonprofit-open-data-collective.github.io/irs990efile/data-dictionary/data-dictionary.html)
and the [efile
catalog](https://nccs.urban.org/nccs/catalogs/catalog-efile-v2_1.html).

## Scoring 2023 filers like the anchor model

The 2023 model was fit to 501(c)(3) organizations only, with one filing
per organization
([`panel990::panel_deduplicate()`](https://nonprofit-open-data-collective.github.io/panel990/reference/panel_deduplicate.html)).
To reproduce that population, add the header and Part I tables and
filter on the 501(c)(3) checkbox:

``` r
tables <- c( "F9-P00-T00-HEADER", "F9-P01-T00-SUMMARY", gov_tables )

panel <-
  panelize(
    sfw    = create_sfw( "governance 2023", form_type = "990" ),
    tables = tables,
    years  = 2023
  )

dat <- as.data.frame( panel_deduplicate(panel) )
dat <- dat[ dat$F9_00_EXEMPT_STAT_501C3_X %in% "X", ]
```

Other 501(c) organizations can be scored on the same scale, but the
model was not fit to them.
