library(raster)
library(rjson)
library(dplyr)

convertToLatLong = function(dataDir, hostRasterPath, surveyMappingPath, artificalSurveyOutPath){
  
  ugaPoly = sf::st_as_sf(raster::getData('GADM', country='UGA', level=0))
    
  hostRaster = raster(hostRasterPath)
  surveyMapping = fromJSON(file=surveyMappingPath)
  
  managementPaths = list.files(dataDir, "O_0_*Management", full.names = T)
  
  surveyDataList = list()
  for(thisManagementPath in managementPaths){
    
    thisManagementFilename = basename(thisManagementPath)
    splitFilename = strsplit(thisManagementFilename, "_")[[1]]
    simYear = as.numeric(gsub(".txt", "", splitFilename[length(splitFilename)]))
    
    surveyRasterName = surveyMapping[[as.character(simYear)]]
    surveyYear = as.numeric(gsub("_raster_total.asc", "", surveyRasterName))
    
    thisManagementDf = read.csv(thisManagementPath, sep="\t")
    
    fixedX = xmin(hostRaster) + thisManagementDf$X * res(hostRaster)[1]
    fixedY = ymax(hostRaster) - thisManagementDf$Y * res(hostRaster)[2]
    
    thisSurveyDf = data.frame(
      year=surveyYear,
      simYear=simYear,
      x=fixedX,
      y=fixedY,
      cbsd=as.numeric(thisManagementDf$NHostsSurveyDetections>0)
    )
    
    # Drop any points outside UGA
    thisSurveyDfSf = sf::st_as_sf(thisSurveyDf, coords=c("x", "y"), remove=FALSE, crs="WGS84")
    
    intersectList = sf::st_intersects(thisSurveyDfSf, ugaPoly)
    
    intersectBool = as.numeric(intersectList) > 0
    intersectBool[is.na(intersectBool)] = FALSE
    
    thisSurveyDfOut = thisSurveyDf[intersectBool,]
    
    surveyDataList[[thisManagementPath]] = thisSurveyDfOut
    
  }
  
  surveyDataOut = bind_rows(surveyDataList)
  write.csv(surveyDataOut, artificalSurveyOutPath, row.names = F)
  
}
