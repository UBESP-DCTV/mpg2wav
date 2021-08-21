# https://www.r-bloggers.com/2020/02/working-with-audio-in-r-using-av/

library(here)
library(av)

source_dir <- file.path(
  "C:", "Users", "corra", "OneDrive", "Teaching", "2020_master_mlt",
  "DL", "week3-sequential-CL", "raw-video", "03-NLP"
)

filename <- "RNN-nlp-5_5_07"

input_mp4 <- file.path(source_dir, paste0(filename, ".mp4"))

output_wav <- here("dev/output", paste0(filename, ".wav"))

av_media_info(input_mp4)
av_audio_convert(
  input_mp4, output_wav,
  channels = 1, sample_rate = 16000,
  total_time = 20
)
