doRealData = 0
doArtificialData = 1

surveyDataList = list()

outTopDir = "mask_stats"
plotTopDir = "survey_plots"

if(doRealData){
  
  target_data_key = "survey_data_C"
  surveyDataList[[target_data_key]][["surveyDataPath"]] = "../input_generation/surveillance_data/raw_data/survey_data_summary.csv"
  surveyDataList[[target_data_key]][["outDir"]] = file.path(outTopDir, target_data_key)
  surveyDataList[[target_data_key]][["plotDir"]] = file.path(plotTopDir, target_data_key)
  surveyDataList[[target_data_key]][["titleBool"]] = TRUE

}


if(doArtificialData){
  
  artificialSurveyDataDir = "../artificial/artificial_survey/"
  
  artificialSurveyDataFiles = list.files(artificialSurveyDataDir)
  for(thisArtificialSurveyDataFile in artificialSurveyDataFiles){
    
    thisSurveyKey = gsub(".csv", "", thisArtificialSurveyDataFile)
    
    surveyDataList[[thisSurveyKey]] = list()
    surveyDataList[[thisSurveyKey]][["surveyDataPath"]] = file.path(artificialSurveyDataDir, thisArtificialSurveyDataFile)
    surveyDataList[[thisSurveyKey]][["outDir"]] = file.path(outTopDir, thisSurveyKey)
    surveyDataList[[thisSurveyKey]][["plotDir"]] = file.path(plotTopDir, thisSurveyKey)
    surveyDataList[[thisSurveyKey]][["titleBool"]] = FALSE
    
  }
  
  
}

# ----------------------------

source("FUNC_gen_survey_poly_stats.R")
source("FUNC_plotSurvey.R")
source("FUNC_gen_stats_grid.R")
source("FUNC_merge_stats.R")

for(thisSurveyKey in names(surveyDataList)){

  print(thisSurveyKey)

  surveyDataPath = surveyDataList[[thisSurveyKey]][["surveyDataPath"]]
  outDir = surveyDataList[[thisSurveyKey]][["outDir"]]
  plotDir = surveyDataList[[thisSurveyKey]][["plotDir"]]
  titleBool = surveyDataList[[thisSurveyKey]][["titleBool"]]

  genSurveyPolyStats(
    surveyDataPath=surveyDataPath,
    outDir=outDir
  )

  plotSurveyData(
    surveyDataPath=surveyDataPath,
    plotDir=plotDir,
    titleBool=titleBool
  )

  genGridStats(
    topDir=outDir
  )

  mergeMaskStats(
    maskDir=outDir
  )
  
}


