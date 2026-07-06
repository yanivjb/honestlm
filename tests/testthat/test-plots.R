test_that("geom_lm_smooth builds additive and interaction smooths", {
  plot_additive <- ggplot2::ggplot(
    mtcars,
    ggplot2::aes(wt, mpg, colour = factor(cyl))
  ) +
    geom_lm_smooth()

  plot_interaction <- ggplot2::ggplot(
    mtcars,
    ggplot2::aes(wt, mpg, colour = factor(cyl))
  ) +
    geom_lm_smooth(interaction = TRUE)

  expect_s3_class(ggplot2::ggplot_build(plot_additive), "ggplot_built")
  expect_s3_class(ggplot2::ggplot_build(plot_interaction), "ggplot_built")
})

test_that("stat_lm_means builds with two categorical predictors", {
  plot <- ggplot2::ggplot(
    mtcars,
    ggplot2::aes(factor(cyl), mpg, colour = factor(am))
  ) +
    stat_lm_means()

  built <- ggplot2::ggplot_build(plot)

  expect_s3_class(built, "ggplot_built")
  expect_true(all(c("y", "ymin", "ymax") %in% names(built$data[[1]])))
})

test_that("stat_lm_means tolerates one-level faceted panels", {
  testthat::skip_if_not_installed("palmerpenguins")

  plot <- ggplot2::ggplot(
    palmerpenguins::penguins,
    ggplot2::aes(island, bill_length_mm, colour = species)
  ) +
    stat_lm_means(colour = "black") +
    ggplot2::facet_wrap(~species)

  expect_s3_class(suppressWarnings(ggplot2::ggplot_build(plot)), "ggplot_built")
})
