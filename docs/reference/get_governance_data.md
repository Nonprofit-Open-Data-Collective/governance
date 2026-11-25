# Import raw 990 governance fields via the panel990 package

Builds the input to
[`get_features`](https://nonprofit-open-data-collective.github.io/governance/reference/get_features.md)
from the IRS efile archive using the
[panel990](https://github.com/Nonprofit-Open-Data-Collective/panel990)
package. It assembles a sample frame that restricts the data to **full
990 filers** (`RETURN_TYPE == "990"`; the governance index does not
apply to 990EZ returns, which omit these fields), then calls
[`panel990::panelize()`](https://nonprofit-open-data-collective.github.io/panel990/reference/panelize.html)
to download the required tables, keep the needed columns, and merge them
into one row per filing.

## Usage

``` r
get_governance_data(
  years,
  eins = NULL,
  source = NULL,
  cache = c("temporary", "retain"),
  path = "efdata",
  verbose = FALSE
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

## Value

A data.frame with one row per full-990 filing: `ORG_EIN`, the raw
governance fields, and identifier columns, ready for
[`get_features`](https://nonprofit-open-data-collective.github.io/governance/reference/get_features.md).

## Details

The governance and management fields come from four tables:

- `F9-P04-T00-REQUIRED-SCHEDULES`:

  Part IV – required-schedule triggers (audited financials,
  interested-person transactions, non-cash and art/historical
  contributions).

- `F9-P06-T00-GOVERNANCE`:

  Part VI – governing body composition and governance/management
  policies and disclosures.

- `F9-P12-T00-FINANCIAL-REPORTING`:

  Part XII – accounting method and audit oversight.

- `SM-P01-T00-NONCASH-CONTRIBUTIONS`:

  Schedule M – non-cash contribution review process.

The tables are imported raw and handed to
[`get_features`](https://nonprofit-open-data-collective.github.io/governance/reference/get_features.md),
which performs the governance-specific normalization.
[`panel990::panel_normalize()`](https://nonprofit-open-data-collective.github.io/panel990/reference/panel_normalize.html)
only rewrites blank *financial* fields and leaves these checkbox and
count fields untouched, so it is safe (but unnecessary) to apply
beforehand.

Install panel990 with
`remotes::install_github("Nonprofit-Open-Data-Collective/panel990")`.

## See also

[`get_features`](https://nonprofit-open-data-collective.github.io/governance/reference/get_features.md),
[`get_scores`](https://nonprofit-open-data-collective.github.io/governance/reference/get_scores.md),
[`get_governance_scores`](https://nonprofit-open-data-collective.github.io/governance/reference/get_governance_scores.md);
[`panel990::panelize()`](https://nonprofit-open-data-collective.github.io/panel990/reference/panelize.html)
and
[`panel990::create_sfw()`](https://nonprofit-open-data-collective.github.io/panel990/reference/create_sfw.html)
for the underlying sample-frame workflow.

## Examples

``` r
if (FALSE) { # \dontrun{
dat <- get_governance_data(years = 2022)
features <- get_features(dat)
scores <- get_scores(features)
} # }
```
