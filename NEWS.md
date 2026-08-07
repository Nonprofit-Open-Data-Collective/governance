# governance 0.0.1.0000

* Fixed a Part XII normalization bug where the accounting-method "other" case was
  detected with `is.na()` on a free-text field that reads as `""` (not `NA`) from
  `data.table::fread`, causing every filer to be labeled "other" and
  `P12_LINE_1` to collapse to 0. Accrual is now detected correctly.
* `get_features()` normalization is now robust to how blank cells are encoded:
  `NA` and `""` yield identical features (blank yes/no responses score `0`).
* `get_features()` now normalizes the returned `ORG_EIN` to a 9-digit string
  (previously dead code) and accepts integer and `"EIN-.."` forms.
* Member counts are coerced to numeric, so character input from `fread` no longer
  errors on the independent-member ratio.
* Fixed a copy-paste bug in the missing-column checks so the error names the
  actual missing columns.
* `get_scores()` now stops with a clear message if a feature column is entirely
  `NA`, rather than returning invalid scores. `psych` moved to `Imports`.
* Rebuilt the bundled `dat_example` from the NCCS efile v2.1 archive (tax year
  2022, 5,000 organizations) so the example reflects current field formats.
* Added a `testthat` test suite covering normalization, scoring, and the fixes
  above.
* Refreshed the vignettes, README, and pkgdown reference index.

* Initial CRAN submission.
