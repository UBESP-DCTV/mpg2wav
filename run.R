
# Setup -----------------------------------------------------------
library(progressr)
library(purrr)
library(here)
handlers(handler_progress(
  format   = ":spin :current/:total (:message) [:bar] :percent in :elapsed ETA: :eta",
  width    = 78,
  complete = "+",
  clear = FALSE
))

list.files(here("R"), pattern = "\\.R$", full.names = TRUE) |>
  walk(source, echo = FALSE)

# Data ------------------------------------------------------------
videos <- list.files(
  path = "E:/",
  full.names = TRUE,
  recursive = TRUE,
  pattern = "\\.mp4$",
  ignore.case = TRUE,
  no.. = TRUE
)

# Run -------------------------------------------------------------
with_progress({
  res <- run(videos[1:5])
}, delay_terminal = FALSE)

