#' @keywords internal
"_PACKAGE"

.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    "honestlm: use honest_lm() for guarded linear model summaries, ",
    "or as_honest_lm(lm(...)) for existing lm objects."
  )
}
