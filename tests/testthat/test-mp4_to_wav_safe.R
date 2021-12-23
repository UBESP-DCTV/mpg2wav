test_that("mp4_to_wav_safe works", {
  # setup
  video_path <- here::here("tests/testthat/data-test/OTP-login.mp4")
  audio_output <- withr::local_file("output.wav")

  # execute
  res <- mp4_to_wav_safe(video_path, audio_output)

  # expectation
  expect_true(fs::file_exists(video_path))  # just an hp check
  expect_null(res[["error"]])
  expect_true(fs::file_exists(res[["result"]]))
})
