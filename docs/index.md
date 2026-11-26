# governance [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.10781067.svg)](https://doi.org/10.5281/zenodo.10781067)

R package for creating a nonprofit governance index score from IRS Form
990 efile data. It normalizes the governance and management fields of
the 990 into a binary feature matrix, then scores them with an item
response model fit to the full population of 501(c)(3) Form 990 filers
for tax year 2023, so scores from any year are on a common, benchmarked
scale.

**governance scores; it does not download data.** Retrieving and
assembling the 990 efile tables is handled by the companion
[panel990](https://github.com/Nonprofit-Open-Data-Collective/panel990)
package, which `governance` calls for you through
[`get_governance_data()`](https://nonprofit-open-data-collective.github.io/governance/reference/get_governance_data.md)
and
[`get_governance_scores()`](https://nonprofit-open-data-collective.github.io/governance/reference/get_governance_scores.md).

## Installation

``` r
devtools::install_github( 'nonprofit-open-data-collective/governance' )
```

## Usage

The workflow is two steps: normalize raw 990 fields into features with
[`get_features()`](https://nonprofit-open-data-collective.github.io/governance/reference/get_features.md),
then score them with
[`get_scores()`](https://nonprofit-open-data-collective.github.io/governance/reference/get_scores.md).

### Step 1: Get input data

The index uses Form 990 Parts IV, VI, and XII and Schedule M, and
applies to **full 990 filers only** (not 990EZ).
[`get_governance_data()`](https://nonprofit-open-data-collective.github.io/governance/reference/get_governance_data.md)
handles the retrieval, the full-990 filter, and the merge:

``` r
# remotes::install_github("Nonprofit-Open-Data-Collective/panel990")
dat <- get_governance_data(years = 2022)          # one row per filing, ready for get_features()
scores <- get_governance_scores(years = 2022)     # or the whole pipeline in one call
```

See the [Download Data
vignette](https://nonprofit-open-data-collective.github.io/governance/articles/download-data.html)
for the required tables, the field list, and the panel990 workflow.

The package also ships a ready-to-use example (a 5,000-organization
sample of raw 2022 fields) so you can try the workflow without
downloading anything:

``` r
data("dat_example", package = "governance")

set.seed(57)
dat_example <- dat_example[sample(seq_len(nrow(dat_example)), 200), ]
```

### Step 2: Build the feature matrix

``` r
features_example <- get_features(dat_example)
```

### Step 3: Calculate the scores

``` r
scores_example <- get_scores(features_example)
```

[`get_scores()`](https://nonprofit-open-data-collective.github.io/governance/reference/get_scores.md)
appends the governance index (`gov_score`) with its standard error,
scores from the bifactor measurement model, and `gov_count`, the number
of the 16 recommended practices reported. The index is on a scale with
mean 100 and standard deviation 15 among 2023 501(c)(3) full-990 filers:
115 is one standard deviation above the average 2023 filer, scores run
from about 67 (no practices) to about 128 (all 16), and adding a
practice never lowers a score. The original 2018 model is available with
`get_scores(features, model = "legacy-2018")`.

## Learn more

- [Governance Across the
  Sector](https://nonprofit-open-data-collective.github.io/governance/articles/overview.html):
  how practices and scores vary by size, subsector, state and year.
- [Governance
  Workflow](https://nonprofit-open-data-collective.github.io/governance/articles/governance-workflow.html):
  every column the package adds, and how to read it.
- [Making Governance
  Scores](https://nonprofit-open-data-collective.github.io/governance/articles/making-gov-scores.html):
  how the items were chosen and the model fit and validated.

## Citing the package

- Beck, O., & Lecy, J. (2024). Nonprofit governance Package for R.
  *Zenodo*. <https://doi.org/10.5281/zenodo.10781066>
