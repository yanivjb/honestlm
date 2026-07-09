test_that("av_transform returns residualized columns whose slope matches lm coefficient", {
  av_data <- av_transform(
    mtcars,
    y = mpg,
    x = wt,
    adjust = c(hp, factor(cyl))
  )

  expect_true(all(c(".av_x", ".av_y") %in% names(av_data)))
  expect_equal(attr(av_data, "av_y"), "mpg")
  expect_equal(attr(av_data, "av_x"), "wt")
  expect_equal(attr(av_data, "av_adjust"), c("hp", "factor(cyl)"))

  full_fit <- stats::lm(mpg ~ wt + hp + factor(cyl), data = mtcars)
  av_fit <- stats::lm(.av_y ~ .av_x, data = av_data)

  expect_equal(
    unname(stats::coef(av_fit)[[".av_x"]]),
    unname(stats::coef(full_fit)[["wt"]]),
    tolerance = 1e-10
  )
})

test_that("av_transform supports character adjust vectors", {
  av_data <- av_transform(
    mtcars,
    y = "mpg",
    x = "wt",
    adjust = c("hp", "cyl")
  )

  expect_true(all(c(".av_x", ".av_y") %in% names(av_data)))
  expect_equal(attr(av_data, "av_adjust"), c("hp", "cyl"))
})

test_that("av_transform preserves rows with missing residualized values", {
  dat <- mtcars
  dat$hp[1] <- NA

  av_data <- av_transform(dat, y = mpg, x = wt, adjust = hp)

  expect_equal(nrow(av_data), nrow(dat))
  expect_true(is.na(av_data$.av_x[1]))
  expect_true(is.na(av_data$.av_y[1]))
  expect_false(anyNA(av_data$.av_x[-1]))
  expect_false(anyNA(av_data$.av_y[-1]))
})

test_that("av_transform requires a numeric focal x", {
  dat <- mtcars
  dat$cyl_group <- factor(dat$cyl)

  expect_error(
    av_transform(dat, y = mpg, x = cyl_group, adjust = hp),
    "`x` must be numeric"
  )
})
