# Fit a guarded linear model

`honest_lm()` fits a regular
[`stats::lm()`](https://rdrr.io/r/stats/lm.html) model and adds an
`honest_lm` class. Familiar methods such as
[`summary()`](https://rdrr.io/r/base/summary.html),
[`anova()`](https://rdrr.io/r/stats/anova.html), and broom methods can
then use more cautious defaults.

## Usage

``` r
honest_lm(formula, data, ..., p_values = c("hide", "warn", "show"))
```

## Arguments

- formula, data, ...:

  Passed to [`stats::lm()`](https://rdrr.io/r/stats/lm.html).

- p_values:

  How p-values should be handled by honest methods. The default `"hide"`
  suppresses p-value columns where possible. `"show"` includes them.
  `"warn"` includes them and may warn about contrast interpretation.

## Value

An object with class `c("honest_lm", "lm")`.

## Examples

``` r
fit <- honest_lm(mpg ~ wt + factor(cyl), data = mtcars)
summary(fit)
#> 
#> Call:
#> lm(formula = mpg ~ wt + factor(cyl), data = mtcars)
#> 
#> Residuals:
#>     Min      1Q  Median      3Q     Max 
#> -4.5890 -1.2357 -0.5159  1.3845  5.7915 
#> 
#> Coefficients:
#>              Estimate Std. Error t value
#> (Intercept)   33.9908     1.8878  18.006
#> wt            -3.2056     0.7539  -4.252
#> factor(cyl)6  -4.2556     1.3861  -3.070
#> factor(cyl)8  -6.0709     1.6523  -3.674
#> 
#> Categorical predictors:
#>   factor(cyl): 3 levels; reference level = 4
#> 
#> Notes:
#>   * Coefficient p-values are hidden by default. Use p_values = "warn" or "show" if you really want them.
#>   * For post-hoc comparisons among factor levels, consider estimated marginal means, e.g. emmeans::emmeans() and pairs(). See https://rvlenth.github.io/emmeans/.
#> 
#> Residual standard error: 2.557 on 28 degrees of freedom
#> Multiple R-squared:  0.8374, Adjusted R-squared:  0.82
#> F-statistic: 48.08 on 3 and 28 DF  (model-level p-value hidden)
#> Warning: `factor(cyl)` has 3 levels. The coefficient rows for `factor(cyl)` are comparisons to the reference level `4`, not tests of whether each category or the overall predictor matters.
```
