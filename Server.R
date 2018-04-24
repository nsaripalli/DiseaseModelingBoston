library(shiny)
library(ggplot2)

function(input, output) {
  
  dataset <- reactive({
    R0 <- input$R0
    BC <- input$`B-c`
    S <- input$S
    I <- input$I
    numDays <- input$numDays
    y <- input$y
    basic <- input$basic
  })
  
  output$plot <- renderPlot({
    
    require(rgdal)
    library(maptools)
    library(RColorBrewer)
    library(ggmap)
    library(EpiModel)
    
    
    if(input$basic) {
      param <- param.dcm(inf.prob = (input$R0 / input$`B-c`) #this would be where the risk assessment goes
                         , act.rate = 1, rec.rate = input$y,
                         b.rate = 1/3650 #Boston is closish to this number
                         , ds.rate = 1/100, di.rate = 1/80, dr.rate = 1/100)
      init <- init.dcm(s.num = ((input$S) / 673184) #cur pop of Boston
                       , i.num = input$I, r.num = 0)
      control <- control.dcm(type = "SIR", nsteps = input$numDays, dt = 0.5)
      mod <- dcm(param, init, control)
      
      q1 <- par(mar = c(3.2, 3, 2, 1), mgp = c(2, 1, 0), mfrow = c(1, 2))
      q2 <- plot(mod, popfrac = FALSE, alpha = 0.5,
                 lwd = 4, main = "Compartment Sizes")
      q3 <- plot(mod, y = "si.flow", lwd = 4, col = "firebrick",
                 main = "Disease Incidence", legend = "n")
      
      print(q2)
    }
    else {
      area <- readOGR("Tracts_Boston BARI.shp")
      
      
      colors <- brewer.pal(9, "BuGn")
      
      mapImage <- get_map(location=c(left = -71.193799, bottom = 42.15, right = -70.985746, top = 42.5))
      
      area.points <- fortify(area)
      
      p <- ggmap(mapImage) +
        geom_polygon(aes(x = long,
                         y = lat,
                         group = group),
                     data = area.points,
                     color = colors[9],
                     fill = colors[6],
                     alpha = 0.5) +
        labs(x = "Longitude",
             y = "Latitude")
      
      print(p)
    }
    
  }, height=700)
  
}

