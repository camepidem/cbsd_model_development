paramSet = "params_2"

artificialSimDir = file.path("../simulations/artificial/sim_output/model_2/", paramSet)

hostRasterPath = "../simulations/fitting/inputs/agg_inputs/L_0_HOSTDENSITY.txt"
surveyMappingPath = "../simulations/fitting/inputs/agg_inputs/surveyTiming.json"

outDir = "artificial_survey"

dir.create(outDir, showWarnings = F, recursive = T)

source("FUNC_convertToLatLong.R")

jobDirs = list.files(artificialSimDir, "job", full.names = T)

for(thisJobDir in jobDirs){
  
  print(thisJobDir)
  
  thisJobName = basename(thisJobDir)
  
  managementDataDir = file.path(thisJobDir, "output/runfolder0")
  
  artificalSurveyOutPath = file.path(outDir, paste0(paramSet, "_", thisJobName, "_artificial_survey.csv"))
  
  convertToLatLong(
    dataDir=managementDataDir, 
    hostRasterPath=hostRasterPath, 
    surveyMappingPath=surveyMappingPath, 
    artificalSurveyOutPath=artificalSurveyOutPath
  )
  
}
