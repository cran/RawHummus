#' qcView UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @importFrom data.table address
#' @importFrom kableExtra kbl
m <- matrix(data = NA, nrow = 3, ncol = 2, dimnames = list(NULL, c("mz", "Expected_RT")))
mod_qcView_ui <- function(id){
  ns <- NS(id)
  tagList(
    fluidRow(
      column(width = 12,
             box(
               width = 12,
               title = strong("User Guide"),
               status = "warning",
               solidHeader = FALSE,
               collapsible = TRUE,
               collapsed = FALSE,
               closable = FALSE,
               p(strong("QCviewer"), "tab enables evaluating LCMS system using QC samples."),
               p("1. The converted QC files can be uploaded in", strong("Data Input Panel"), ". Note at least two QC files are required."),
               p("2.", strong("QCviewer"), "automatically select 6 peaks accross the retention time (RT) range in your sample to evalute the system.
                 The 6 peaks are peaks with highest ion intensity from 6 evenly sliced RT ranges. Optionally, you could add peaks of interest to evaluate
                 your QC samples in a more targeted and specific manner."),
               p("3. You can click", strong("Read Data"), "button to start reading the raw data. Be patient, it may take a while for the evaluation process."),
               p("4. Once data is extracted, a download button is prompt to allow downloading the evaluation report."),
               p("5. You may need to restart your PC if the report generation is stuck.")
               )
             ),

      column(width = 6,
             box(
               width = 12,
               inputId = "input_card",
               title = strong("Data Input Panel"),
               status = "primary",
               solidHeader = FALSE,
               collapsible = FALSE,
               collapsed = FALSE,
               closable = FALSE,
               fileInput(
                 inputId = ns("convertedData"),
                 label = "1. Upload data (mzML/mzXML format):",
                 multiple = TRUE,
                 accept = c(".mzML", ".mzXML")
                 ),
               sliderInput(
                 inputId = ns("mynoise"),
                 label = "2. (Optional but recommended:) Estimated noise intensity level",
                 value = 1000,
                 min = 0,
                 max = 1000000,
                 step = 1000,
                 ticks = FALSE
                 ),
               strong("3. (Optional:) Add peaks of interest to monitor"),
               br(),
               br(),
               p(style = "color:#CD5C5C;", shiny::icon("bell"), strong("Note: ")),
               p(span("1. You can enter the m/z values and the expected retention time (in minutes) for the metabolite you are interested in.", style = "color:#CD5C5C")),
               p(span("2. If you don't know the expected retention times for your metabolites. You can leave them empty. RawHummus will try to find them for you.", style = "color:#CD5C5C")),
               shinyMatrix::matrixInput(
                 inputId = ns("mypeaks"),
                 label = "",
                 value = m,
                 rows = list(extend = TRUE, names = FALSE),
                 cols = list(names = TRUE),
                 class = "numeric"
                 ),
               p(span("3. You can set mass and retention time tolerance windows below to enable RawHummus search for your metabolites of interest.", style = "color:#CD5C5C")),
               column(width = 6,
                      sliderInput(
                        inputId = ns("myppm"),
                        label = "Mass tolerance (ppm)",
                        value = 10,
                        min = 1,
                        max = 100
                        )
                      ),
               column(width = 6,
                      sliderInput(
                        inputId = ns("myrt"),
                        label = "RT tolerance (min)",
                        value = 2,
                        min = 0.1,
                        max = 5
                        )
                      ),
               strong("4. (Optional:) Slide to select retention time range"),
               br(),
               br(),
               p(style = "color:#CD5C5C;", shiny::icon("bell"), strong("Note: ")),
               p(span(" 1. You can adjust the retention time by trimming it. For example, you have the option to remove the first and last 0.5 minutes", style = "color:#CD5C5C")),
               column(width = 6,
                      sliderInput(
                        inputId = ns("startRT"),
                        label = "Trim the first N minutes",
                        value = 0,
                        min = 0,
                        max = 20,
                        step = 0.2
                        )
                      ),
               column(width = 6,
                      sliderInput(
                        inputId = ns("endRT"),
                        label = "Trim the last N minutes",
                        value = 0,
                        min = 0,
                        max = 20,
                        step = 0.2
                        )
                      ),
               actionButton(
                 inputId = ns("evaluate"),
                 label = "Read Data",
                 icon = icon("paper-plane"),
                 style = "color: #fff; background-color: #67ac8e; border-color: #67ac8e"
                 )
               )
             ),

      #(2) Output ==============================================================
      column(width = 6,
             box(
               width = 12,
               inputId = "report_card",
               title = strong("Report"),
               status = "success",
               solidHeader = FALSE,
               collapsible = TRUE,
               collapsed = FALSE,
               closable = FALSE,
               shinycustomloader::withLoader(
                 uiOutput(outputId = ns("report_button")),
                 type = "html",
                 loader = "dnaspin"
                 )
               )
             )
      )
    )
  }

#' qcView Server Functions
#'
#' @noRd
mod_qcView_server <- function(id, global){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    #(1) Check input files and parameters ======================================
    userInput <- reactive({
      infile <- input$convertedData
      if (is.null(infile)){
        return(NULL)
        } else {
        oldNames = infile$datapath
        newNames = file.path(dirname(infile$datapath), infile$name)
        file.rename(from = oldNames, to = newNames)
        filepath <- newNames
        return(filepath)
        }
    })

    mynoise <- reactive({input$mynoise})
    mypeaks <- reactive({input$mypeaks})
    myppm <- reactive({input$myppm})
    myrt <- reactive({input$myrt})
    startRT <- reactive({input$startRT})
    endRT <- reactive({input$endRT})

    #(2) Report ================================================================
    output$report_button <- ({NULL})
    observeEvent(input$evaluate, {

      #(2.1) generate report button
      output$report_button <- renderUI({
        shiny::validate(need(length(userInput()) >= 2, "Attention: at least 2 data files are required"))
        global$msdata <- RaMS::grabMSdata(files = userInput(), grab_what = c("MS1", "MS2", "TIC"))
        downloadButton(
          outputId = ns("report"),
          label = "Download Report",
          style="color: #fff; background-color: #a077b5; border-color: #a077b5"
          )
        })
      ## remove action button after it is clicked
      removeUI(selector = paste0("#", ns("evaluate")), session = session)
    })

    ##(2.2) generate report
    output$report <- downloadHandler(
      filename <- paste0(Sys.Date(), "_QCReport.html"),
      content <- function(file){
        shiny::withProgress(
          message = "Generating report",
          detail = "This may take a while...",
          value = 0.4,
          {
            tempReport <- file.path(tempdir(), "Report.Rmd")
            tempCSS <- file.path(tempdir(), "style.css")
            tempLogo <- file.path(tempdir(), "logo.png")
            file.copy(app_sys("app/www/Report.Rmd"), tempReport, overwrite = TRUE)
            file.copy(app_sys("app/www/reportCSS/style.css"), tempCSS)
            file.copy(app_sys("app/www/img/logo2.png"), tempLogo)
            params <- list(msdata = global$msdata,
                           mynoise = mynoise(),
                           mypeaks = mypeaks(),
                           myppm = myppm(),
                           myrt = myrt(),
                           startRT = startRT(),
                           endRT = endRT()
                           )
            rmarkdown::render(tempReport,
                              output_file = file,
                              params = params,
                              envir = new.env(parent = globalenv())
                              )
            })
        })
  })
}

## To be copied in the UI
# mod_qcView_ui("qcView_1")

## To be copied in the server
# mod_qcView_server("qcView_1")
