# Factor Model

Factor model object from
[`features2`](https://nonprofit-open-data-collective.github.io/governance/reference/features2.md)
data set using polychoric correlations from
[`rho2`](https://nonprofit-open-data-collective.github.io/governance/reference/rho2.md).
This is the output of the
[`psych::fa`](https://rdrr.io/pkg/psych/man/fa.html) function. This
model has 12 features and 6 factors. See
[`vignette("legacy-2018-model", package = "governance")`](https://nonprofit-open-data-collective.github.io/governance/articles/legacy-2018-model.md)
for a detailed description of how and why this model was chosen.

Most notable internal objects include

- loadings:

  Loadings from the factor analysis using polychoric correlations of
  `features2`.

- scores:

  Scores using the PEARSON correlations. Note, we do not use the scores
  generated from the
  [`psych::fa`](https://rdrr.io/pkg/psych/man/fa.html) function as they
  always use the Pearson correlation, even if the factor loadings were
  caclulated using the polychoric correlations.

## Usage

``` r
model6
```

## Format

An object of class `psych` (inherits from `fa`) of length 51.
