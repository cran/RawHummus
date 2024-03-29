#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @importFrom  shinydashboard sidebarMenu menuItem menuSubItem dashboardBody tabItems tabItem
#' @import shinydashboardPlus
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Your application UI logic
    fluidPage(
      dashboardPage(
        ## Header --------------------------------------------------------------
        header = dashboardHeader(title = strong("RawHummus")),
        ## Sidebar -------------------------------------------------------------
        sidebar = dashboardSidebar(
          sidebarMenu(
            id = "sidebarmenu",
            menuItem(text = strong("Home"), tabName = "home", icon = icon("home")),
            hr(),
            menuItem(text = strong("Logviewer"), tabName = "monitor", icon = icon("book")),
            hr(),
            menuItem(text = strong("QCviewer"), tabName = "evaluate", icon = icon("check-square")),
            hr(),
            menuItem(text = strong("Contact"), tabName = "contact", icon = icon("smile"))
            )
          ),

        ## Body ----------------------------------------------------------------
        body = dashboardBody(
          tabItems(
            tabItem(tabName = "home",  mod_home_ui("home_1")),
            tabItem(tabName = "monitor",  mod_logView_ui("logView_1")),
            tabItem(tabName = "evaluate",  mod_qcView_ui("qcView_1")),
            tabItem(tabName = "contact", mod_contact_ui("contact_1"))
            )
          ),

        ## Footer --------------------------------------------------------------
        footer = dashboardFooter(
          left = "Metabolic Profiling Unit, Weizmann Institute of Science",
          right = "Copyright (C) 2023"
          )
        )
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "RawHummus"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
