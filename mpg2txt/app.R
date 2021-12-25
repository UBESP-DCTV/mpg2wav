library(shiny)
library(av)
library(here)
library(readr)

options(shiny.maxRequestSize = 1*1024^3)
# Define UI for data upload app ----
ui <- fluidPage(
    titlePanel("Extract txt from mp4"),
    sidebarLayout(
        sidebarPanel(
            fileInput("source_mp4", "Choose an mp4 file",
                      multiple = FALSE,
                      accept = c("video/mp4", ".mp4"))
        ),
        mainPanel(
            textOutput("out_txt")
        )

    )
)

# Define server logic to read selected file ----
server <- function(input, output) {

    output$out_txt <- renderText({

        req({
            input$source_mp4
        })

        message("START processing ...")

        source_audio <- fs::file_temp("source_audio", ext = "Wav")
        output_text <- fs::file_temp("output_text", ext = "txt")
        aux_prog <- fs::file_temp(
            "index_aux",
            tmp_dir = here::here("dev/speechFileToText"),
            ext = "js"
        )

        message("EXTRACTING video to audio ...")
        av_audio_convert(
            input$source_mp4$datapath, source_audio,
            channels = 1, sample_rate = 16000,
            total_time = 60
        )

        message("TUNING the program ...")
        here::here("dev/speechFileToText/index.js") |>
            readr::read_lines() |>
            stringr::str_replace_all(
                "var filename = .*;",
                paste0("var filename = \"", source_audio, "\";")
            ) |>
            stringr::str_replace_all(
                "fs.writeFileSync\\(\".*\", tempText\\);",
                paste0(
                    'fs.writeFileSync("', output_text, '", tempText);'
                )
            ) |>
            readr::write_lines(aux_prog)

        message("EXTRACTING text from audio ...")
        system2("node", aux_prog)

        message("READING output ...")
        res <- readr::read_lines(output_text)

        message("RETURN and FINISH!")
        res
    })
}

# Create Shiny app ----
shinyApp(ui, server)

