#' Analysis of variance for a guarded linear model
#'
#' For a single predictor, this method returns the usual ANOVA table from
#' [stats::anova.lm()]. For models with more than one predictor, it stops by
#' default because that table uses sequential Type I sums of squares, which
#' depend on the order of terms in the formula.
#'
#' @param object An `honest_lm` object.
#' @param ... Passed to [stats::anova()].
#' @param beg Logical. Set to `TRUE` to explicitly request sequential Type I
#'   sums of squares for a model with more than one predictor.
#'
#' @return An ANOVA table with an extra class for printing.
#' @export
anova.honest_lm <- function(object, ..., beg = FALSE) {
  dots <- list(...)
  is_model_comparison <- any(vapply(
    dots,
    function(x) inherits(x, "lm"),
    logical(1)
  ))

  term_labels <- attr(stats::terms(object), "term.labels")
  has_multiple_terms <- length(term_labels) > 1

  if (has_multiple_terms && !is_model_comparison && !isTRUE(beg)) {
    stop(
      "`anova()` for a single linear model with more than one predictor reports ",
      "sequential Type I sums of squares. ",
      "honestlm stops here because changing the order of terms can change the table. ",
      "Use `car::Anova(model, type = 2)` for term-level tests, or type = 3 ",
      "with care. ",
      "If you really want Type I sums of squares, call `anova(model, beg = TRUE)`.",
      call. = FALSE
    )
  }

  lm_object <- object
  class(lm_object) <- setdiff(class(lm_object), "honest_lm")

  out <- stats::anova(lm_object, ...)
  class(out) <- unique(c("anova_honest_lm", class(out)))
  attr(out, "honestlm_type_i_warning") <- has_multiple_terms && !is_model_comparison
  out
}

#' @export
print.anova_honest_lm <- function(x, ...) {
  table <- x
  class(table) <- setdiff(class(table), "anova_honest_lm")
  print(table, ...)

  if (isTRUE(attr(x, "honestlm_type_i_warning"))) {
    utils::flush.console()
    warning(
      "`anova()` for linear models reports sequential Type I sums of squares. ",
      "Those depend on the order of terms in the formula and are usually not ",
      "the test you want for models with multiple predictors. Use `car::Anova()` ",
      "for Type II or Type III sums of squares.",
      call. = FALSE
    )
  }

  invisible(x)
}
