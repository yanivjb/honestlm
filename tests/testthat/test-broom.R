test_that("tidy uses honest p-values by default and adds contrast notes", {
  testthat::skip_if_not_installed("broom")

  fit <- honest_lm(mpg ~ wt + factor(cyl), data = mtcars)
  out <- broom::tidy(fit)

  expect_true("p.value" %in% names(out))
  expect_true(is.na(out$p.value[out$term == "(Intercept)"]))
  expect_false(is.na(out$p.value[out$term == "wt"]))
  expect_true(all(is.na(out$p.value[grepl("^factor\\(cyl\\)", out$term)])))
  expect_true("contrast_note" %in% names(out))
  expect_true(any(!is.na(out$contrast_note)))
})

test_that("tidy can hide p-values", {
  testthat::skip_if_not_installed("broom")

  fit <- honest_lm(mpg ~ wt + factor(cyl), data = mtcars)
  out <- broom::tidy(fit, p_values = "hide")

  expect_false("p.value" %in% names(out))
})

test_that("tidy can show p-values", {
  testthat::skip_if_not_installed("broom")

  fit <- honest_lm(mpg ~ wt + factor(cyl), data = mtcars)
  out <- broom::tidy(fit, p_values = "show")

  expect_true("p.value" %in% names(out))
  expect_false(all(is.na(out$p.value[grepl("^factor\\(cyl\\)", out$term)])))
})

test_that("glance hides model-level p-value by default", {
  testthat::skip_if_not_installed("broom")

  fit <- honest_lm(mpg ~ wt + factor(cyl), data = mtcars)
  out <- broom::glance(fit)

  expect_false("p.value" %in% names(out))
})
