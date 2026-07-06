# Glance at a guarded linear model

This method calls broom's ordinary `lm` glance method and removes the
model-level `p.value` by default.

## Usage

``` r
# S3 method for class 'honest_lm'
glance(x, ..., p_values = NULL)
```

## Arguments

- x:

  An `honest_lm` object.

- ...:

  Passed to
  [`broom::glance()`](https://generics.r-lib.org/reference/glance.html).

- p_values:

  Optional p-value policy. See
  [`honest_lm()`](https://yanivjb.github.io/honestlm/reference/honest_lm.md).

## Value

A tibble when broom is installed.
