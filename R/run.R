#' Run conversion
#'
#' @param videos (chr) paths to videos
#'
#' @return a list with one element per video. Each element has two
#'   fields: "result", which stores the output wav's path or `NULL` if
#'   some error occurred, and "error", which stores the possible error
#'   message the process for the corresponding video returned an error,
#'   or `NULL` otherwise
#' @keywords internal
#'
#' @examples
#' \dontrun{
#'   with_progress({
#'     res <- run(videos[1:5])
#'   }, delay_terminal = FALSE)
#' }
#'
#'
run <- function(videos, con, table, restart_from_skratch = FALSE) {
  stopifnot(length(videos) != 0L)
  stopifnot(DBI::dbIsValid(con))

  if (restart_from_skratch &&
      (reset <- usethis::ui_yeah(
        "Are you sure to wipe the progresses?
Files will be not deleated, but the process restarts owerwriting them."
      ))
  ) {
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

  processed <- DBI::dbReadTable(con, "videos")
  n_videos <- length(videos)
  usethis::ui_info("There are {n_videos} videos to process.")
  res <- vector("list", length = n_videos)


  todo <- rep(TRUE, n_videos)
  while (any(todo)) {
    video_todo <- videos[which(todo)]  # which in case there is only one

    outputs_wav <- video_todo |>
      purrr::map_chr(stringr::str_replace, "\\.[mM][pP]4$", ".wav")
    outputs_txt <- video_todo |>
      purrr::map_chr(stringr::str_replace, "\\.[mM][pP]4$", "-MS_COGNITIVE_ELABORATED.txt")

    pb <- progressr::progressor(
      along = video_todo,
      message = "Starting...",
      scale = 2,
      offset = 1
)
    res[which(todo)] <- purrr::pmap(
      list(video_todo, outputs_wav, outputs_txt),
      ~ {
        present <- fs::file_exists(..3)
        current_processed <- processed |>
          dplyr::filter(
            stringr::str_remove(folder, "^[A-Z]://") ==
              stringr::str_remove(dirname(..3), "^[A-Z]://"),
            text == basename(..3)
          )
        done <- current_processed |>
          purrr::pluck("done") |>
          as.logical() |>  # it is 1 in sqlite
          isTRUE()  # considering NULL if not present, FALSE if errored

        if (present && !done) {
          cat("\n")
          usethis::ui_warn("
            {usethis::ui_value(..3)} is on disk but not marked as done."
          )
          usethis::ui_todo(
            "deleting {usethis::ui_value(basename(..3))}"
          )
          fs::file_delete(..3)
          usethis::ui_done(
            "{usethis::ui_value(basename(..3))} deleted."
          )
        }


        if (present && done) {  # considering is.null(done)
          pb(message = paste0(basename(..1), " to wav"))
          pb(message = paste(basename(..2), " to txt"))
          return(tibble::tibble(
            result = ..3,
            error = NULL
          ))
        }

        if (!present && done) {
          usethis::ui_warn("{usethis::ui_value(..3)} results done but missing")
          usethis::ui_info("{usethis::ui_value(..3)} will re-evaluated now")
          real_processed <- processed |>
            dplyr::anti_join(current_processed)
          DBI::dbWriteTable(con, "videos", real_processed, overwrite = TRUE)
        }

        is_online <- function() {
          if (!curl::has_internet()) {
            usethis::ui_warn("Internet connection lost.")

            is_net_restored <- interactive() &&
              usethis::ui_yeah("Have you restored it now?")

            if (is_net_restored) {
              usethis::ui_info("Let the computations continue!")
              return(is_online())
            } else {
              usethis::ui_info("The program exits now. Bye.")
              return(FALSE)
            }
          }
          TRUE
        }

        if (!is_online()) ui_stop("Internet connection lost.")

        wav <- if (fs::file_exists(..2)) {
          pb(message = paste0(basename(..1), " to wav"))
          ..2
        } else {
          mp4_to_wav_safe(..1, ..2, pb = pb) |>
            purrr::pluck("result")
        }
        res <- wav |> wav_to_txt_safe(..3, pb = pb)

        # if at this time internet is lost it possible caused some
        # undetected error in the evaluation, maybe even a non completed
        # transcription.
        if (is.null(res[["error"]]) && curl::has_internet()) {
          tbl <- tibble::tibble(
            timestamp = lubridate::now(),
            folder = dirname(..3),
            video = basename(..1),
            audio = basename(..2),
            text = basename(..3),
            done = TRUE
          )
          DBI::dbWriteTable(con, "videos", tbl, append = TRUE)
        }

        res
      }
    )

    are_errors <- purrr::transpose(res)[["error"]] |>
      purrr::map_lgl(~!is.null(.x))
    n_errors <- sum(are_errors)

    retry_on_errors <- FALSE
    if (n_errors > 0L && interactive()) {
      retry_on_errors <- usethis::ui_yeah("
    There are {n_errors} errors.
    Whould you like to try the conversion on them again?"
      )
    }
    if (n_errors > 0L && retry_on_errors) {
      todo <- are_errors
    } else {
      break
    }
  }
  pb(message = "All done!")
  invisible(res)
}
