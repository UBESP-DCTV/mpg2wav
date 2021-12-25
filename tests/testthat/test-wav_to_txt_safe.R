test_that("wav_to_txt_safe works", {
  # setup
  video_path <- here::here("tests/testthat/data-test/OTP-login.mp4")
  audio_path <- withr::local_file("audio.wav")
  text_path <- withr::local_file("text.txt")

  # execute
  res <- mp4_to_wav_safe(video_path, audio_path) |>
    purrr::pluck("result") |>
    wav_to_txt_safe(text_path)

  # expectation
  expect_true(fs::file_exists(video_path))  # just an hp check
  expect_null(res[["error"]])
  expect_true(fs::file_exists(res[["result"]]))
  expect_gt(fs::file_info(res[["result"]])[["size"]], 100)

})
