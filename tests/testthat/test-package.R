test_that("package attach message nudges toward honest_lm", {
  expect_message(
    .onAttach(NULL, "honestlm"),
    "use honest_lm\\(\\)",
    fixed = FALSE
  )
})
