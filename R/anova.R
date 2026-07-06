#' Analysis of variance for a guarded linear model
#'
#' This method returns the same sequential ANOVA table as [stats::anova.lm()],
#' but warns that these are Type I sums of squares and therefore depend on term
#' order.
#'
#' @param object An `honest_lm` object.
#' @param ... Passed to [stats::anova()].
#'
#' @return An ANOVA table with an extra class for printing.
#' @export
anova.honest_lm <- function(object, ...) {
  out <- NextMethod("anova")
  class(out) <- unique(c("anova_honest_lm", class(out)))
  out
}

#' @export
print.anova_honest_lm <- function(x, ...) {
  table <- x
  class(table) <- setdiff(class(table), "anova_honest_lm")
  print(table, ...)

  utils::flush.console()
  warning(
    "`anova()` for linear models reports sequential Type I sums of squares. ",
    "Those depend on the order of terms in the formula and are usually not ",
    "the test you want for models with multiple predictors. Use `car::Anova()` ",
    "for Type II or Type III sums of squares.",
    call. = FALSE
  )

  invisible(x)
}
