# Import 990 data and compute governance scores in one call

Convenience wrapper that chains
[`get_governance_data`](https://nonprofit-open-data-collective.github.io/governance/reference/get_governance_data.md),
[`get_features`](https://nonprofit-open-data-collective.github.io/governance/reference/get_features.md),
and
[`get_scores`](https://nonprofit-open-data-collective.github.io/governance/reference/get_scores.md).

## Usage

``` r
get_governance_scores(
  years,
  eins = NULL,
  source = NULL,
  cache = c("temporary", "retain"),
  path = "efdata",
  verbose = FALSE,
  ...
)
```

## Arguments

- years:

  Integer vector of tax years to import.

- eins:

  Optional character vector of formatted EINs (`EIN2`, e.g.
  `"EIN-43-2031361"`) to restrict the download to given organizations.

- source:

  A
  [`panel990::data_source()`](https://nonprofit-open-data-collective.github.io/panel990/reference/data_source.html)
  configuration. Defaults to the NCCS efile v2.1 archive. Point `root`
  at a local directory to read already-downloaded tables.

- cache:

  Passed to
  [`panel990::panelize()`](https://nonprofit-open-data-collective.github.io/panel990/reference/panelize.html):
  `"temporary"` (default) uses a session temp directory; `"retain"`
  keeps a durable cache in `path`.

- path:

  Cache directory used when `cache = "retain"`.

- verbose:

  Print panel990 progress messages.

- ...:

  Additional arguments passed to
  [`get_scores`](https://nonprofit-open-data-collective.github.io/governance/reference/get_scores.md)
  (for example `missing` or `impute`).

## Value

The scored data frame returned by
[`get_scores`](https://nonprofit-open-data-collective.github.io/governance/reference/get_scores.md).

## See also

[`get_governance_data`](https://nonprofit-open-data-collective.github.io/governance/reference/get_governance_data.md),
[`get_features`](https://nonprofit-open-data-collective.github.io/governance/reference/get_features.md),
[`get_scores`](https://nonprofit-open-data-collective.github.io/governance/reference/get_scores.md).

## Examples

``` r
if (FALSE) { # \dontrun{
scores <- get_governance_scores(years = 2022)
} # }
```
