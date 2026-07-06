# Analysis of variance for a guarded linear model

This method returns the same sequential ANOVA table as
[`stats::anova.lm()`](https://rdrr.io/r/stats/anova.lm.html), but warns
that these are Type I sums of squares and therefore depend on term
order.

## Usage

``` r
# S3 method for class 'honest_lm'
anova(object, ...)
```

## Arguments

- object:

  An `honest_lm` object.

- ...:

  Passed to [`stats::anova()`](https://rdrr.io/r/stats/anova.html).

## Value

An ANOVA table with an extra class for printing.
