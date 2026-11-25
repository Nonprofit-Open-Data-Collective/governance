# Example Data

A 5,000-organization sample of raw 990 efile fields (tax year 2022),
used as a worked example for building features and running the factor
model. Contains the Part IV, VI, and XII and Schedule M fields that
[`get_features`](https://nonprofit-open-data-collective.github.io/governance/reference/get_features.md)
consumes, plus organization name / return type / tax year for
illustration. Values are unmodified from the source (e.g. yes/no fields
as `"true"`/`"false"`, flags as `"X"`, blanks as `""`).

Pulled directly from the NCCS 990 efile v2.1 archive; see
`data-raw/make-dat-example.R` for the exact provenance and the [efile
v2.1
catalog](https://nccs.urban.org/nccs/catalogs/catalog-efile-v2_1.html).

## Usage

``` r
dat_example
```

## Format

An object of class `data.frame` with 5000 rows and 40 columns.
