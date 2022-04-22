dropIncompleteSims = function(
    resPath,
    resFixedOutPath,
    maxSurveyDataYear,
    statsMergedDfPath,
    completeStatsDfPath
){

    targetStatsDf = read.csv(statsMergedDfPath) |> 
        dplyr::filter(surveyDataYear<=maxSurveyDataYear)

    targetPolyNames = targetStatsDf$polyName

    resultsSummaryDf = readRDS(resPath)

    resultsSummarySimList = split(resultsSummaryDf, resultsSummaryDf$simKey)

    # Check all required target polys are present
    simsCompleteStats = function(
        thisResultsDf,
        targetPolyNames
    ){
        
        thisResultsPolyNames = thisResultsDf$polyName
        
        polyNamesPresentBoolVec = targetPolyNames %in% thisResultsPolyNames
        allPolyNamesPresentBool = all(polyNamesPresentBoolVec)

        numPolysMissing = sum(!polyNamesPresentBoolVec)
        
        numNas = sum(is.na(thisResultsDf))
        noNaBool = numNas==0
        
        simKey = thisResultsDf[1, "simKey"]
        
        return(
            data.frame(
                simKey,
                allPolyNamesPresentBool,
                noNaBool,
                numPolysMissing,
                numNas,
                completeBool=allPolyNamesPresentBool&noNaBool
            )
        )
        
    }

    completeStatsList = lapply(resultsSummarySimList, simsCompleteStats, targetPolyNames)
    completeStatsDf = dplyr::bind_rows(completeStatsList)

    brokenDf = completeStatsDf[!completeStatsDf$completeBool,]

    numDropping = nrow(brokenDf)

    print("Dropping:")
    print(numDropping)

    resultsSummaryDfFixed = resultsSummaryDf[!(resultsSummaryDf$simKey %in% brokenDf$simKey),]

    saveRDS(resultsSummaryDfFixed, resFixedOutPath)

    # Write out
    write.csv(completeStatsDf, completeStatsDfPath, row.names=FALSE)

}
