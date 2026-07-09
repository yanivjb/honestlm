# Labels for an added-variable plot

`av_labs()` returns ggplot2 axis labels that describe the residual
models used by
[`av_transform()`](https://yanivjb.github.io/honestlm/reference/av_transform.md).

## Usage

``` r
av_labs(data)
```

## Arguments

- data:

  A data frame returned by
  [`av_transform()`](https://yanivjb.github.io/honestlm/reference/av_transform.md).

## Value

A ggplot2 labels object.

## Examples

``` r
av_data <- av_transform(mtcars, y = mpg, x = wt, adjust = c(hp, factor(cyl)))

ggplot2::ggplot(av_data, ggplot2::aes(.adjusted_wt, .adjusted_mpg)) +
  ggplot2::geom_point() +
  av_labs(av_data)
```
