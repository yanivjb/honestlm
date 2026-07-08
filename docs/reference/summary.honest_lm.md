# Summarize a guarded linear model

This method keeps the familiar shape of
[`summary.lm()`](https://rdrr.io/r/stats/summary.lm.html) but treats
coefficient p-values cautiously. The default `p_values = "honest"` shows
p-values for continuous predictors and two-level categorical predictors,
but hides intercept p-values and multi-level categorical contrast
p-values with `NA`. Notes explain what was hidden.

## Usage

``` r
# S3 method for class 'honest_lm'
summary(
  object,
  ...,
  conf.level = 0.95,
  p_values = NULL,
  intercept_p_value = FALSE
)
```

## Arguments

- object:

  An `honest_lm` object.

- ...:

  Unused.

- conf.level:

  Confidence level used for stored confidence intervals.

- p_values:

  Optional p-value policy. See
  [`honest_lm()`](https://yanivjb.github.io/honestlm/reference/honest_lm.md).

- intercept_p_value:

  Logical. Set to `TRUE` to show the intercept p-value when coefficient
  p-values are shown.

## Value

A `summary_honest_lm` object.
