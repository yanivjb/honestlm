test_that("summary shows honest p-values by default", {
  fit <- honest_lm(mpg ~ wt + factor(cyl), data = mtcars)
  out <- summary(fit)

  expect_true("p.value" %in% names(out$coefficients))
  expect_true(is.na(out$coefficients$p.value[out$coefficients$term == "(Intercept)"]))
  expect_false(is.na(out$coefficients$p.value[out$coefficients$term == "wt"]))
  expect_true(all(is.na(out$coefficients$p.value[grepl("^factor\\(cyl\\)", out$coefficients$term)])))
})

test_that("summary honest default shows p-values for two-level factors", {
  data <- subset(mtcars, cyl %in% c(4, 6))
  data$cyl <- factor(data$cyl)
  fit <- honest_lm(mpg ~ cyl, data = data)
  out <- summary(fit)

  expect_true(is.na(out$coefficients$p.value[out$coefficients$term == "(Intercept)"]))
  expect_false(is.na(out$coefficients$p.value[out$coefficients$term == "cyl6"]))
})

test_that("summary can hide all coefficient p-values", {
  fit <- honest_lm(mpg ~ wt + factor(cyl), data = mtcars)
  out <- summary(fit, p_values = "hide")

  expect_false("p.value" %in% names(out$coefficients))
})

test_that("summary can show multi-level factor p-values with warnings", {
  fit <- honest_lm(mpg ~ wt + factor(cyl), data = mtcars)
  out <- summary(fit, p_values = "show")

  expect_true("p.value" %in% names(out$coefficients))
  expect_false(all(is.na(out$coefficients$p.value[grepl("^factor\\(cyl\\)", out$coefficients$term)])))
  expect_warning(
    invisible(utils::capture.output(print(out))),
    "factor\\(cyl\\).*3 levels",
    fixed = FALSE
  )
})

test_that("printing summary does not warn for honest default", {
  fit <- honest_lm(mpg ~ wt + factor(cyl), data = mtcars)

  expect_warning(
    invisible(utils::capture.output(print(summary(fit)))),
    NA
  )
})

test_that("summary can show intercept p-value when explicitly requested", {
  fit <- honest_lm(mpg ~ wt, data = mtcars)
  out <- summary(fit, intercept_p_value = TRUE)

  intercept_row <- out$coefficients$term == "(Intercept)"

  expect_false(is.na(out$coefficients$p.value[intercept_row]))
  expect_warning(
    invisible(utils::capture.output(print(out))),
    NA
  )
})
