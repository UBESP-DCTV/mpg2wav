# https://www.r-bloggers.com/2020/02/working-with-audio-in-r-using-av/

library(av)

av_media_info("test.mp4")

av_audio_convert("whale.mp4", "whale10.wav",
  channels = 1, total_time = 10
)
