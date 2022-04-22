x = tibble::tibble(
  Package = names(installed.packages()[,3]),
  Version = unname(installed.packages()[,3])
)

write.csv(x, "env_r.csv", row.names=FALSE)
