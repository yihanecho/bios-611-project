library(dplyr)
library(treemapify)
library(ggplot2)
library(shiny)
select <- dplyr::select

OCC.NAICS <- read_csv("./derived_data/Salary_US_major_group.csv")


# Define Treemap function==================================================

make.treemap <- function(NAICS_CODE, min=0, max=200,
                         title = "", legtitle = "Mean Hourly Wage") {
  dum <- OCC.NAICS %>%
    filter(NAICS==NAICS_CODE) %>%
    filter(min <= H_MEAN & H_MEAN <= max) %>%
    arrange(desc(H_MEAN))

  ggplot(dum, aes(area = TOT_EMP, fill = H_MEAN, subgroup = OCC_TITLE)) +
    geom_treemap() +
    geom_treemap_subgroup_border(color = "black") +
    geom_treemap_subgroup_text(place = "centre", grow = T, alpha = 0.5,
                               colour = "white", fontface = "italic",
                               min.size = 2,
                               padding.x = grid::unit(2, "mm"),
                               padding.y = grid::unit(2, "mm")) +
    labs(title = title, fill = legtitle)
}

# Define ui and server ====================================================

ui <- fluidPage(

  titlePanel(
    h3("Salary and Employment in US by NAICS sector"),
    br()),

  sidebarLayout(

    sidebarPanel(

      selectInput("code",
                  label = "Choose a Industry (NAICS Code)",
                  choices = c("11", "21", "22", "23",
                              "31-33", "42", "44-45",
                              "48-49", "51", "52", "53",
                              "54", "55", "56", "61",
                              "62", "71", "72", "81", "99")
      ),
      sliderInput("range",
                  label = "Range of interest:",
                  min = 0, max = 100, value = c(0, 100)),

      tags$div(
        tags$a(href= "https://www.bls.gov/oes/special.requests/oesm20all.zip",
               "Source Data"),
        tags$p("from U.S. BUREAU OF LABOR STATISTICS")),
      br(), br(), br(),


      p('11  -  Agriculture, Forestry, Fishing and Hunting'),
      p('21  -  Mining, Quarrying, and Oil and Gas Extraction'),
      p('22  -  Utilities'),
      p('23  -  Construction'),
      p('31-33  -  Manufacturing'),
      p('42  -  Wholesale Trade'),
      p('44-45  -  Retail Trade'),
      p('48-49  -  Transportation and Warehousing'),
      p('51  -  Information'),
      p('52  -  Finance and Insurance'),
      p('53  -  Real Estate and Rental and Leasing'),
      p('54  -  Professional, Scientific, and Technical Services'),
      p('55  -  Management of Companies and Enterprises'),
      p('56  -  Administrative and Support
      and Waste Management and Remediation Services'),
      p('61  -  Educational Services'),
      p('62  -  Health Care and Social Assistance'),
      p('71  -  Arts, Entertainment, and Recreation'),
      p('72  -  Accommodation and Food Services'),
      p('81  -  Other Services (except Public Administration)'),
      p('99  -  Federal, State, and Local Government')
    ),

    mainPanel(
      h1(textOutput("codeval")),
      br(),

      h4("The treemap below shows the total employment and mean hourly wage across different occupations (categorized by the Standard Occupational Classification System) within a selected sector (categorized by the North American Industry Classification System)"),
      h4("Each rectangle has size proportional to the total employment and color lightness related to the mean hourly wage"),

      plotOutput("treemap"),

      br(),
      br(),

      h3("Summary Table"),
      dataTableOutput("outtb")
    )
  )
)

server <- function(input, output) {
  output$treemap <- renderPlot({
    make.treemap(input$code, input$range[1], input$range[2])
  })

  output$codeval <- renderText({
    OCC.NAICS %>% filter(NAICS == input$code) %>% distinct(NAICS_TITLE) %>% pull()
  })

  output$outtb <- renderDataTable({
    OCC.NAICS %>%
      filter(NAICS == input$code) %>%
      filter(input$range[1] <= H_MEAN & H_MEAN <= input$range[2]) %>%
      arrange(desc(H_MEAN)) %>%
      select(OCC_CODE, OCC_TITLE, TOT_EMP, EMP_PRSE, H_MEAN, A_MEAN) %>%
      rename(SOC_Code = OCC_CODE,
             SOC = OCC_TITLE,
             Employment = TOT_EMP,
             Employment_PrSE = EMP_PRSE,
             Mean_Hourly_Wage = H_MEAN,
             Mean_Annual_Wage = A_MEAN)
  }, options = list(pageLength = 5))
}

# Run shiny app
shinyApp(ui = ui, server = server)