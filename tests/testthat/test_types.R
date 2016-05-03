context("type checking")

test_that("Various types get stored and coersed correctly",{

  #a bit of everything, copied from jsonlite package
  set.seed('123')
  mydata <- data.frame(
    num = c(pi, NA, NaN, Inf, -Inf),
    int = c(-1, 0, 21, NA, 999999),
    bool = c(T, T, T, F, NA),
    dates = as.Date(Sys.time()) + c(1:4, NA),
    times = Sys.time() + c(1:4, NA),
    stringsAsFactors = FALSE
  )

  tmp <- tempfile()
  dir.create(tmp)
  x <- data_package(tmp)
  x$resources$add(mydata, "test")
  expect_equal(mydata, x$resources$read("test"))
})
