# governance [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.10781067.svg)](https://doi.org/10.5281/zenodo.10781067)

R package for creating a nonprofit governance index score from IRS Form 990
efile data. It normalizes the governance and management fields of the 990 into a
binary feature matrix, then scores them against a factor model derived
empirically from the full filing population for benchmarking.

## Installation

```r
devtools::install_github( 'nonprofit-open-data-collective/governance' )
```

## Usage

The workflow is two steps: normalize raw 990 fields into features with
`get_features()`, then score them with `get_scores()`.

### Step 1: Get input data

`get_features()` expects raw 990 efile fields from Part IV, Part VI, Part XII,
and Schedule M. The companion
[panel990](https://github.com/Nonprofit-Open-Data-Collective/panel990) package
retrieves and assembles them for you:

```r
# remotes::install_github("Nonprofit-Open-Data-Collective/panel990")
dat <- get_governance_data(years = 2022)          # one row per filing, ready for get_features()
scores <- get_governance_scores(years = 2022)     # or the whole pipeline in one call
```

See the [Download Data vignette](https://nonprofit-open-data-collective.github.io/governance/articles/download-data.html)
for the field list and input contract.

The package also ships a ready-to-use example (a 5,000-organization sample of raw
2022 fields) so you can try the workflow without downloading anything:

```r
data("dat_example", package = "governance")

set.seed(57)
dat_example <- dat_example[sample(seq_len(nrow(dat_example)), 200), ]
```

### Step 2: Build the feature matrix

```r
features_example <- get_features(dat_example)
```

### Step 3: Calculate the scores

```r
scores_example <- get_scores(features_example)
```

`get_scores()` appends six factor scores and a `total.score`. See the
[Governance Workflow vignette](https://nonprofit-open-data-collective.github.io/governance/articles/governance-workflow.html)
for a fuller walk-through and the
[Making Governance Scores vignette](https://nonprofit-open-data-collective.github.io/governance/articles/making-gov-scores.html)
for the methodology.

## Citing the package

- Beck, O., & Lecy, J. (2024). Nonprofit governance Package for R. *Zenodo*. https://doi.org/10.5281/zenodo.10781066
