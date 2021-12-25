#' Extract WAV from MP4
#'
#' @param .input (chr) mp4 input's path
#' @param .output (chr) wav output's path
#' @param pb a [progressor][progressr::progressor] (optional)
#'
#' @return Wav [.output] path
#' @keywords internal
#'
#' @examples
#' \dontrun{
#'   library(progressr)
#'
#'   good_video_path <- "path/to/good_video.mp4"
#'   with_progress({
#'     good_res <- mp4_to_wav_safe(good_video_path)
#'   })
#'   good_res
#'   good_res[["result"]]
#'   good_res[["error"]]
#'
#'   bad_video_path <- "path/to/bad_video.mp4"
#'   with_progress({
#'     bad_res <- mp4_to_wav_safe(bad_video_path)
#'   })
#'   bad_res
#'   bad_res[["result"]]
#'   bad_res[["error"]]
#'
#' }
mp4_to_wav_safe <- purrr::safely(function(
  .input,
  .output = fs::file_temp("audio", ext = "wav"),
  pb = progressr::progressor()
) {
  pb(message = paste0(basename(.input), " to wav"))

  info <- av::av_media_info(.input)[["video"]]
  duration_s <- ceiling(info[["frames"]] / info[["framerate"]])

  av::av_audio_convert(
    audio = .input,
    output = .output,
    channels = 1,
    sample_rate = 16000,
    total_time = duration_s,
    verbose = FALSE
  )
  .output
})
