test_that("mean_sd calculates correct values", {
  x <- c(1, 2, 3, 4)
  res <- mean_sd(x)
  expect_type(res, "list")
  expect_equal(res$mean, mean(x))
  expect_equal(res$sd, sd(x))
})

test_that("mean_sd fails on non-numeric input", {
  expect_error(mean_sd(letters))
})