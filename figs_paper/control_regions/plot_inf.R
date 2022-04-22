library(ggplot2)

surveyData = read.csv("../../input_generation/surveillance_data/raw_data/survey_data_summary.csv") |>
    sf::st_as_sf(coords=c("x", "y"), crs="WGS84")

controlDistrictsDf = sf::read_sf("../../input_generation/control_raster/inputs/uga_admbnda_ubos_20200824.gdb", layer="uga_admbnda_adm2_ubos_20200824") |>
    dplyr::rename(geom=Shape, poly_name=admin2Name_en)|> 
    dplyr::filter(poly_name%in%c("Luwero", "Mukono", "Nakasongola", "Wakiso")) # Filter out the 4 target districts

gen_summary_df = function(
    inPolyDf,
    colName
){

    polyYears = unique(inPolyDf$year)
    
    statsDf = data.frame()
    for(thisYear in polyYears){
                
        thisYearDf = inPolyDf[inPolyDf$year==thisYear,] |>
            dplyr::filter(!is.na(get(colName)))

        if(nrow(thisYearDf)){

            nPos = sum(thisYearDf[[colName]], na.rm=TRUE)
            nTotal = sum(!is.na(thisYearDf[[colName]]))
            nNeg = nTotal - nPos
            propPos = nPos / nTotal
            
            thisRow = data.frame(
                year=thisYear,
                nPos=nPos,
                nNeg=nNeg,
                nTotal=nTotal,
                propPos=propPos
            )
            
            statsDf = rbind(statsDf, thisRow)
            
        }
        
    }
    
    # Drop too low
    statsDfDrop = statsDf #|>
        # dplyr::filter(nTotal>=10)

    return(statsDfDrop)
    
}

# For each polygon, analyse subset of points that fall within given polygon
statsDfList = list()
for(i in seq_len(nrow(controlDistrictsDf))){

    thisPoly = controlDistrictsDf[i,]

    polyName = thisPoly$poly_name

    # Which points are in poly
    iRowsInPoly = unlist(sf::st_intersects(thisPoly, surveyData))

    # Extract points in poly
    inPolyDf = surveyData[iRowsInPoly,]
    
    statsDfCbsd = gen_summary_df(
        inPolyDf=inPolyDf,
        colName="cbsd"
    ) |>
        dplyr::mutate(poly_name=polyName)
    
    statsDfList[[as.character(i)]] = statsDfCbsd


}

statsDf = dplyr::bind_rows(statsDfList)



p = ggplot(statsDf, aes(x=year, y=propPos, col=poly_name)) +
    geom_line() +
    geom_point() +
    ylim(0,1) +
    xlim(2004, 2017) +
    xlab("Year") +
    ylab("Proportion of survey sites infected") +
    labs(color=NULL) +
    theme(
        axis.text=element_text(size=12),
        axis.title = element_text(size=12),
        legend.text = element_text(size=12)
    )

# p

# Save
cowplot::save_plot("./control_districts_inf.png", p, base_asp=1.2)
