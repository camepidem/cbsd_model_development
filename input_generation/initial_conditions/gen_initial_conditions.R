options(stringsAsFactors = F)
library(raster)

genInitialConditions = function(surveyRasterPath, hostRasterPath, outDir, singleFieldVal){
  
  dir.create(outDir, recursive = T, showWarnings = F)
  
  surveyRaster = raster(surveyRasterPath)
  surveyRaster[is.na(surveyRaster)] = 0

  hostRaster = raster(hostRasterPath)
  hostRaster[is.na(hostRaster)] = 0
    
  # This is the proportion of an entire cell area that is infected
  infAreaRaster = surveyRaster * singleFieldVal

  # Divide by Host raster to get the proportion of the host area that is infected
  infRaster = infAreaRaster / hostRaster
  infRaster[is.na(infRaster)] = 0

  # Calc sus raster
  susRaster = 1 - infRaster

  # Generate empty removed raster
  remRaster = infRaster * 0
  
  infRasterPath = file.path(outDir, "inf_raster.tif")
  susRasterPath = file.path(outDir, "sus_raster.tif")
  remRasterPath = file.path(outDir, "rem_raster.tif")

  writeRaster(infRaster, infRasterPath, overwrite=T)
  writeRaster(susRaster, susRasterPath, overwrite=T)
  writeRaster(remRaster, remRasterPath, overwrite=T)

}
