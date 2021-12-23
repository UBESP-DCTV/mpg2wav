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
run <- function(videos, exclude_done = TRUE) {

  if (exclude_done) {
    path_txt_done <- videos |>
      purrr::map_chr(stringr::str_replace, "\\.[mM][pP]4$", "-MS_COGNITIVE_ELABORATED.txt")
    are_txt_done <- purrr::map_lgl(path_txt_done, fs::file_exists)
    videos <- videos[!are_txt_done]
  }

  n_videos <- length(videos)
  res <- vector("list", length = n_videos)

  if (n_videos == 0) {
    message("All video seams already processed to txt. Function exits")
    return(invisible(res))
  }

  todo <- rep(TRUE, n_videos)
  while (any(todo)) {
    video_todo <- videos[which(todo)]  # which in case there is only one
    outputs_wav <- video_todo |>
      purrr::map_chr(stringr::str_replace, "\\.[mM][pP]4$", ".wav")
    outputs_txt <- video_todo |>
      purrr::map_chr(stringr::str_replace, "\\.[mM][pP]4$", "-MS_COGNITIVE_ELABORATED.txt")

    p <- progressr::progressor(steps = 2 * length(video_todo))
    res[which(todo)] <- purrr::pmap(
      list(video_todo, outputs_wav, outputs_txt),
      ~ mp4_to_wav_safe(..1, ..2, p = p) |>
          purrr::pluck("result") |>
          wav_to_txt_safe(..3, p = p)
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
  invisible(res)
}
