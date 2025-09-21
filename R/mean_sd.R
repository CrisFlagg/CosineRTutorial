#' Mean and standard deviation
#'
#' Computes the mean and standard deviation for a numeric vector.
#'
#' @param x A numeric vector.
#' @return A list with components `mean` and `sd`.
#' @examples
#' mean_sd(c(1, 2, 3, 4))
#' @export
mean_sd <- function(x) {
  stopifnot(is.numeric(x))
  list(mean = mean(x), sd = stats::sd(x))
}