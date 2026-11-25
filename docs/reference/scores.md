# Training Factor Scores

The factor scores from factor model
[`model6`](https://nonprofit-open-data-collective.github.io/governance/reference/model6.md)
of the
[`features2`](https://nonprofit-open-data-collective.github.io/governance/reference/features2.md)
training data. These are NOT the scores from `model6`, but are rather
the factor scores calculated using the `psych::facotor.scores` function
using polychoric correlations
[`rho2`](https://nonprofit-open-data-collective.github.io/governance/reference/rho2.md)
and `method == "Thurstone"`. See step 6 of
[`vignette("legacy-2018-model", package = "governance")`](https://nonprofit-open-data-collective.github.io/governance/articles/legacy-2018-model.md)
for detailed information on how this was generated.

## Usage

``` r
scores
```

## Format

An object of class `list` of length 5.
