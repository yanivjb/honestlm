# honestlm

`honestlm` keeps familiar linear model workflows, but adds guardrails
around common interpretation traps.

Documentation site: <https://yanivjb.github.io/honestlm/>

The package is intentionally small. It starts from ordinary
[`lm()`](https://rdrr.io/r/stats/lm.html) models and keeps familiar
verbs like [`summary()`](https://rdrr.io/r/base/summary.html),
[`anova()`](https://rdrr.io/r/stats/anova.html),
[`broom::tidy()`](https://generics.r-lib.org/reference/tidy.html), and
ggplot2 layers, but changes the defaults where the usual output invites
overreading.

## Install

Install the development version from GitHub:

``` r

install.packages("remotes")
remotes::install_github("yanivjb/honestlm")
```

If you are working from a local checkout, load the package during
development with:

``` r

devtools::load_all()
```

Run the checks locally with:

``` r

devtools::test()
devtools::check(document = FALSE, manual = FALSE)
```

## Safer summaries

``` r

library(honestlm)
library(palmerpenguins)

fit <- honest_lm(
  bill_length_mm ~ bill_depth_mm + species,
  data = penguins
)

summary(fit)
```

By default, [`summary()`](https://rdrr.io/r/base/summary.html) uses
honest p-values: it shows p-values for continuous predictors and
two-level categorical predictors, but prints `NA` for intercept p-values
and multi-level categorical contrast rows. Notes under the coefficient
table explain what was hidden and point readers toward estimated
marginal means for post-hoc comparisons.

## Sequential sums of squares guardrail

``` r

anova(fit)
#> Error: `anova()` for a single linear model with more than one predictor reports sequential Type I sums of squares. ...

anova(fit, beg = TRUE)
```

For linear models with more than one predictor,
[`anova()`](https://rdrr.io/r/stats/anova.html) reports sequential Type
I sums of squares. These depend on the order of terms in the formula, so
`honestlm` stops by default. Use `car::Anova(model, type = 2)` for
term-level tests, or `anova(fit, beg = TRUE)` if you really want the
Type I table.

## Broom methods

``` r

library(broom)

tidy(fit)
glance(fit)
```

[`tidy()`](https://generics.r-lib.org/reference/tidy.html) removes
`p.value` by default and adds a `contrast_note` column for factor
contrasts.
[`glance()`](https://generics.r-lib.org/reference/glance.html) removes
the model-level `p.value` by default.

## Model-aware plots

``` r

library(ggplot2)

ggplot(penguins, aes(bill_depth_mm, bill_length_mm, colour = species)) +
  geom_point() +
  geom_lm_smooth(interaction = FALSE)
```

`geom_lm_smooth(interaction = FALSE)` draws additive/parallel linear
model smooths. Set `interaction = TRUE` to delegate to
`ggplot2::geom_smooth(method = "lm")` for separate slopes by group.

``` r

ggplot(penguins, aes(island, bill_length_mm, colour = species)) +
  geom_point() +
  stat_lm_means(interaction = FALSE) +
  facet_wrap(~species)
```

[`stat_lm_means()`](https://yanivjb.github.io/honestlm/reference/stat_lm_means.md)
draws model-predicted means rather than raw grouped means. This helps
plots follow the same additive or interaction structure as the linear
model.
