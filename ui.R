library(shiny)
library(shinydashboard)

dashboardPage(
  dashboardHeader(title = "Fund Split Validation Tool"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("File Upload", tabName = "upload", icon = icon("th")),
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard"))
    )
  ),
#UPLOAD TAB ####  
  dashboardBody(
    tabItems(
      tabItem(tabName = "upload",
              fluidRow(
                column(width = 4,
#file input for practice data----
                box(fileInput(inputId = "cfs", 
                              label = "Choose Current Fund Split File",
                          accept = c("text/csv",
                                     "text/comma-separated-values,text/plain",
                                     ".csv")),
                    checkboxInput("header", "Header", TRUE),
                # Input: Select separator
                radioButtons(inputId = "sep", 
                             label = "Separator",
                             choices = c(Comma = ",",
                                         Semicolon = ";",
                                         Tab = "\t"),
                             selected = ",")
                    ),
                
#file input for VACCINE BREAKDOWN----
                box(fileInput(inputId = "vb", 
                              label = "Choose Vaccine Breakdown File",
                          accept = c("text/csv",
                                     "text/comma-separated-values,text/plain",
                                     ".csv")),
                checkboxInput("header", "Header", TRUE),
                # Input: Select separator
                radioButtons(inputId = "sep", 
                             label = "Separator",
                             choices = c(Comma = ",",
                                         Semicolon = ";",
                                         Tab = "\t"),
                             selected = ",")
                     ),
                
#file input for PRACTICE PROFILE----
                box(fileInput(inputId = "pp", 
                              label = "Choose Practice Profile File",
                              accept = c("text/csv",
                                         "text/comma-separated-values,text/plain",
                                         ".csv")),
                    checkboxInput("header", "Header", TRUE),
                    # Input: Select separator
                    radioButtons(inputId = "sep", 
                                 label = "Separator",
                                 choices = c(Comma = ",",
                                             Semicolon = ";",
                                             Tab = "\t"),
                                 selected = ",")
                     ),
#file input for VACCINE ORDERING DATA----
                box(fileInput(inputId = "vo", 
                              label = "Choose Vaccine Ordering File",
                              accept = c("text/csv",
                                         "text/comma-separated-values,text/plain",
                                         ".csv")),
                    checkboxInput("header", "Header", TRUE),
                    # Input: Select separator
                    radioButtons(inputId = "sep", 
                                 label = "Separator",
                                 choices = c(Comma = ",",
                                             Semicolon = ";",
                                             Tab = "\t"),
                                 selected = ",")
                    ),
#file input for VACCINE REFERENCE TABLE ----
                box(fileInput(inputId = "vac.rt", 
                              label = "Choose Vaccine Reference File",
                              accept = c("text/csv",
                                         "text/comma-separated-values,text/plain",
                                         ".csv")),
                    checkboxInput("header", "Header", TRUE),
                    
                    # Input: Select separator
                    radioButtons(inputId = "sep", 
                                 label = "Separator",
                                 choices = c(Comma = ",",
                                             Semicolon = ";",
                                             Tab = "\t"),
                                 selected = ",")
                ),
#file input for VACCINE REFERENCE TABLE----
                box(fileInput(inputId = "status.rt", 
                              label = "Choose Insurance Status Reference File",
                              accept = c("text/csv",
                                          "text/comma-separated-values,text/plain",
                                          ".csv")),
                    checkboxInput("header", "Header", TRUE),
    
                    # Input: Select separator
                    radioButtons(inputId = "sep", 
                                 label = "Separator",
                                 choices = c(Comma = ",",
                                 Semicolon = ";",
                                 Tab = "\t"),
                                 selected = ",")
                      )
            
               # fluidRow(dataTableOutput("cfs.data"))
                      ))
                ),
#DASHBOARD TAB ####
      tabItem(tabName = "dashboard",
              fluidRow(
                column(width = 3,
                       box(title = "Filtering Controls",  width = NULL,
                           sliderInput(inputId = "vac",
                                       label = "Total Vaccines Administered",
                                       min = 0, max = 40000,
                                       value = c(0,40000), step = 500),
                           sliderInput(inputId = "vb", label = "Vaccine Breakdown Delta",
                                       min = -1, max = 1,
                                       value = c(-1,1), step = .05),
                           sliderInput(inputId = "pp",label = "Practice Profile Delta",
                                       min = -1, max = 1,
                                       value = c(-1,1), step = .05),
                           sliderInput(inputId = "unknown",label = "Unknown Vaccine Status Percentage",
                                       min = 0, max = 1,
                                       value= c(0, 8), step = 0.05),
                           checkboxGroupInput(inputId = "age", label = "Age Group",
                                              choices = c("Pediatric" = "PED", "Adolescent" = "ADO"),
                                              selected = c("Pediatric" = "PED", "Adolescent" = "ADO")),
                           checkboxGroupInput(inputId = "source", label = "Data Source",
                                              choices = c("IIS" = "IIS", "Other" = "OTHER", "Billing" = "BILLING", "Billing/IIS" = "BILLING/IIS"),
                                              selected = c("IIS" = "IIS", "Other" = "OTHER", "Billing" = "BILLING", "Billing/IIS" = "BILLING/IIS")),
                           actionButton(inputId = "go", label = "Update"),
                           downloadButton(outputId = "downloadData", label = "Download")
                          )
                       ),
                column(width = 5,
                       box(title = "Variance from the Current Fund Split",
                           width = NULL,
                           plotOutput(outputId = "hist")
                           ),
                       box(verbatimTextOutput("summary"), width = NULL)
                       ),
                column(width = 4,
                       box(title = "Budget Impact of Fund Split Implementation",
                           plotOutput(outputId = "bar"), 
                           width = NULL),
                       box(dataTableOutput(outputId = "table"), 
                           width = NULL)
                      )
              )
      )
    )))
