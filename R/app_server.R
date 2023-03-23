#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  options(shiny.maxRequestSize = 10000 * 1024^2) ## file size limit
  global <- reactiveValues()
  mod_home_server("home_1")
  mod_logView_server("logView_1")
  mod_qcView_server("qcView_1", global = global)
  mod_contact_server("contact_1")
}
