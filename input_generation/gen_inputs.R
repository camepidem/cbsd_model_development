options(stringsAsFactors = F)

# Core functions
genHost = TRUE
genSurvey = TRUE
genVector = TRUE
fixHost = TRUE
genInitial = TRUE

# Diagnostics
genSurveyPlots = TRUE

# Constants
singleFieldVal = 1/1000

# -----------------------------------
# Host landscape

rawProdRasterPath = "host_landscape/raw_host/CassavaMap_Prod_v1.tif"

fieldsRasterName = gsub(".tif", "_FIELDS.tif", basename(rawProdRasterPath))
fieldsHostRasterPath = file.path("host_landscape/fields_host", fieldsRasterName)

normRasterName = gsub(".tif", "_NORMALISED.tif", basename(rawProdRasterPath))
normHostRasterPath = file.path("host_landscape/norm_host", normRasterName)


# Process host landscape from raw production file (from paper) into number of fields + then normalised version
if(genHost){

  source("host_landscape/gen_normalised_host_landscape.R")

  genHostLandscape(
    rawProdRasterPath=rawProdRasterPath,
    outRasterPathFields=fieldsHostRasterPath,
    outRasterPathNorm=normHostRasterPath
  )

}

# -----------------------------------
# Surveillance data
rawSurveyDataPath = "surveillance_data/raw_data/uga_paper_DATASET_C.csv"
surveyDataCOutPath = "surveillance_data/raw_data/survey_data_summary.csv"

outDirC = "surveillance_data/survey_rasters/survey_data_C"

if(genSurvey){

  # Gen summary of Uganda data paper to field level
  source("surveillance_data/gen_survey_summary.R")

  surveyDataC = genSurveySummary(
    rawSurveyDataPath=rawSurveyDataPath,
    summaryOutPath=surveyDataCOutPath
  ) |> dplyr::mutate(countryCode="UGA")

  write.csv(surveyDataC, surveyDataCOutPath, row.names=FALSE)
  
  # Gen survey rasters
  source("surveillance_data/gen_survey_rasters.R")
  
  genSurveyRasters(
    surveyData=surveyDataC,
    outDir=outDirC,
    templateRasterPath=rawProdRasterPath
  )

}

# -----------------------------------
# Vector abundance layer

outDirC = "vector_layer/vector_layer_data_C/"

if(genVector){

  source("vector_layer/gen_vector_layer.R")

  surveyDataC = read.csv(surveyDataCOutPath)

  genVectorLayer(
    surveyData=surveyDataC, 
    outDir=outDirC,
    templateRasterPath=rawProdRasterPath
  )

}

# ------------------------------------
# Fix host - add in fields where surveys occur if necessary
surveyRasterDir = "surveillance_data/survey_rasters/survey_data_C"

if(fixHost){

  source("host_landscape/fix_host_survey_locations.R")

  fixHost(
    hostRasterPath=normHostRasterPath, 
    surveyRasterDir=surveyRasterDir,
    singleFieldVal=singleFieldVal
  )


}

# ------------------------------------
# Generate initial conditions
surveyRasterPathInitial = "surveillance_data/survey_rasters/survey_data_C/2005_raster_pos.tif"
hostRasterPathFixed = "host_landscape/norm_host/CassavaMap_Prod_v1_NORMALISED_FIXED.tif"
outDirInitial = "initial_conditions"

if(genInitial){
  
  source("initial_conditions/gen_initial_conditions.R")

  genInitialConditions(
    surveyRasterPath=surveyRasterPathInitial,
    hostRasterPath=hostRasterPathFixed,
    outDir=outDirInitial,
    singleFieldVal=singleFieldVal
  )
  
}

# ------------------------------------
# DIAGNOSTICS
# ------------------------------------
# Survey plots
if(genSurveyPlots){

  source("surveillance_data/plot_survey_data.R")

  surveyDataC = read.csv(surveyDataCOutPath)

  plotDirC = "surveillance_data/plots/data_C"

  plotSurveyData(
    surveyDataC=surveyDataC, 
    plotDirC=plotDirC
  )

}
