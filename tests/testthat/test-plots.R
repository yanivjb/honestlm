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

test_that("geom_lm_smooth tolerates facets that split the grouping variable", {
  plot <- ggplot2::ggplot(
    mtcars,
    ggplot2::aes(wt, mpg, colour = factor(cyl))
  ) +
    ggplot2::geom_point() +
    geom_lm_smooth() +
    ggplot2::facet_wrap(~cyl)

  expect_warning(
    built <- ggplot2::ggplot_build(plot),
    NA
  )
  expect_s3_class(built, "ggplot_built")
  expect_true(nrow(built$data[[2]]) > 0)
})

test_that("geom_lm_smooth draws a single lm line without groups", {
  plot <- ggplot2::ggplot(
    mtcars,
    ggplot2::aes(wt, mpg)
  ) +
    ggplot2::geom_point() +
    geom_lm_smooth()

  expect_warning(
    built <- ggplot2::ggplot_build(plot),
    NA
  )
  expect_s3_class(built, "ggplot_built")
  expect_true(nrow(built$data[[2]]) > 0)
  expect_equal(length(unique(built$data[[2]]$group)), 1)
})


test_that("geom_lm_smooth accepts method lm as a quiet compatibility argument", {
  plot <- ggplot2::ggplot(
    mtcars,
    ggplot2::aes(wt, mpg)
  ) +
    geom_lm_smooth(method = "lm")

  expect_warning(
    built <- ggplot2::ggplot_build(plot),
    NA
  )
  expect_s3_class(built, "ggplot_built")
})

test_that("geom_lm_smooth warns for non-lm method requests", {
  expect_warning(
    geom_lm_smooth(method = "loess"),
    "always uses linear models"
  )
})


test_that("stat_lm_means uses one additive fit across facets", {
  df <- data.frame(
    x = rep(c("a", "b", "a", "b"), each = 2),
    facet = rep(c("p1", "p1", "p2", "p2"), each = 2),
    y = c(0, 0, 10, 10, 100, 100, 130, 130)
  )

  plot <- ggplot2::ggplot(df, ggplot2::aes(x, y, colour = x)) +
    stat_lm_means() +
    ggplot2::facet_wrap(~facet)

  built <- ggplot2::ggplot_build(plot)
  stat_data <- built$data[[1]]

  model_data <- data.frame(
    y = df$y,
    x_num = factor(as.numeric(factor(df$x))),
    panel = factor(as.numeric(factor(df$facet)))
  )
  fit <- stats::lm(y ~ x_num + panel, data = model_data)
  expected <- expand.grid(
    x_num = levels(model_data$x_num),
    panel = levels(model_data$panel)
  )
  expected$y <- as.numeric(stats::predict(fit, newdata = expected))

  stat_data <- stat_data[order(stat_data$PANEL, stat_data$x), ]
  expected <- expected[order(expected$panel, expected$x_num), ]

  expect_equal(stat_data$y, expected$y, tolerance = 1e-10)
  expect_false(all(stat_data$y %in% c(0, 10, 100, 130)))
})
