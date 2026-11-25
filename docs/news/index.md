# Changelog

## governance 0.1.0

### Breaking changes

- [`get_scores()`](https://nonprofit-open-data-collective.github.io/governance/reference/get_scores.md)
  now applies the **2023 governance index model** by default. It is a
  bifactor item response model fit to all 501(c)(3) full Form 990 filers
  for tax year 2023, and returns:
  - `gov_score`, with its standard error `gov_score_se`;
  - four specific-factor scores (`gov_s_finance`, `gov_s_minutes`,
    `gov_s_policy`, `gov_s_comp`);
  - `gov_count` (number of the 16 practices reported) and `gov_n_items`.

  Item parameters are fixed at 2023 values (`gov_model_2023`), so scores
  from other years share the 2023 scale. The previous six-factor model
  and its `total.score` are still available with
  `get_scores(x, model = "legacy-2018")`.
- `mirt` is now a dependency.

### New features

- [`get_features()`](https://nonprofit-open-data-collective.github.io/governance/reference/get_features.md)
  also returns the 16 `GI_*` practice items used by the 2023 model. They
  add the audit committee (Part XII line 2c), compilation or review,
  committee minutes, and the pay process for other officers, and keep
  the conflict-of-interest disclosure and monitoring items separate.
- [`get_features()`](https://nonprofit-open-data-collective.github.io/governance/reference/get_features.md)
  also returns five `RISK_*` indicators: insider transactions, loans to
  insiders, family or business ties, management company, and asset
  diversion.
- Missing fields used only by the 2023 items produce a message, not an
  error.
- [`get_governance_data()`](https://nonprofit-open-data-collective.github.io/governance/reference/get_governance_data.md)
  retrieves the additional fields, and `dat_example` includes them.
- `data-raw/fit-model-2023.R` reproduces the shipped model from the
  efile archive.

### Documentation

- New article, “Governance Across the Sector”
  ([`vignette("overview")`](https://nonprofit-open-data-collective.github.io/governance/articles/overview.md)):
  practice prevalence and governance scores for every 501(c)(3) full-990
  filer, broken out by size, subsector, state and organization age, with
  risk disclosures and change from 2021 to 2024. Its summary tables are
  built by `data-raw/make-overview-data.R`.
- “Making Governance Scores” now documents the 2023 index: population
  and data preparation, item selection and coding, dimensionality, the
  model comparison, scoring and validation (invariance and predictive
  validity).
- The derivation of the 2018 model and its known issues moved to a new
  article, “The Legacy 2018 Model”, with its tables rebuilt and several
  descriptions corrected.
- “Getting Started” and “Governance Workflow” describe the 16 `GI_*`
  items, the `RISK_*` indicators and every column
  [`get_scores()`](https://nonprofit-open-data-collective.github.io/governance/reference/get_scores.md)
  adds. “Getting 990 Data” lists every field the 2023 items read.

### Fixes

- [`get_features()`](https://nonprofit-open-data-collective.github.io/governance/reference/get_features.md):
  audited financial statements (`P4_LINE_12`) now count consolidated
  audits (Part IV line 12b, `F9_04_AFS_CONSOL_X`) as well as separate
  audits (line 12a), matching how the factor model was trained.
  Previously organizations audited only on a consolidated basis
  scored 0. `F9_04_AFS_CONSOL_X` is optional: without it, a message is
  shown and line 12a alone is used.
  [`get_governance_data()`](https://nonprofit-open-data-collective.github.io/governance/reference/get_governance_data.md)
  now retrieves the field, and `dat_example` includes it.
- Documented four known issues with the shipped factor model in the
  “Making Governance Scores” vignette and in
  [`?get_scores`](https://nonprofit-open-data-collective.github.io/governance/reference/get_scores.md):
  - the training sample excluded fully independent boards;
  - a coding bug zeroed out the audit-committee item (Part XII line 2c);
  - `total.score` puts negative implied weights on several good-practice
    features;
  - six factors over-fit 12 binary items. These motivated the 2023
    refit.
- Retrieval tests now read the local fixture tables as CSV, since
  `panel990` defaults to parquet sources.

## governance 0.0.1.0000

- Added
  [`get_governance_data()`](https://nonprofit-open-data-collective.github.io/governance/reference/get_governance_data.md)
  and
  [`get_governance_scores()`](https://nonprofit-open-data-collective.github.io/governance/reference/get_governance_scores.md)
  to import IRS 990 efile tables through the companion
  [panel990](https://github.com/Nonprofit-Open-Data-Collective/panel990)
  package and assemble the input to
  [`get_features()`](https://nonprofit-open-data-collective.github.io/governance/reference/get_features.md)
  (Parts IV, VI, XII and Schedule M), merged to one row per filing.
  Retrieval uses
  [`panel990::panelize()`](https://nonprofit-open-data-collective.github.io/panel990/reference/panelize.html)
  with a sample frame that restricts the data to full 990 filers
  (`RETURN_TYPE == "990"`) via the SFW `form_type` filter.

- Fixed a Part XII normalization bug where the accounting-method “other”
  case was detected with [`is.na()`](https://rdrr.io/r/base/NA.html) on
  a free-text field that reads as `""` (not `NA`) from
  [`data.table::fread`](https://rdrr.io/pkg/data.table/man/fread.html),
  causing every filer to be labeled “other” and `P12_LINE_1` to collapse
  to 0. Accrual is now detected correctly.

- [`get_features()`](https://nonprofit-open-data-collective.github.io/governance/reference/get_features.md)
  normalization is now robust to how blank cells are encoded: `NA` and
  `""` yield identical features (blank yes/no responses score `0`).

- [`get_features()`](https://nonprofit-open-data-collective.github.io/governance/reference/get_features.md)
  now normalizes the returned `ORG_EIN` to a 9-digit string (previously
  dead code) and accepts integer and `"EIN-.."` forms.

- Member counts are coerced to numeric, so character input from `fread`
  no longer errors on the independent-member ratio.

- Fixed a copy-paste bug in the missing-column checks so the error names
  the actual missing columns.

- [`get_scores()`](https://nonprofit-open-data-collective.github.io/governance/reference/get_scores.md)
  now stops with a clear message if a feature column is entirely `NA`,
  rather than returning invalid scores. `psych` moved to `Imports`.

- Rebuilt the bundled `dat_example` from the NCCS efile v2.1 archive
  (tax year 2022, 5,000 organizations) so the example reflects current
  field formats.

- Added a `testthat` test suite covering normalization, scoring, and the
  fixes above.

- Refreshed the vignettes, README, and pkgdown reference index.

- Initial CRAN submission.
