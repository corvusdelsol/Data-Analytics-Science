#UI + Server####################################################################
ui = fluidPage(
  titlePanel("US Flight Delays"),
  # User input: number of bins for histogram
  sidebarLayout(
    sidebarPanel(
      #This is a "widget"
      #   The first two arguments are always 
      #      - inputId: A unique character 
      #      - label:  what does the user see as a description?
      checkboxGroupInput("weekday", label = "Day of Week", 
                         choices = list("Sunday" = "1", "Monday" = "2", "Tuesday" = "3",
                                        "Wednesday" = "4", "Thursday" = "5", "Friday" = "6",
                                        "Saturday" = "7"),
                         selected = 1),
      checkboxGroupInput("month", label = "Month", 
                         choices = list("January" = "01", "February" = "02", "March" = "03", "April" = "04",
                                        "May" = "05", "June" = "06", "July" = "07", "August" = "08",
                                        "September" = "09", "October" = "10", "November" = "11", 
                                        "December" = "12"),
                         selected = 1),
      selectInput("year", label = "Year", 
                  choices = list("2019" = "2019", "2021" = "2021"), 
                  selected = 1),
      checkboxGroupInput("carrier", label = "Carrier", 
                         choices = list("Endeavor Air" = "9E", "American Airlines" = "AA", "Alaska Airlines" = "AS",
                                        "Jetblue" = "B6", "Delta" = "DL", "ExpressJet" = "EV", "Frontier" = "F9",
                                        "Allegiant Air" = "G4", "Hawaiian Airlines" = "HA", "Envoy Air" = "MQ",
                                        "Spirit Airlines" = "NK", "Jetstream" = "OH", "Skywest Airlines" = "OO",
                                        "Horizon Air" = "QX", "United Airlines" = "UA", "Southwest Airlines" = "WN",
                                        "Mesa Airlines" = "YV", "Republic Airlines" = "YX"),
                         selected = 1),
      textInput("origin", label = "Origin Airport Code", value = "LAX"),
      textInput("dest", label = "Destination Airport Code", value = "DFW")
    ),
    
    # this directs where to send the user input to
    #  -> Send user input to "main panel" on site
    mainPanel(
      #   outputId: a character used to connect UI input to server output
      plotOutput(outputId = "Plot")
    )
  )
  
)



require(dplyr)
if (!require('shiny')){install.packages("shiny");require(shiny)}

#setwd("C:/Users/rockc/OneDrive/Documents/A&M/2023/Spring 2023/STAT 656/Project/Task 4/Shiny App")
load("shinydata.Rdata")



server = function(input, output) {

dataDep = reactive({ as_tibble(dfNC$DEP_DELAY) %>% filter(dfNC$DAY_OF_WEEK %in% input$weekday,
                                                          dfNC$MONTH %in% input$month,
                                                          dfNC$YEAR %in% input$year,
                                                          dfNC$OP_UNIQUE_CARRIER %in% input$carrier,
                                                          dfNC$ORIGIN %in% input$origin,
                                                          dfNC$DEST %in% input$dest) })

dataArr = reactive({ as_tibble(dfNC$ARR_DELAY_IMP) %>% filter(dfNC$DAY_OF_WEEK %in% input$weekday,
                                                          dfNC$MONTH %in% input$month,
                                                          dfNC$YEAR %in% input$year,
                                                          dfNC$OP_UNIQUE_CARRIER %in% input$carrier,
                                                          dfNC$ORIGIN %in% input$origin,
                                                          dfNC$DEST %in% input$dest) })

  #renderPlot refreshed the display whenever the user input changes
  #   output:  The UI directs the user input to be displayed at "Plot"
  output$Plot = renderPlot({
    par(mfrow=c(1,2)) 
    boxplot(dataDep(),
            ylab="Delay in Minutes",main="Departure Delay Distribution",col="dodgerblue",cex.main=1.5,
            cex.lab=1.3)
    mtext(summary(dataDep())[1],side=1,line=0,cex=1.25)
    mtext(summary(dataDep())[3],side=1,line=1,cex=1.25)
    mtext(summary(dataDep())[4],side=1,line=2,cex=1.25)
    mtext(summary(dataDep())[6],side=1,line=3,cex=1.25)

    boxplot(dataArr(),
            ylab="Delay in Minutes",main="Arrival Delay Distribution",col="dodgerblue",cex.main=1.5,
            cex.lab=1.3)
    mtext(summary(dataArr())[1],side=1,line=0,cex=1.25)
    mtext(summary(dataArr())[3],side=1,line=1,cex=1.25)
    mtext(summary(dataArr())[4],side=1,line=2,cex=1.25)
    mtext(summary(dataArr())[6],side=1,line=3,cex=1.25)
  })
}

shinyApp(ui = ui, server = server)