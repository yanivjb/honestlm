#' Model-predicted means for categorical displays
#'
#' `stat_lm_means()` is a model-aware alternative to using
#' [ggplot2::stat_summary()] for means and intervals. It draws fitted means from
#' a linear model implied by the plot aesthetics instead of raw grouped means.
#' With two categorical predictors, `interaction = FALSE` fits an additive model
#' and `interaction = TRUE` fits the interaction model.
#'
#' @inheritParams ggplot2::layer
#' @param interaction Should the fitted means come from an interaction model? The
#'   default `FALSE` uses an additive model.
#' @param se Should confidence intervals be drawn?
#' @param level Confidence level for intervals.
#' @param na.rm If `FALSE`, missing values are removed with a warning. If
#'   `TRUE`, missing values are silently removed.
#' @param ... Additional arguments passed to the ggplot2 layer.
#'
#' @return A ggplot2 layer.
#' @export
#'
#' @examples
#' library(ggplot2)
#'
#' ggplot(mtcars, aes(factor(cyl), mpg, colour = factor(am))) +
#'   geom_point() +
#'   stat_lm_means()
stat_lm_means <- function(mapping = NULL,
                          data = NULL,
                          geom = "pointrange",
                          position = "identity",
                          ...,
                          interaction = FALSE,
                          se = TRUE,
                          level = 0.95,
                          na.rm = FALSE,
                          show.legend = NA,
                          inherit.aes = TRUE) {
  ggplot2::layer(
    data = data,
    mapping = mapping,
    stat = StatLmMeans,
    geom = geom,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      interaction = interaction,
      se = se,
      level = level,
      na.rm = na.rm,
      ...
    )
  )
}

StatLmMeans <- ggplot2::ggproto(
  "StatLmMeans",
  ggplot2::Stat,

  required_aes = c("x", "y"),
  extra_params = c("na.rm", "interaction", "se", "level"),

  compute_panel = function(data, scales, interaction = FALSE, se = TRUE,
                           level = 0.95, na.rm = FALSE) {
    group_var <- honest_plot_group_var(data)
    needed <- c("x", "y", group_var)
    keep <- stats::complete.cases(data[, needed, drop = FALSE])
    data <- data[keep, , drop = FALSE]

    if (nrow(data) == 0) {
      return(data[0, , drop = FALSE])
    }

    x_levels <- sort(unique(data$x))
    data$.lm_x <- factor(data$x, levels = x_levels)
    x_has_multiple_levels <- length(x_levels) > 1

    if (is.null(group_var)) {
      formula <- if (x_has_multiple_levels) y ~ .lm_x else y ~ 1
      fit <- stats::lm(formula, data = data)
      pred_data <- data.frame(.lm_x = levels(data$.lm_x))
      pred_data$x <- as.numeric(as.character(pred_data$.lm_x))
      pred_data$group <- seq_len(nrow(pred_data))
    } else {
      data$.lm_group <- factor(data[[group_var]], levels = unique(data[[group_var]]))
      group_has_multiple_levels <- nlevels(data$.lm_group) > 1

      formula <- if (x_has_multiple_levels && group_has_multiple_levels && isTRUE(interaction)) {
        y ~ .lm_x * .lm_group
      } else if (x_has_multiple_levels && group_has_multiple_levels) {
        y ~ .lm_x + .lm_group
      } else if (x_has_multiple_levels) {
        y ~ .lm_x
      } else if (group_has_multiple_levels) {
        y ~ .lm_group
      } else {
        y ~ 1
      }
      fit <- stats::lm(formula, data = data)

      combos <- unique(data[, c("x", group_var), drop = FALSE])
      combos <- combos[order(combos$x, combos[[group_var]]), , drop = FALSE]
      pred_data <- data.frame(
        .lm_x = factor(combos$x, levels = levels(data$.lm_x)),
        .lm_group = factor(combos[[group_var]], levels = levels(data$.lm_group)),
        x = combos$x,
        group = as.integer(interaction(combos$x, combos[[group_var]], drop = TRUE))
      )
      pred_data[[group_var]] <- combos[[group_var]]
    }

    pred <- stats::predict(fit, newdata = pred_data, se.fit = TRUE)
    pred_data$y <- as.numeric(pred$fit)

    if (isTRUE(se)) {
      crit <- stats::qt((1 + level) / 2, df = stats::df.residual(fit))
      pred_data$se <- as.numeric(pred$se.fit)
      pred_data$ymin <- pred_data$y - crit * pred_data$se
      pred_data$ymax <- pred_data$y + crit * pred_data$se
    }

    aesthetic_cols <- intersect(
      c("colour", "color", "fill", "alpha", "linetype", "linewidth", "size", "shape"),
      names(data)
    )

    for (aesthetic in aesthetic_cols) {
      if (!is.null(group_var) && identical(aesthetic, group_var)) {
        next
      }

      pred_data[[aesthetic]] <- vapply(
        seq_len(nrow(pred_data)),
        function(i) {
          rows <- data$x == pred_data$x[i]
          if (!is.null(group_var)) {
            rows <- rows & data[[group_var]] == pred_data[[group_var]][i]
          }
          data[[aesthetic]][which(rows)[1]]
        },
        data[[aesthetic]][1]
      )
    }

    pred_data
  }
)
