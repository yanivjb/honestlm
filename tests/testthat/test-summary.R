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

test_that("summary hides intercept p-value even when coefficient p-values are shown", {
  fit <- honest_lm(mpg ~ wt, data = mtcars)
  out <- summary(fit, p_values = "show")

  intercept_row <- out$coefficients$term == "(Intercept)"
  slope_row <- out$coefficients$term == "wt"

  expect_true(is.na(out$coefficients$p.value[intercept_row]))
  expect_false(is.na(out$coefficients$p.value[slope_row]))
  expect_warning(
    invisible(utils::capture.output(print(out))),
    "intercept p-value is hidden",
    fixed = TRUE
  )
})

test_that("summary can show intercept p-value when explicitly requested", {
  fit <- honest_lm(mpg ~ wt, data = mtcars)
  out <- summary(fit, p_values = "show", intercept_p_value = TRUE)

  intercept_row <- out$coefficients$term == "(Intercept)"

  expect_false(is.na(out$coefficients$p.value[intercept_row]))
  expect_warning(
    invisible(utils::capture.output(print(out))),
    NA
  )
})
