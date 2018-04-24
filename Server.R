library(shiny)
library(ggplot2)

function(input, output) {
  
  dataset <- reactive({
  })
  
  output$plot <- renderPlot({
    
    require(rgdal)
    library(maptools)
    library(RColorBrewer)
    library(ggmap)
    
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
    
  }, height=700)
  
}

