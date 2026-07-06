test_that("tidy hides p-values and adds contrast notes", {
  testthat::skip_if_not_installed("broom")

  fit <- honest_lm(mpg ~ wt + factor(cyl), data = mtcars)
  out <- broom::tidy(fit)

  expect_false("p.value" %in% names(out))
  expect_true("contrast_note" %in% names(out))
  expect_true(any(!is.na(out$contrast_note)))
})

test_that("tidy can show p-values", {
  testthat::skip_if_not_installed("broom")

  fit <- honest_lm(mpg ~ wt + factor(cyl), data = mtcars)
  out <- broom::tidy(fit, p_values = "show")

  expect_true("p.value" %in% names(out))
})

test_that("glance hides model-level p-value by default", {
  testthat::skip_if_not_installed("broom")

  fit <- honest_lm(mpg ~ wt + factor(cyl), data = mtcars)
  out <- broom::glance(fit)

  expect_false("p.value" %in% names(out))
})
