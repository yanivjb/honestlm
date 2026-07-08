# Analysis of variance for a guarded linear model

For a single predictor, this method returns the usual ANOVA table from
[`stats::anova.lm()`](https://rdrr.io/r/stats/anova.lm.html). For models
with more than one predictor, it stops by default because that table
uses sequential Type I sums of squares, which depend on the order of
terms in the formula.

## Usage

``` r
# S3 method for class 'honest_lm'
anova(object, ..., beg = FALSE)
```

## Arguments

- object:

  An `honest_lm` object.

- ...:

  Passed to [`stats::anova()`](https://rdrr.io/r/stats/anova.html).

- beg:

  Logical. Set to `TRUE` to explicitly request sequential Type I sums of
  squares for a model with more than one predictor.

## Value

An ANOVA table with an extra class for printing.
