test_that("partial_r2 returns term-level effect sizes", {
  fit <- lm(mpg ~ wt + hp + factor(cyl), data = mtcars)
  out <- partial_r2(fit)

  expect_s3_class(out, "tbl_df")
  expect_named(out, c("term", "df", "partial_r2", "f2"))
  expect_equal(out$term, c("wt", "hp", "factor(cyl)"))
  expect_equal(out$df, c(1, 1, 2))
  expect_true(all(out$partial_r2 >= 0 & out$partial_r2 <= 1))
  expect_true(all(out$f2 >= 0))
})

test_that("partial_r2 matches drop1 single-term deletion quantities", {
  fit <- lm(mpg ~ wt + hp + factor(cyl), data = mtcars)
  out <- partial_r2(fit, details = TRUE)
  drops <- as.data.frame(stats::drop1(fit, test = "F"))
  drops$term <- row.names(drops)
  drops <- drops[drops$term != "<none>", , drop = FALSE]

  expected_partial <- drops[["Sum of Sq"]] / drops$RSS
  expected_f2 <- drops[["Sum of Sq"]] / stats::deviance(fit)

  expect_equal(out$partial_r2, as.numeric(expected_partial))
  expect_equal(out$f2, as.numeric(expected_f2))
  expect_equal(out$delta_ss, as.numeric(drops[["Sum of Sq"]]))
  expect_equal(out$ss_reduced_error, as.numeric(drops$RSS))
  expect_equal(out$ss_full_error, rep(stats::deviance(fit), nrow(out)))
})

test_that("partial_r2 accepts honest_lm objects", {
  fit <- honest_lm(mpg ~ wt + factor(cyl), data = mtcars)
  out <- partial_r2(fit)

  expect_equal(out$term, c("wt", "factor(cyl)"))
  expect_equal(out$df, c(1, 2))
})

test_that("partial_r2 validates input", {
  expect_error(partial_r2(mtcars), "must be an `lm`")
  expect_error(partial_r2(lm(mpg ~ 1, data = mtcars)), "at least one model term")
})
