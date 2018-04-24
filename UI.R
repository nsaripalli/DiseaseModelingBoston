library(shiny)
library(ggplot2)

dataset <- diamonds

fluidPage(
  
  titlePanel("Boston Disease Model"),
  
  sidebarPanel(
    numericInput('R0', 'R0 (Transmission rate)', value = 1, min = 0),
    numericInput('B-c', 'Average number of contacts the average person has per day', value = 1, min = 0, step = 1),
    numericInput('S', 'Percent of people susceptible', value = .9, min = 0, max = 1),
    numericInput('I', 'People infected (Total)', value = 1, min = 0, step = 1),
    numericInput('numDays', 'Number of Days since Disease start', value = 0, min = 0, step = 1),
    numericInput('y', 'fraction of infected members expected to recover per day', value = 0, min = 0, max = 1)
  ),
  
  mainPanel(
    plotOutput('plot')
  )
)