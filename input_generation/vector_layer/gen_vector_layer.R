options(stringsAsFactors = F)
library(raster)
library(gstat)
library(rworldmap)

genVectorLayer = function(surveyData, outDir, templateRasterPath){

  dir.create(outDir, recursive=T, showWarnings = F)

  cap_pre_idw = 100
  cap_post_idw = 20
  idw_param = 1
  grid_res_reduction = 5
  
  templateExtentRaster = raster(templateRasterPath)
  templateExtent = extent(templateExtentRaster)
  templateResolution = res(templateExtentRaster) * grid_res_reduction
  
  templateRaster = raster(x=templateExtent, resolution=templateResolution)
  templateSpatialPixels = as(templateRaster, "SpatialPixels")
  
  surveyData = surveyData[!is.na(surveyData$vector),]
  coordsDf = surveyData[,c("x", "y")]
  coordinates(coordsDf) = ~x+y
  
  # Cap values above a given mean
  surveyData[surveyData$vector>cap_pre_idw, "vector"] = cap_pre_idw
  
  # Gen IDW raster
  idwOutput = idw(formula =  surveyData$vector~1, locations = coordsDf, newdata = templateSpatialPixels, idp=idw_param)
  idwRaster = raster(idwOutput)
  
  # Normalise
  idwRaster[idwRaster > cap_post_idw] = cap_post_idw
  normRaster = idwRaster / cap_post_idw

  countryPolys = getMap(resolution = "high")
  ugaPoly = countryPolys[countryPolys@data$ADM0_A3=="UGA",]  
  
  normRasterOutPathUga = file.path(outDir, paste0("idw_raster_param_", idw_param, "_data_C.tif"))
  normRasterUga = crop(normRaster, ugaPoly)
  
  writeRaster(normRasterUga, normRasterOutPathUga, overwrite=T)
  
}
