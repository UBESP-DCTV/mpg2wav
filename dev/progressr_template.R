library(progressr)
library(purrr)

fun_safe <- safely(function(x, p) {
  on.exit(p())
  Sys.sleep(1)
  if (runif(1) > 0.5) stop()
  x
})

run <- function(xs) {
  set.seed(1)
  res <- vector("list", length(xs))
  todo <- TRUE

  while (any(todo)) {
    xs_todo <- xs[todo]
    res[todo] <- map(xs_todo, fun_safe, p = progressor(along = xs_todo))
    todo <- map_lgl(res, ~!is.null(.x[["error"]]))
    print(todo)
  }
  invisible(res)
}

x <- seq_len(10)

# in_rstudio <- requireNamespace("rstudioapi", quietly = TRUE) &
#   rstudioapi::isAvailable()
#
# if (in_rstudio) with_progress(run(x), handler_rstudio())  # OK
#

with_progress(run(x), handler_txtprogressbar(clear = FALSE))  # OK
with_progress(run(x), handler_progress(clear = FALSE))  # First pb only
