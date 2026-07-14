#' Term-level partial R-squared and Cohen's f-squared
#'
#' `partial_r2()` calculates term-level effect sizes for a linear model. Each
#' row describes what happens when one model term is removed after accounting
#' for the other terms in the model.
#'
#' Partial R-squared asks how much additional residual variation is explained by
#' a term, given the other terms already in the model. Cohen's f-squared is a
#' related effect size that expresses that contribution relative to the residual
#' variation left in the full model.
#'
#' These are term-level quantities, not coefficient-level quantities. A
#' categorical predictor with more than two levels, such as `location`, gets one
#' row because it is one model term, even though it creates multiple coefficient
#' rows in [summary()].
#'
#' @param model An [stats::lm()] or `honest_lm` object.
#' @param details Logical. If `FALSE`, return only the term, degrees of freedom,
#'   partial R-squared, and f-squared. If `TRUE`, also return the partial F
#'   statistic, p-value, full-model residual sum of squares, reduced-model
#'   residual sum of squares, and their difference.
#'
#' @return A tibble with one row per model term and columns:
#' \describe{
#'   \item{term}{The model term being evaluated.}
#'   \item{df}{The degrees of freedom for the term. Multi-level categorical
#'   predictors usually have more than one degree of freedom.}
#'   \item{partial_r2}{The partial R-squared for the term. This is the
#'   proportion of the reduced model's residual sum of squares that is explained
#'   by adding the term back to the model. Partial R-squared values do not
#'   generally add up to the model R-squared.}
#'   \item{f2}{Cohen's f-squared for the term, calculated as
#'   `partial_r2 / (1 - partial_r2)`.}
#'   \item{statistic}{The partial F statistic, returned when `details = TRUE`.}
#'   \item{p_value}{The p-value for the partial F test, returned when
#'   `details = TRUE`.}
#'   \item{ss_full_error}{The residual sum of squares for the full model,
#'   returned when `details = TRUE`.}
#'   \item{ss_reduced_error}{The residual sum of squares for the model with the
#'   term removed, returned when `details = TRUE`.}
#'   \item{delta_ss}{The increase in residual sum of squares when the term is
#'   removed, returned when `details = TRUE`.}
#' }
#'
#' @details
#' For each term, `partial_r2()` compares the full model to a reduced model that
#' drops that term. It uses the same single-term deletion logic as
#' [stats::drop1()] with an F test.
#'
#' For a term with `df` degrees of freedom:
#'
#' `partial_r2 = delta_ss / ss_reduced_error`
#'
#' `f2 = delta_ss / ss_full_error`
#'
#' where `ss_full_error` is the residual sum of squares for the full model,
#' `ss_reduced_error` is the residual sum of squares after dropping the term,
#' and `delta_ss = ss_reduced_error - ss_full_error`.
#'
#' These effect sizes answer adjusted, model-dependent questions. If predictors
#' are correlated, a term's partial R-squared describes its contribution after
#' accounting for the other terms in that specific model. For models with
#' interactions, term-level interpretation can be more subtle because main
#' effects and interactions depend on each other.
#'
#' @export
#'
#' @examples
#' fit <- lm(mpg ~ wt + hp + factor(cyl), data = mtcars)
#' partial_r2(fit)
#'
#' partial_r2(fit, details = TRUE)
partial_r2 <- function(model, details = FALSE) {
  if (!inherits(model, "lm")) {
    stop("`model` must be an `lm` or `honest_lm` object.", call. = FALSE)
  }

  details <- isTRUE(details)
  term_labels <- attr(stats::terms(model), "term.labels")

  if (length(term_labels) == 0) {
    stop("`model` must contain at least one model term.", call. = FALSE)
  }

  lm_model <- model
  class(lm_model) <- setdiff(class(lm_model), "honest_lm")

  drop_table <- stats::drop1(lm_model, test = "F")
  drop_df <- as.data.frame(drop_table)
  drop_df$term <- row.names(drop_df)
  drop_df <- drop_df[drop_df$term != "<none>", , drop = FALSE]
  drop_df <- drop_df[!is.na(drop_df$Df) & drop_df$Df > 0, , drop = FALSE]

  ss_full_error <- stats::deviance(lm_model)
  ss_reduced_error <- drop_df$RSS
  delta_ss <- drop_df[["Sum of Sq"]]

  partial <- delta_ss / ss_reduced_error
  f2 <- delta_ss / ss_full_error

  out <- tibble::tibble(
    term = drop_df$term,
    df = drop_df$Df,
    partial_r2 = as.numeric(partial),
    f2 = as.numeric(f2)
  )

  if (details) {
    out$statistic <- as.numeric(drop_df[["F value"]])
    out$p_value <- as.numeric(drop_df[["Pr(>F)"]])
    out$ss_full_error <- rep(ss_full_error, nrow(out))
    out$ss_reduced_error <- as.numeric(ss_reduced_error)
    out$delta_ss <- as.numeric(delta_ss)
  }

  out
}
