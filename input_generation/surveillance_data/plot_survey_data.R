options(stringsAsFactors = F)
library(ggplot2)
library(ggspatial)
library(rworldmap)
library(raster)

plotSurveyData = function(surveyDataC, plotDirC){

  countryPolys = getMap(resolution = "high")
  ugaPoly = countryPolys[countryPolys@data$ADM0_A3=="UGA",]

  dir.create(plotDirC, showWarnings = F, recursive = T)

  surveyDataC$cbsd = as.logical(surveyDataC$cbsd)
  coordinates(surveyDataC) = ~x+y
  proj4string(surveyDataC) = proj4string(ugaPoly)

  allYears = sort(unique(surveyDataC$year))

  cols = c("TRUE"="red", "FALSE"="green")

  plotMap = function(thisSurveySubset, outPath, year){
    
    ggplot() + 
      layer_spatial(ugaPoly, fill = "transparent") +
      layer_spatial(thisSurveySubset, pch=3, stroke=1, size=2, aes(col=cbsd)) + 
      scale_colour_manual(values=cols) + 
      ggtitle(thisYear) + 
      theme(legend.position="none")
    
    ggsave(outPath)
  }

  for(thisYear in allYears){
    
    print(thisYear)

    subset_surveyDataC = surveyDataC[surveyDataC$year==thisYear,]
    outPath = file.path(plotDirC, paste0(thisYear, "_data_C.png"))
    plotMap(subset_surveyDataC, outPath, thisYear)
    
  }

}






