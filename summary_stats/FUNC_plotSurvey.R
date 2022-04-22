library(ggplot2)
library(ggspatial)
library(rworldmap)
library(raster)

plotSurveyData = function(surveyDataPath, plotDir, titleBool, ugaExtent=TRUE){
  
  surveyData = read.csv(surveyDataPath)

  countryPolys = getMap(resolution = "high")
  ugaPoly = countryPolys[countryPolys@data$ADM0_A3=="UGA",]

  lakesPoly = sf::st_read("../figs_paper/host/GLWD-level1/lakes_glwd_1.gpkg")

  dir.create(plotDir, showWarnings = F, recursive = T)

  surveyData$cbsd = as.logical(surveyData$cbsd)
  cbsdStr = surveyData$cbsd
  cbsdStr[cbsdStr==TRUE] = "Presence"
  cbsdStr[cbsdStr==FALSE] = "Absence"

  surveyData = cbind(surveyData, cbsdStr)

  coordinates(surveyData) = ~x+y
  proj4string(surveyData) = proj4string(ugaPoly)

  allYears = sort(unique(surveyData$year))

  cols = c("Presence"="red", "Absence"="green")

  for(thisYear in allYears){
    
    print(thisYear)

    subset_surveyData = surveyData[surveyData$year==thisYear,]
    outPath = file.path(plotDir, paste0(thisYear, "_data.png"))

    legendPosition = "none"
    if(thisYear==2005 & stringr::str_detect(surveyDataPath, "input_generation/surveillance_data/raw_data/survey_data_summary.csv")){
        legendPosition = c(0.83, 0.085)
    }
    
    x = ggplot() + 
        layer_spatial(lakesPoly, fill = "#A1C5FF", size=0.1, alpha=0.5) +
        layer_spatial(countryPolys, fill = "transparent", size=0.3) +
        layer_spatial(subset_surveyData, pch=3, stroke=1, size=2, aes(col=cbsdStr)) + 
        scale_colour_manual(values=cols) + 
        theme(
            axis.text = element_text(size=25),
            legend.text = element_text(size=25),
            title = element_text(size=25),
            legend.position = legendPosition, 
            legend.title=element_blank(), 
            legend.margin=margin(c(0,5,10,5))
        ) + 
        annotation_north_arrow(location="tr") +
        annotation_scale(text_cex=2, height=unit(0.5, "cm"), width_hint=0.3, pad_x = unit(0.5, "cm"), pad_y = unit(0.5, "cm"))

    if(ugaExtent){

      x = x + coord_sf(xlim = c(xmin(ugaPoly), xmax(ugaPoly)), ylim=c(ymin(ugaPoly), ymax(ugaPoly)))

    }

    if(titleBool){

        x = x + ggtitle(paste0(thisYear, " CBSD Survey Data"))

    }
    
    ggsave(outPath, width=8, height=8)
    
  }

}
