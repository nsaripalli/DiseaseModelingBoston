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
    library(deSolve)
    library(EpiModel)
    
    
    if(input$basic) {
      param <- param.dcm(inf.prob = (input$R0 / input$`B-c`) #this would be where the risk assessment goes
                         , act.rate = 1, rec.rate = input$y,
                         b.rate = 1/3650 #Boston is closish to this number
                         , ds.rate = 1/100, di.rate = 1/80, dr.rate = 1/100)
      init <- init.dcm(s.num = ((input$S) * 673184) #cur pop of Boston
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

      calcFinalInf <- function(POP) {
        param <- param.dcm(inf.prob = (input$R0 / input$`B-c`) #this would be where the risk assessment goes
                           , act.rate = 1, rec.rate = input$y,
                           b.rate = 1/3650 #Boston is closish to this number
                           , ds.rate = 1/100, di.rate = 1/80, dr.rate = 1/100)
        init <- init.dcm(s.num = ((input$S) * POP * 100)
                         , i.num = input$I, r.num = 0)
        control <- control.dcm(type = "SIR", nsteps = input$numDays, dt = 0.5)
        
        mod <- dcm(param, init, control)
        x <- tail(mod$epi$i.num$run1, n=1)
        x <- ceiling(x)
        return(x)
      }
      
      area$inf <- area$POP100
      area$inf <- sapply(area$inf, calcFinalInf)
    
      library(plyr)      # for join(...)
      library(rgdal)     # for readOGR(...)
      library(ggplot2)   # for fortify(...)
      
      area@data$id = rownames(area@data)
      
      area.points = fortify(area)
      area.points = join(area.points, area@data, by="id")      
      
      colors <- brewer.pal(9, "BuGn")
      
      mapImage <- get_map(location=c(left = -71.193799, bottom = 42.15, right = -70.985746, top = 42.5))
      
      colors <- brewer.pal(9, "BuGn")
      
      mapImage <- get_map(location=c(left = -71.193799, bottom = 42.15, right = -70.985746, top = 42.5))
      
      
      
      p <- ggmap(mapImage) + geom_polygon(data = area.points, aes(x = long,
                                                                  y = lat,
                                                                  group = group,
                                                                  fill = inf),
                                          color = "black") +
        labs(x = "Longitude",
             y = "Latitude")
      
      print(p)
    }
    
  }, height=700)
  
}