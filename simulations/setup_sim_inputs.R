options(stringsAsFactors = F)
library(rworldmap)
library(raster)
library(rjson)

cropBool = TRUE

cropSurveyRasters = 1
cropMiscRasters = 1
cropInitial = 1
genTimingJson = 1
simDir = "fitting/inputs"
dataKey = "survey_data_C"

countryPolys = getMap(resolution = "high")
ugaPoly = countryPolys[countryPolys@data$ADM0_A3=="UGA",]  
cropExtent = extent(ugaPoly)

# -----------------------------
# Setup
aggDir = file.path(simDir, "agg_inputs")
dir.create(aggDir, recursive = T, showWarnings = F)

# -----------------------------
# Survey rasters and stats
if(cropSurveyRasters){
  
  source("FUNC_crop_rasters_gen_index.R")
  
  # This generates indexes for every mask for every survey year
  # If there are no surveys in the mask in that year, it writes out a file with 
  # nrow = 0 i.e. just the header
  outPathListC = cropRastersAndGenIndexDf(
    cropBool=cropBool,
    cropExtent=cropExtent,
    simDir=simDir,
    dataKey=dataKey
  )
  
  aggSurveyPaths = file.path(aggDir, basename(outPathListC))

  file.copy(outPathListC, aggSurveyPaths)
  
}

# -----------------------------
# Host and vector raster

cropRaster = function(inPath, outPath, cropExtent, cropBool){
  
  rawRaster = raster(inPath)

  if(cropBool){
    cropRaster = crop(rawRaster, cropExtent)
  }else{
    cropRaster = rawRaster
  }
  
  writeRaster(cropRaster, outPath, overwrite=T)
  
}

if(cropMiscRasters){
  
  vectorInPath = "../input_generation/vector_layer/vector_layer_data_C/idw_raster_param_1_data_C.tif"
  vectorOutPath = file.path(aggDir, "vector_abundance_layer.asc")
  
  cropRaster(
    inPath=vectorInPath, 
    outPath=vectorOutPath, 
    cropExtent=cropExtent,
    cropBool=cropBool
  )

  controlInPath = "../input_generation/control_raster/outputs/control_raster.asc"
  controlOutPath = file.path(aggDir, "control_raster.asc")
  
  cropRaster(
    inPath=controlInPath, 
    outPath=controlOutPath, 
    cropExtent=cropExtent,
    cropBool=cropBool
  )
  
  hostInPath = "../input_generation/host_landscape/norm_host/CassavaMap_Prod_v1_NORMALISED_FIXED.tif"
  hostOutPath = file.path(aggDir, "L_0_HOSTDENSITY.asc")
  
  cropRaster(
    inPath=hostInPath, 
    outPath=hostOutPath, 
    cropExtent=cropExtent,
    cropBool=cropBool
  )
  
  file.rename(hostOutPath, gsub(".asc", ".txt", hostOutPath))
  
  ## Vector config file
  vectorConfigPath = file.path(aggDir, "P_WeatherSwitchTimes.txt")
  vectorConfigStr = c("Time Targets Files", paste0("0 [0_INFECTIOUSNESS 0_SUSCEPTIBILITY] ", basename(vectorOutPath)))
  
  fileConn = file(vectorConfigPath)
  writeLines(vectorConfigStr, fileConn)
  close(fileConn)
  
}

# -----------------------------
# Initial conditions

if(cropInitial){

    infInPath = "../input_generation/initial_conditions/inf_raster.tif"
    infOutPath = file.path(aggDir, "L_0_INFECTIOUS.asc")
  
    cropRaster(
      inPath=infInPath, 
      outPath=infOutPath, 
      cropExtent=cropExtent,
      cropBool=cropBool
    )

  file.rename(infOutPath, gsub(".asc", ".txt", infOutPath))

  susInPath = "../input_generation/initial_conditions/sus_raster.tif"
  susOutPath = file.path(aggDir, "L_0_SUSCEPTIBLE.asc")
  
  cropRaster(
    inPath=susInPath, 
    outPath=susOutPath, 
    cropExtent=cropExtent,
    cropBool=cropBool
  )

  file.rename(susOutPath, gsub(".asc", ".txt", susOutPath))

  remInPath = "../input_generation/initial_conditions/rem_raster.tif"
  remOutPath = file.path(aggDir, "L_0_REMOVED.asc")

  cropRaster(
    inPath=remInPath, 
    outPath=remOutPath, 
    cropExtent=cropExtent,
    cropBool=cropBool
  )

  file.rename(remOutPath, gsub(".asc", ".txt", remOutPath))

}

# --------------------------------

if(genTimingJson){
  
  offset = 1
  
  totalRasters = list.files(file.path(aggDir), pattern = "total")
  
  realYears = as.character(as.numeric(gsub("_raster_total.asc", "", totalRasters)) + offset)
  
  jsonList = list()
  
  for(i in seq_len(length(realYears))){
    
    jsonList[[realYears[i]]] = totalRasters[i]
    
  }
  
  jsonOutStr = toJSON(jsonList)
  
  surveyTimingOutPath = file.path(aggDir, "surveyTiming.json")
  
  fileConn = file(surveyTimingOutPath)
  writeLines(jsonOutStr, fileConn)
  close(fileConn)
  
}
