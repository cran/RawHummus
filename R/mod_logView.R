#' logView UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_logView_ui <- function(id){
  ns <- NS(id)
  tagList(
    fluidRow(
      #(1) User guide ==========================================================
      column(width = 12,
             box(
               width = 12,
               title = strong("User Guide"),
               status = "warning",
               solidHeader = FALSE,
               collapsible = TRUE,
               collapsed = FALSE,
               closable = FALSE,
               p("A log file is a type of text file with the .log extension. In the case of the Orbitrap Exactive instrument,
                 The default directory is", code("C:\\Xcalibur\\system\\Exactive\\log.")),
               p("1. You can upload a single log file to monitor different instrument parameters of the day, or multiple
                 files to compare the instrument status among different dates."),
               p("2. There are more than 40 parameters to inspect, you can use", strong("Select Parameters to View"),
                 "panel to select the parameter of interest."),
               p("3.", strong("Plot"), "panel allows you to interactively view, compare and save the results.
                 Data point from the same day means that they were measured at different time points of the day.")
               )
             ),

      #(2) Input ===============================================================
      column(width = 4,
             box(
               width = 12,
               inputId = "input_card",
               title = strong("Data Input Panel"),
               status = "primary",
               solidHeader = FALSE,
               collapsible = FALSE,
               collapsed = FALSE,
               closable = FALSE,
               fileInput(inputId = ns("logs"),
                         label = "Upload log files:",
                         multiple = TRUE,
                         placeholder = "C:/Xcalibur/system/Exactive/log",
                         accept = c(".log")
                         ),

               actionButton(inputId = ns("monitor"),
                            label = "Monitor",
                            icon = icon("paper-plane"),
                            style = "color: #fff; background-color: #67ac8e; border-color: #67ac8e"
                            )
               )
             ),

      #(3) Output ==============================================================
      column(width = 8,
             box(
               width = 12,
               inputId = "input_card",
               title = strong("Select Parameters to View"),
               status = "success",
               solidHeader = FALSE,
               collapsible = FALSE,
               collapsed = FALSE,
               closable = FALSE,
               selectInput(inputId = ns("selected_parameters"),
                           label = "",
                           choices = list()
                           )
               ),
             box(
               width = 12,
               inputId = "report_card",
               title = strong("Plot"),
               status = "success",
               solidHeader = FALSE,
               collapsible = TRUE,
               collapsed = FALSE,
               closable = FALSE,
               plotly::plotlyOutput(ns("logFiles"))
               )
             )
      )
  )
}


#' logView Server Functions
#'
#' @noRd
#' @importFrom ggplot2 aes
#'
mod_logView_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    #(1) Check input files =====================================================
    userLogs <- reactive({
      infile <- input$logs
      if(is.null(infile)){
        return(NULL)
      } else {
        ## keep original file names
        oldNames = infile$datapath
        newNames = file.path(dirname(infile$datapath), infile$name)
        file.rename(from = oldNames, to = newNames)
        filepath <- newNames
        return(filepath)
      }
    })

    #(2) Read logs =============================================================
    logDF <- reactive({
      readLogFile(userLogs())
    })

    #(3)Plot ===================================================================
    observeEvent(input$monitor, {
      shiny::validate(need(length(userLogs()) > 0, "no files selected"))
      shiny::validate(need(!is.null(logDF), "no files selected"))

      observe({
        x <- colnames(logDF())[-c(1:3)]
        updateSelectInput(session,
                          inputId = "selected_parameters",
                          choices = x,
                          selected = x[1]
                          )
        })

      nDate <- length(levels(as.factor(logDF()$Date))) ## get number of Date levels
      output$logFiles <- plotly::renderPlotly({
        req(input$selected_parameters)
        plotly::plot_ly(data = logDF(),
                x = ~ Date,
                y = ~ get(input$selected_parameters),
                color = ~ Date,
                colors = RColorBrewer::brewer.pal(min(max(3, nDate), 12), "Paired"), ## min =3, max = 12
                type = 'scatter',
                mode = 'markers',
                size = 10,
                hoverinfo = 'x+y') %>%
          plotly::layout(yaxis = list(title = ''), yaxis = list(""))
      })
    })
  })
}

## To be copied in the UI
# mod_logView_ui("logView_1")

## To be copied in the server
# mod_logView_server("logView_1")
