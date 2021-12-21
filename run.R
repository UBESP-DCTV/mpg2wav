
# Packages --------------------------------------------------------

# install.packages("beepr")
# install.packages("remotes")
# remotes::install_github("HenrikBengtsson/progressr")

library(purrr)
library(stringr)
library(av)
library(progressr)
handlers(handler_progress(
  format   = ":spin :current/:total (:message) [:bar] :percent in :elapsed ETA: :eta",
  width    = 60,
  complete = "+",
  clear = FALSE
))


# Data ------------------------------------------------------------

videos <- list.files(
  path = "E:/",
  full.names = TRUE,
  recursive = TRUE,
  pattern = "\\.mp4$",
  ignore.case = TRUE,
  no.. = TRUE
)


# Functions -------------------------------------------------------

mp4_to_wav_safe <- safely(function(.input, .output, p) {
  p(message = basename(.input))

  info <- av::av_media_info(.input)[["video"]]
  duration_s <- ceiling(info[["frames"]] / info[["framerate"]])

    av_audio_convert(
      audio = .input,
      output = .output,
      channels = 1,
      sample_rate = 16000,
      total_time = duration_s,
      verbose = FALSE
    )
    # Sys.sleep(1)
    # if (runif(1) > 0.5) stop(call. = FALSE)

  .output
})

run <- function(videos) {

  n_videos <- length(videos)
  res <- vector("list", length = n_videos)

  todo <- rep(TRUE, n_videos)
  while (any(todo)) {
    video_todo <- videos[todo]
    outputs_wav <- video_todo |>
      map_chr(str_replace, "\\.[mM][pP]4$", ".wav")

    p <- progressor(along = video_todo)
    res[todo] <- map2(video_todo, outputs_wav, mp4_to_wav_safe, p = p)

    are_errors <- transpose(res)[["error"]] |>
      map_lgl(~!is.null(.x))
    n_errors <- sum(are_errors)

    if (n_errors > 0L) {
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


# Run -------------------------------------------------------------
with_progress({
  res <- run(videos[1:5])
}, delay_terminal = FALSE)




