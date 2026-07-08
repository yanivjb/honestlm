test_that("multi-predictor anova requires begging", {
  fit <- honest_lm(mpg ~ wt + factor(cyl), data = mtcars)

  expect_error(
    anova(fit),
    "beg = TRUE",
    fixed = TRUE
  )
})

test_that("begged multi-predictor anova returns Type I table and warns when printed", {
  fit <- honest_lm(mpg ~ wt + factor(cyl), data = mtcars)
  out <- anova(fit, beg = TRUE)

  expect_s3_class(out, "anova_honest_lm")
  expect_s3_class(out, "anova")
  expect_warning(
    invisible(utils::capture.output(print(out))),
    "Type I sums of squares",
    fixed = TRUE
  )
})

test_that("single-predictor anova runs without Type I warning", {
  fit <- honest_lm(mpg ~ wt, data = mtcars)
  out <- anova(fit)

  expect_s3_class(out, "anova_honest_lm")
  expect_s3_class(out, "anova")
  expect_warning(
    invisible(utils::capture.output(print(out))),
    NA
  )
})

