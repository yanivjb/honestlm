test_that("anova returns the usual table and warns about Type I sums of squares when printed", {
  fit <- honest_lm(mpg ~ wt + factor(cyl), data = mtcars)
  out <- anova(fit)

  expect_s3_class(out, "anova_honest_lm")
  expect_s3_class(out, "anova")
  expect_warning(print(out), "Type I sums of squares", fixed = TRUE)
})
