options(stringsAsFactors = F)
library(raster)
library(dplyr)
library(rworldmap)

extractIndex = function(thisRaster){
  
  zeroExtent = extent(0, xmax(thisRaster)-xmin(thisRaster), 0, ymax(thisRaster)-ymin(thisRaster))
  
  extent(thisRaster) = zeroExtent
  
  rasterIndexes = which(thisRaster[]>0)
  numRealSurveysInCell = thisRaster[rasterIndexes]
  
  indexDf = as.data.frame(rowColFromCell(thisRaster, rasterIndexes))
  indexDf = indexDf %>% rename("X"="col", "Y"="row")
  indexDf = cbind(indexDf, numRealSurveysInCell)
  
  # Correct offset
  indexDf$X = indexDf$X - 1
  indexDf$Y = indexDf$Y - 1
  
  return(indexDf)
  
}

cropRastersAndGenIndexDf = function(
  cropBool,
  cropExtent, 
  simDir, 
  dataKey,
  startYear=NULL
  ){
  
  surveyRasterDir = file.path("../input_generation/surveillance_data/survey_rasters", dataKey)
  outDir = file.path(simDir, dataKey)
  
  outRasterDir = file.path(outDir, "rasters")
  outIndexDir = file.path(outDir, "index")

  dir.create(outRasterDir, recursive = T, showWarnings = F)
  dir.create(outIndexDir, recursive = T, showWarnings = F)
  
  totalRasterPaths = list.files(surveyRasterDir, pattern="total", full.names=T)
  polygonPaths = list.files("../summary_stats/mask_polys/", full.names=T)
  statsPaths = list.files(file.path("../summary_stats/mask_stats/", dataKey), full.names=T)

  outPathList = c()
  
  for(thisTotalRasterPath in totalRasterPaths){
    
    year = as.numeric(strsplit(basename(thisTotalRasterPath), "_")[[1]][[1]])
    
    if(!is.null(startYear) && year < startYear){
      next
    }
      
    thisRaster = raster(thisTotalRasterPath)

    if(cropBool){
      thisRasterCropped = crop(thisRaster, cropExtent)
    }else{
      thisRasterCropped = thisRaster
    }
    
    fixRasterName = gsub(".tif", ".asc", basename(thisTotalRasterPath))
    outRasterPath = file.path(outRasterDir, fixRasterName)
    
    print(outRasterPath)
    outPathList = c(outPathList, outRasterPath)
    
    writeRaster(thisRasterCropped, outRasterPath, overwrite=T)

    # ----------------------------

    thisRasterYear = gsub("_raster_total.tif", "", basename(thisTotalRasterPath))
    
    # For each mask
    for(thisPolygonPath in polygonPaths){

      print(thisPolygonPath)

      thisPolygonName = basename(thisPolygonPath)
      thisPolygonStr = gsub(".rds", "", thisPolygonName)

      # Only generate index for polygons with any surveys in them i.e. a stats file exists
      if(any(stringr::str_detect(statsPaths, thisPolygonStr))){

        thisPolygon = readRDS(thisPolygonPath)

        thisPolyRaster = mask(thisRasterCropped, thisPolygon, updateValue=0)
        thisPolyIndexDf = extractIndex(thisPolyRaster)

        outPolyIndexPath = file.path(outIndexDir, paste0(thisRasterYear, "_", thisPolygonStr, ".csv"))
        write.csv(thisPolyIndexDf, outPolyIndexPath, row.names = F)
        
      }

    }
    
  }
  
  dataStr = paste0("Data: ", dataKey)
  extentStr = paste0("Extent: ", paste(as.character(cropExtent), collapse = ", "))
  extentLogPath = file.path(outDir, "extent_log.txt")
  fileConn = file(extentLogPath)
  writeLines(c(dataStr, extentStr), fileConn)
  close(fileConn)

  return(outPathList)
    
}
