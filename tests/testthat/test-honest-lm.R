test_that("honest_lm adds the honest_lm class", {
  fit <- honest_lm(mpg ~ wt + factor(cyl), data = mtcars)

  expect_s3_class(fit, "honest_lm")
  expect_s3_class(fit, "lm")
})

test_that("as_honest_lm retrofits an lm object", {
  fit <- lm(mpg ~ wt, data = mtcars)
  honest_fit <- as_honest_lm(fit)

  expect_s3_class(honest_fit, "honest_lm")
  expect_s3_class(honest_fit, "lm")
})
