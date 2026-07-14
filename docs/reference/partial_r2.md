# Term-level partial R-squared and Cohen's f-squared

`partial_r2()` calculates term-level effect sizes for a linear model.
Each row describes what happens when one model term is removed after
accounting for the other terms in the model.

## Usage

``` r
partial_r2(model, details = FALSE)
```

## Arguments

- model:

  An [`stats::lm()`](https://rdrr.io/r/stats/lm.html) or `honest_lm`
  object.

- details:

  Logical. If `FALSE`, return only the term, degrees of freedom, partial
  R-squared, and f-squared. If `TRUE`, also return the partial F
  statistic, p-value, full-model residual sum of squares, reduced-model
  residual sum of squares, and their difference.

## Value

A tibble with one row per model term and columns:

- term:

  The model term being evaluated.

- df:

  The degrees of freedom for the term. Multi-level categorical
  predictors usually have more than one degree of freedom.

- partial_r2:

  The partial R-squared for the term. This is the proportion of the
  reduced model's residual sum of squares that is explained by adding
  the term back to the model. Partial R-squared values do not generally
  add up to the model R-squared.

- f2:

  Cohen's f-squared for the term, calculated as
  `partial_r2 / (1 - partial_r2)`.

- statistic:

  The partial F statistic, returned when `details = TRUE`.

- p_value:

  The p-value for the partial F test, returned when `details = TRUE`.

- ss_full_error:

  The residual sum of squares for the full model, returned when
  `details = TRUE`.

- ss_reduced_error:

  The residual sum of squares for the model with the term removed,
  returned when `details = TRUE`.

- delta_ss:

  The increase in residual sum of squares when the term is removed,
  returned when `details = TRUE`.

## Details

Partial R-squared asks how much additional residual variation is
explained by a term, given the other terms already in the model. Cohen's
f-squared is a related effect size that expresses that contribution
relative to the residual variation left in the full model.

These are term-level quantities, not coefficient-level quantities. A
categorical predictor with more than two levels, such as `location`,
gets one row because it is one model term, even though it creates
multiple coefficient rows in
[`summary()`](https://rdrr.io/r/base/summary.html).

For each term, `partial_r2()` compares the full model to a reduced model
that drops that term. It uses the same single-term deletion logic as
[`stats::drop1()`](https://rdrr.io/r/stats/add1.html) with an F test.

For a term with `df` degrees of freedom:

`partial_r2 = delta_ss / ss_reduced_error`

`f2 = delta_ss / ss_full_error`

where `ss_full_error` is the residual sum of squares for the full model,
`ss_reduced_error` is the residual sum of squares after dropping the
term, and `delta_ss = ss_reduced_error - ss_full_error`.

These effect sizes answer adjusted, model-dependent questions. If
predictors are correlated, a term's partial R-squared describes its
contribution after accounting for the other terms in that specific
model. For models with interactions, term-level interpretation can be
more subtle because main effects and interactions depend on each other.

## Examples

``` r
fit <- lm(mpg ~ wt + hp + factor(cyl), data = mtcars)
partial_r2(fit)
#> # A tibble: 3 × 4
#>   term           df partial_r2    f2
#>   <chr>       <dbl>      <dbl> <dbl>
#> 1 wt              1      0.420 0.724
#> 2 hp              1      0.122 0.139
#> 3 factor(cyl)     2      0.176 0.213

partial_r2(fit, details = TRUE)
#> # A tibble: 3 × 9
#>   term      df partial_r2    f2 statistic p_value ss_full_error ss_reduced_error
#>   <chr>  <dbl>      <dbl> <dbl>     <dbl>   <dbl>         <dbl>            <dbl>
#> 1 wt         1      0.420 0.724     19.5  1.44e-4          161.             277.
#> 2 hp         1      0.122 0.139      3.74 6.36e-2          161.             183.
#> 3 facto…     2      0.176 0.213      2.88 7.36e-2          161.             195.
#> # ℹ 1 more variable: delta_ss <dbl>
```
