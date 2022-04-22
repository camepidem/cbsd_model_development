options(stringsAsFactors = F)
library(raster)
library(rworldmap)
library(rjson)
library(sf)
library(ggplot2)
library(ggspatial)

plotSim = function(managementDfPath, outDir){
  
  managementDf = read.table(managementDfPath, header = T)
  if(nrow(managementDf) == 0){
    return()
  }
  
  # Get jobStr from path
  splitPath = strsplit(managementDfPath, .Platform$file.sep)[[1]]
  jobStr = splitPath[grepl("job", splitPath)]
  
  # Gen real latlong
  long = xMin + managementDf$X*cellsize
  lat = yMax - managementDf$Y*cellsize
  
  cbsd = managementDf$NHostsSurveyDetections > 0
  
  cbsdStr = cbsd
  cbsdStr[cbsdStr==TRUE] = "Presence"
  cbsdStr[cbsdStr==FALSE] = "Absence"
  
  realDf = cbind(
    managementDf,
    long,
    lat,
    cbsd,
    cbsdStr
  )
  
  realDfSpatial = st_as_sf(realDf, coords = c("long", "lat"), crs = st_crs(ugaPoly), agr = "constant")
  
  # Extract sim/survey years
  splitFilename = strsplit(basename(managementDfPath), "_")[[1]]
  thisSimYearStr = splitFilename[6]
  thisSimYear = gsub(".000000.txt", "", thisSimYearStr)
  thisSurveyYear = gsub("_raster_total.asc", "", surveyMapping[[thisSimYear]])
  
  title = paste0(thisSurveyYear, " Simulated CBSD Survey Data")
    
  # Plot
  p = ggplot() +
    layer_spatial(lakesPoly, fill = "#A1C5FF", size=0.1, alpha=0.5) +
    layer_spatial(countryPolys, fill = "transparent", size=0.3) +
    layer_spatial(realDfSpatial, pch=3, stroke=1, size=2, aes(col=cbsdStr)) +
    scale_colour_manual(values=cols) +
    ggtitle(title) +
    coord_sf(xlim = c(xmin(ugaExtent), xmax(ugaExtent)), ylim=c(ymin(ugaExtent), ymax(ugaExtent))) +
    theme(
        axis.text = element_text(size=25),
        legend.text = element_text(size=25),
        title = element_text(size=25),
        legend.position = "none", 
        legend.title=element_blank(), 
        legend.margin=margin(c(0,5,10,5))
    ) + 
    annotation_north_arrow(location="tr") +
    annotation_scale(text_cex=2, height=unit(0.5, "cm"), width_hint=0.3, pad_x = unit(0.5, "cm"), pad_y = unit(0.5, "cm"))
      

  # browser()
#   p

  outFilename = paste0("simulation_", jobStr, "_", thisSurveyYear, ".png")
  outPath = file.path(outDir, outFilename)
  
  ggsave(outPath, width=8, height=8)
  
  # Get path for side by side
  surveyPlotPath = list.files(surveyPlotDir, pattern = thisSurveyYear, full.names = T)
  if(length(surveyPlotPath) != 1){
    stop()
  }
  
  bothFilename = paste0("both_", jobStr, "_", thisSurveyYear, ".png")
  bothOutPath = file.path(outDir, bothFilename)
  
  glueCmd = paste0("convert ", surveyPlotPath, " ", outPath, " +append ", bothOutPath)

  return(glueCmd)

}

# ------------------------------

# Define params
simType = "validation"
modelStr = "model_3"
batchStr = "2022_03_18_batch_0"

batchDir = file.path("../../simulations/", simType, "/sim_output/", modelStr, batchStr)
allJobStr = list.files(batchDir, pattern="8226") # HACK: Remember this looks for this one job only rather than all

countryPolys = st_as_sf(getMap(resolution = "high"))
ugaPoly = countryPolys[countryPolys$ADM0_A3=="UGA",]
ugaExtent = extent(ugaPoly)

lakesPoly = sf::st_read("../host/GLWD-level1/lakes_glwd_1.gpkg")

count = 0
cmdVec = c()
for(jobStr in allJobStr){
  print(jobStr)
  print(count)
  
  jobDir = file.path(batchDir, jobStr)
  outDir = file.path("./plots", simType, modelStr, batchStr)
  
  # -------------------------------
  
  dir.create(outDir, showWarnings = F, recursive = T)
  
  surveyPlotDir = "../../summary_stats/survey_plots/survey_data_C/"
  templateRasterPath = "../../simulations/fitting/inputs/agg_inputs/L_0_INFECTIOUS.txt"
  
  # Gen globals
  surveyMappingPath = "../../simulations/fitting/inputs/agg_inputs/surveyTiming.json"
  surveyMapping = fromJSON(file=surveyMappingPath)
  
  templateRaster = raster(templateRasterPath)
  
  xMin = xmin(templateRaster)
  yMax = ymax(templateRaster)
  cellsize = res(templateRaster)[1]
  
  cols = c("Presence"="red", "Absence"="green")
  
  managementDfPaths = list.files(jobDir, pattern="O_.*_Management_SurveyResults_Time_.*.000000.txt", full.names = T, recursive = T)
  
  for(managementDfPath in managementDfPaths){
    
    print(managementDfPath)
    
    glueCmd = plotSim(
      managementDfPath=managementDfPath, 
      outDir=outDir
    )

    cmdVec = c(cmdVec, glueCmd)
    
  }
  
  count = count + 1
}

readr::write_lines(x=cmdVec, file="glue_cmds.sh")
