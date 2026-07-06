#' Fit a guarded linear model
#'
#' `honest_lm()` fits a regular [stats::lm()] model and adds an `honest_lm`
#' class. Familiar methods such as [summary()], [anova()], and broom methods can
#' then use more cautious defaults.
#'
#' @param formula,data,... Passed to [stats::lm()].
#' @param p_values How p-values should be handled by honest methods. The default
#'   `"hide"` suppresses p-value columns where possible. `"show"` includes them.
#'   `"warn"` includes them and may warn about contrast interpretation.
#'
#' @return An object with class `c("honest_lm", "lm")`.
#' @export
#'
#' @examples
#' fit <- honest_lm(mpg ~ wt + factor(cyl), data = mtcars)
#' summary(fit)
honest_lm <- function(formula, data, ..., p_values = c("hide", "warn", "show")) {
  p_values <- match.arg(p_values)
  lm_call <- match.call(expand.dots = TRUE)
  lm_call$p_values <- NULL

  eval_call <- lm_call
  eval_call[[1]] <- quote(stats::lm)

  fit <- eval(eval_call, parent.frame())
  lm_call[[1]] <- quote(lm)
  fit$call <- lm_call
  fit$honest_lm_p_values <- p_values
  as_honest_lm(fit)
}

#' Add honest linear model behavior to an existing model
#'
#' @param model An object inheriting from class `"lm"`.
#' @param p_values Optional p-value policy. See `honest_lm()`.
#'
#' @return An object with class `c("honest_lm", "lm")`.
#' @export
#'
#' @examples
#' fit <- lm(mpg ~ wt + factor(cyl), data = mtcars)
#' summary(as_honest_lm(fit))
as_honest_lm <- function(model, p_values = NULL) {
  if (!inherits(model, "lm")) {
    stop("`model` must inherit from class <lm>.", call. = FALSE)
  }

  if (!is.null(p_values)) {
    model$honest_lm_p_values <- match.arg(p_values, c("hide", "warn", "show"))
  } else if (is.null(model$honest_lm_p_values)) {
    model$honest_lm_p_values <- "hide"
  }

  class(model) <- unique(c("honest_lm", class(model)))
  model
}
