# Add honest linear model behavior to an existing model

Add honest linear model behavior to an existing model

## Usage

``` r
as_honest_lm(model, p_values = NULL)
```

## Arguments

- model:

  An object inheriting from class `"lm"`.

- p_values:

  Optional p-value policy. See
  [`honest_lm()`](https://yanivjb.github.io/honestlm/reference/honest_lm.md).

## Value

An object with class `c("honest_lm", "lm")`.

## Examples

``` r
fit <- lm(mpg ~ wt + factor(cyl), data = mtcars)
summary(as_honest_lm(fit))
#> 
#> Call:
#> lm(formula = mpg ~ wt + factor(cyl), data = mtcars)
#> 
#> Residuals:
#>     Min      1Q  Median      3Q     Max 
#> -4.5890 -1.2357 -0.5159  1.3845  5.7915 
#> 
#> Coefficients:
#>              Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)   33.9908     1.8878  18.006       NA    
#> wt            -3.2056     0.7539  -4.252 0.000213 ***
#> factor(cyl)6  -4.2556     1.3861  -3.070       NA    
#> factor(cyl)8  -6.0709     1.6523  -3.674       NA    
#> ---
#> Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
#> 
#> Categorical predictors:
#>   factor(cyl): 3 levels; reference level = 4
#> 
#> Notes:
#>   * Intercept p-values are hidden because they usually test whether the expected response is zero at the reference condition. Use intercept_p_value = TRUE if you really want them.
#>   * When present, p-values are shown for continuous predictors and two-level categorical predictors.
#>   * P-values for multi-level categorical coefficient rows are hidden by default because those rows compare levels to a reference level, not whether the overall predictor matters.
#>   * For post-hoc comparisons among factor levels, consider estimated marginal means, e.g. emmeans::emmeans() and pairs(). See https://rvlenth.github.io/emmeans/.
#> 
#> Residual standard error: 2.557 on 28 degrees of freedom
#> Multiple R-squared:  0.8374, Adjusted R-squared:  0.82
#> F-statistic: 48.08 on 3 and 28 DF  (model-level p-value hidden)
```
