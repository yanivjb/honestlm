test_that("summary hides coefficient p-values by default", {
  fit <- honest_lm(mpg ~ wt + factor(cyl), data = mtcars)
  out <- summary(fit)

  expect_false("p.value" %in% names(out$coefficients))
})

test_that("summary can show coefficient p-values", {
  fit <- honest_lm(mpg ~ wt + factor(cyl), data = mtcars)
  out <- summary(fit, p_values = "show")

  expect_true("p.value" %in% names(out$coefficients))
})

test_that("printing summary warns for multi-level factors", {
  fit <- honest_lm(mpg ~ wt + factor(cyl), data = mtcars)

  expect_warning(
    print(summary(fit)),
    "factor\\(cyl\\).*3 levels",
    fixed = FALSE
  )
})

test_that("printing summary does not warn for two-level factors", {
  data <- subset(mtcars, cyl %in% c(4, 6))
  data$cyl <- factor(data$cyl)
  fit <- honest_lm(mpg ~ wt + cyl, data = data)

  expect_warning(print(summary(fit)), NA)
})
