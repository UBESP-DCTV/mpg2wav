#' Extract TXT from WAV
#'
#' @param .input (chr) wav input's path
#' @param .output (chr) txt output's path
#' @param p a [progressor][progressr::progressor] (optional)
#'
#' @return txt [.output] path
#' @keywords internal
#'
#' @examples
#' \dontrun{
#'   library(progressr)
#'
#'   good_audio_path <- "path/to/good_audio.wav"
#'   with_progress({
#'     good_res <- wav_to_txt_safe(good_audio_path)
#'   })
#'   good_res
#'   good_res[["result"]]
#'   good_res[["error"]]
#'
#'   bad_audio_path <- "path/to/bad_audio.mp4"
#'   with_progress({
#'     bad_res <- wav_to_txt_safe(bad_audio_path)
#'   })
#'   bad_res
#'   bad_res[["result"]]
#'   bad_res[["error"]]
#'
#' }
wav_to_txt_safe <- purrr::safely(function(
  .input,
  .output  = fs::file_temp("text", ext = "txt"),
  p = progressr::progressor()
){
  p(message = paste0("processing ", basename(.input)))

  aux_prog <- withr::local_file("index_aux.js")

  here::here("dev/speechFileToText/index.js") |>
    readr::read_lines() |>
    stringr::str_replace_all(
      "var filename = .*;",
      paste0("var filename = \"", .input, "\";")
    ) |>
    stringr::str_replace_all(
      "fs.writeFileSync\\(\".*\", tempText\\);",
      paste0(
        'fs.writeFileSync("', .output, '", tempText);'
      )
    ) |>
    readr::write_lines(aux_prog)

  system2("node", aux_prog, stdout = NULL)

  .output
})

# pp <- function(p = progressr::progressor(2)) {
#   Sys.sleep(1)
#   p(message = paste0("processing ", basename(.input)))
#   Sys.sleep(1)
#   p(message = paste0("processing ", basename(.input)))
#   Sys.sleep(1)
#   p(message = paste0("processing ", basename(.input)))
#   Sys.sleep(1)
# }
#
# progressr::with_progress(
#   pp()
# )

