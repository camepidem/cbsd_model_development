options(stringsAsFactors = F)
library(raster)

fixHost = function(hostRasterPath, surveyRasterDir, singleFieldVal){
  
  # Read in all total rasters
  totalRasterPaths = list.files(path=surveyRasterDir, pattern="total", full.names = T)
  
  # For each total raster
  for(iRaster in seq_len(length(totalRasterPaths))){
    
    thisRasterPath = totalRasterPaths[iRaster]
    print(thisRasterPath)
    
    # Read in raster
    thisRaster = raster(thisRasterPath)
    
    if(iRaster == 1){
      
      totalRaster = thisRaster
      
    }else{
      
      thisRasterBiggerLoc = thisRaster > totalRaster
      
      totalRaster[thisRasterBiggerLoc] = thisRaster[thisRasterBiggerLoc]
    }
    
  }
  
  
  hostRaster = raster(hostRasterPath)
  hostRaster[is.na(hostRaster)] = 0
  
  minAllowedRaster = totalRaster * singleFieldVal
  
  whichToIncreaseRaster = hostRaster<minAllowedRaster
  
  outRaster = hostRaster
  outRaster[whichToIncreaseRaster] = minAllowedRaster[whichToIncreaseRaster]
  
  outPath = gsub(".tif", "_FIXED.tif", hostRasterPath)
  writeRaster(outRaster, outPath, overwrite=T)
  
}
