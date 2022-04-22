library(ggplot2)

surveyDataRaw = read.csv("../surveillance_data/raw_data/uga_paper_DATASET_C.csv")

# Extract data from verified subset A
surveyDataA = surveyDataRaw[surveyDataRaw$data_origin == "dbA",]

# Identify years where records non-dominant var records were taken
cbsdInOtherVars = surveyDataA$cbsd_in_other_varieties
years = unique(surveyDataA[!is.na(cbsdInOtherVars) & cbsdInOtherVars != "", "year"])

# Extract these years
surveyData = surveyDataA[surveyDataA$year %in% years,]

# Read in manual classification of CBSD negative keys
classifyDf = read.csv("classifyDf.csv")
negKeys = classifyDf$otherVarKey[!is.na(classifyDf$noDiseaseBool)]

# Build boolean cols for disease presence/absence
otherVarKeys = surveyData$cbsd_in_other_varieties
negKeysBool = otherVarKeys %in% negKeys | otherVarKeys == ""

cbsdDomBool = surveyData$cbsd_foliar_incidence > 0
cbsdOtherVarBool = !negKeysBool
cbsdAnyVarBool = cbsdDomBool | cbsdOtherVarBool

surveyDataBool = cbind(
  surveyData,
  cbsdDomBool,
  cbsdOtherVarBool,
  cbsdAnyVarBool
)

# Calc yearly error rate
calcPropNew = function(surveyData){
  prop = 1 - sum(surveyData$cbsdDomBool) / sum(surveyData$cbsdAnyVarBool)
  return(prop)
}

propYearVecNew = c()
for(year in years){
  
  thisDfNew = surveyDataBool[surveyData$year==year,]
  propYearVecNew = c(propYearVecNew, calcPropNew(thisDfNew))
  
}

outDf = data.frame(
  years=years,
  propYearVecNew=propYearVecNew
)

p = ggplot(outDf, aes(years, propYearVecNew)) + 
  geom_line() + 
  geom_point(size=2) + 
  xlab("Survey year") +
  ylab("False negative rate") +
  ylim(0, 0.4)

cowplot::save_plot("survey_error.png", p, base_asp=1.2)
