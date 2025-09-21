suppressPackageStartupMessages({
  library(tidyverse)
})

set.seed(123)

# Example dataset
df <- tibble(
  group = rep(LETTERS[1:3], each = 50),
  x = rnorm(150, mean = rep(c(0, 1, -1), each = 50), sd = 1),
  y = rnorm(150)
)

# Summarise by group
summary_tbl <- df %>%
  group_by(group) %>%
  summarise(
    across(c(x, y), list(mean = mean, sd = sd), .names = "{.col}_{.fn}"),
    .groups = "drop"
  )

# Ensure outputs directory exists
dir.create("outputs", showWarnings = FALSE, recursive = TRUE)

# Save results
readr::write_csv(summary_tbl, "outputs/summary.csv")

p <- ggplot(df, aes(x, y, color = group)) +
  geom_point(alpha = 0.7) +
  geom_smooth(method = "lm", se = FALSE) +
  theme_minimal()

ggplot2::ggsave("outputs/plot.png", p, width = 7, height = 5, dpi = 150)

print(summary_tbl)
message("Wrote outputs/summary.csv and outputs/plot.png")