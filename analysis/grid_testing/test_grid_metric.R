box::use(../utils/utils_grid)
box::reload(new_grid_func)

resultsDfTarget = read.csv("./test_sim_output.csv")
surveyStatsDf = read.csv("./test_grid_stats.csv")

maxFittingSurveyDataYear = 2010

# Extract unique simKeys
simKeys = sort(unique(resultsDfTarget$simKey))

criteriaCols = c(
    "exact_match_bool",
    "tol_applied_only_where_both_bool",
    "tol_applied_all_except_final_bool",
    "tol_applied_all_bool"
)

rowList = list()

allTrueRowList = list()
allFalseRowList = list()
mixRowList = list()
for(thisSimKey in simKeys){

    print(thisSimKey)

    resultsDfSim = resultsDfTarget[resultsDfTarget$simKey==thisSimKey,]

    # Extract unique grid names
    polySuffixAll = unique(resultsDfSim$polySuffix)
    polySuffixGrid = stringr::str_subset(polySuffixAll, "grid")

    for(thisGrid in polySuffixGrid){
            
        # Isolate corresponding results for this sim / grid
        resultsDfSubset = resultsDfSim[resultsDfSim$polySuffix==thisGrid,]
        
        # Extract real survey grid stats
        surveyStatsDfSubset = surveyStatsDf[surveyStatsDf$polySuffix==thisGrid,]
        
        # ----------------------------------------
        
        thisRow = utils_grid$calcGridPassCriteria(
            thisSimKey=thisSimKey,
            thisGrid=thisGrid,
            resultsDfSubset=resultsDfSubset,
            surveyStatsDfSubset=surveyStatsDfSubset,
            maxFittingSurveyDataYear=maxFittingSurveyDataYear
        )
        
        listKey = paste0(thisSimKey, "_", thisGrid)
        rowList[[listKey]] = thisRow

        rowSubset = thisRow[,criteriaCols]
        numTrue = rowSums(rowSubset)

        if(numTrue==4){
            allTrueRowList[[listKey]] = thisRow
        }else if(numTrue==0){
            allFalseRowList[[listKey]] = thisRow
        }else{
            mixRowList[[listKey]] = thisRow
        }
        
    }
    
}

allDf = dplyr::bind_rows(rowList)

allTrueDf = dplyr::bind_rows(allTrueRowList)
allFalseDf = dplyr::bind_rows(allFalseRowList)
mixDf = dplyr::bind_rows(mixRowList)

# ----------------------
# Does the allDf match the known test results?
testResultsList = list()
for(iRow in seq_len(nrow(allDf))){
    
    thisTestRow = allDf[iRow,]
    
    thisTargetRow = resultsDfTarget[resultsDfTarget$simKey==thisTestRow$simKey & resultsDfTarget$polySuffix==thisTestRow$polySuffix,]
    
    stopifnot(nrow(thisTargetRow)==1)
    
    exact_match_bool_pass = thisTestRow$exact_match_bool == thisTargetRow$exact_match_bool
    tol_applied_only_where_both_bool_pass = thisTestRow$tol_applied_only_where_both_bool == thisTargetRow$tol_applied_only_where_both_bool
    tol_applied_all_except_final_bool_pass = thisTestRow$tol_applied_all_except_final_bool == thisTargetRow$tol_applied_all_except_final_bool
    tol_applied_all_bool_pass = thisTestRow$tol_applied_all_bool == thisTargetRow$tol_applied_all_bool
    
    pass_all = all(
        exact_match_bool_pass,
        tol_applied_only_where_both_bool_pass,
        tol_applied_all_except_final_bool_pass,
        tol_applied_all_bool_pass
    )
    
    thisTestResultRow = data.frame(
        simKey=thisTestRow$simKey,
        polySuffix=thisTestRow$polySuffix,
        exact_match_bool_pass,
        tol_applied_only_where_both_bool_pass,
        tol_applied_all_except_final_bool_pass,
        tol_applied_all_bool_pass,
        pass_all
    )
    
    testResultsList[[as.character(iRow)]] = thisTestResultRow
    
}

testResultsDf = dplyr::bind_rows(testResultsList)

stopifnot(all(testResultsDf$pass_all))
