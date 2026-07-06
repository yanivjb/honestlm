# Tidy a guarded linear model

This method calls broom's ordinary `lm` tidier, removes `p.value` by
default, and adds a `contrast_note` column for factor contrast rows.

## Usage

``` r
# S3 method for class 'honest_lm'
tidy(x, ..., p_values = NULL)
```

## Arguments

- x:

  An `honest_lm` object.

- ...:

  Passed to
  [`broom::tidy()`](https://generics.r-lib.org/reference/tidy.html).

- p_values:

  Optional p-value policy. See
  [`honest_lm()`](https://yanivjb.github.io/honestlm/reference/honest_lm.md).

## Value

A tibble when broom is installed.
