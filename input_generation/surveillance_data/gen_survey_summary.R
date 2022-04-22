options(stringsAsFactors = F)

genSurveySummary = function(rawSurveyDataPath, summaryOutPath){

    rawSurveyData = read.csv(rawSurveyDataPath)

    col_x = "longitude"
    col_y = "latitude"
    col_year = "year"
    col_cbsd = "cbsd_foliar_incidence"
    col_vector = "adult_whitefly_mean"
    col_dataset = "data_origin"

    dataset_vals = gsub("db", "", rawSurveyData[[col_dataset]])

    surveyDataC = data.frame(
        year=rawSurveyData[[col_year]],
        x=rawSurveyData[[col_x]],
        y=rawSurveyData[[col_y]],
        cbsd=as.numeric(rawSurveyData[[col_cbsd]]>0),
        vector=rawSurveyData[[col_vector]],
        dataset=dataset_vals,
        country="Uganda",
        unqId=NA
    )
    
    # Drop 2004 data as all negatives (pre CBSD inf)
    surveyDataC = surveyDataC[order(surveyDataC$year),]

    summaryDir = dirname(summaryOutPath)
    dir.create(summaryDir, recursive=T, showWarnings=FALSE)
    write.csv(surveyDataC, summaryOutPath, row.names = F)

    return(surveyDataC)

}

getCountryCodesVec = function(
    renamedDf
){

    # Get country codes
    fixMapping = list()
    fixMapping[["Uganda"]] = "UGA"
    fixMapping[["Benin"]] = "BEN"
    fixMapping[["Burkina Faso"]] = "BFA"
    fixMapping[["Cote d'Ivoire"]] = "CIV"
    fixMapping[["DRC"]] = "COD"
    fixMapping[["Ghana"]] = "GHA"
    fixMapping[["Kenya"]] = "KEN"
    fixMapping[["Mozambique"]] = "MOZ"
    fixMapping[["Nigeria"]] = "NGA"
    fixMapping[["Rwanda"]] = "RWA"
    fixMapping[["Tanzania"]] = "TZA"
    fixMapping[["Togo"]] = "TGO"
    fixMapping[["Zambia"]] = "ZMB"
    fixMapping[["Malawi"]] = "MWI"

    fixMapping[["Cameroon"]] = "CMR"
    fixMapping[["Gabon"]] = "GAB"
    fixMapping[["Sierra Leone"]] = "SLE"


    getCode = function(countryVal, fixMapping){
        countryCode = fixMapping[[countryVal]]
        return(countryCode)
    }

    country_code = sapply(renamedDf$country, getCode, fixMapping)

    return(country_code)
}
