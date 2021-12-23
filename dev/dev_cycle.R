
# Functions definition --------------------------------------------

usethis::use_r("<function_name>")
# Document the function going inside its body and pressing
# "`CTRL` + `SHIFT` + `ALT` + R".
#
# More info at: https://r-pkgs.org/man.html


# Install any new required package by
renv::install("<new.package.used.in.the.function>")
# Add it in the DESCRIPTION file:
usethis::use_package("<new.package.used.in.the.function>")
# Use explicit `package::function()` call inside the function's body.


# Test your functions
basename(usethis::use_test("mp4_to_wav_safe")) |> usethis::use_r()
basename(usethis::use_test("run")) |> usethis::use_r()
basename(usethis::use_test("wav_to_txt_safe")) |> usethis::use_r()
# press "`CTRL` + `SHIFT` + T" to run all the tests.
#
# If you like, take advantage of {autotestthat} to automatically run
# every test in the background (on a separate R session, not make your
# busy!). They are run at every changes you saved in both any function
# or every test. Only the test that can be altered by your changes are
# run.
#
# renv::install("CorradoLanera/autotestthat")
#
# Next, go to the RStudio's Addins menu and select "autotest package".


# update NEWS.md (if relevant).




# Before every commit ---------------------------------------------

spelling::spell_check_package()
# spelling::update_wordlist()


lintr::lint_package()


renv::status()
# renv::snapshot()  # if any new package is being installed/used


usethis::use_tidy_description()
