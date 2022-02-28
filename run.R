# Setup -----------------------------------------------------------

options(tidyverse.quiet = TRUE)

library(progressr)
library(tidyverse)
library(dbplyr, warn.conflicts = FALSE)
library(DBI)
library(here)

progressr::handlers(progressr::handler_progress(
    format = ":spin step :current/:total (:message) [:bar] :percent in :elapsed ETA: :eta",
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
) |>
  stringr::str_subset("^.*/\\..*$", negate = TRUE)

# Run -------------------------------------------------------------
with_progress({
  freshstart <- FALSE

  db_name <- "E:/transcripts.sqlite"
  is_db_there <- fs::file_exists(db_name) &&
    fs::file_info(db_name)[["size"]]

  con <- withr::local_db_connection(
    DBI::dbConnect(RSQLite::SQLite(), db_name)
  )

  if (!is_db_there || freshstart) {
    dbExecute(con, "DROP TABLE IF EXISTS videos", immediate = TRUE)
    dbExecute(con, "CREATE TABLE videos
      (
        id INTEGER PRIMARY KEY, -- Autoincrement
        timestamp TIMESTAMP,
        folder TEXT,
        video INTEGER,
        audio INTEGER,
        text INTEGER,
        done LOGICAL
      )
    ", immediate = TRUE)
  }

  res <- run(videos, con = con, table = "videos")
}, delay_terminal = FALSE)
