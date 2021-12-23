# https://www.r-bloggers.com/2020/02/working-with-audio-in-r-using-av/

library(here)
library(av)

source_dir <- here::here("dev/data-raw")

filename <- "2021Presentazione_Master_BIO_Avanzato_2021.mp4_(Source)"

input_mp4 <- file.path(source_dir, paste0(filename, ".mp4"))

output_wav <- here("dev/output", paste0(filename, ".wav"))

av_media_info(input_mp4)
av_audio_convert(
  input_mp4, output_wav,
  channels = 1, sample_rate = 16000,
  total_time = 600
)
conv_res <- system2(
  "node", here::here("dev/speechFileToText/index.js"),
  stdout = TRUE
)

