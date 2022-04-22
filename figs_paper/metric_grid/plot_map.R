box::use(tmap[...])
box::use(../utils_plot)

datasetStr = "survey_data_C"
masksDf = readRDS("data/masksDf.rds")
maskInt = as.numeric(gsub("grid_", "", masksDf$ID))
masksDf = cbind(masksDf, maskInt)

countryPolys = utils_plot$getAfricaCassavaPolys()
ugaPoly = countryPolys[countryPolys$GID_0=="UGA",]

ugaBbox = sf::st_bbox(c(xmin=29, xmax=35.5, ymin=-2, ymax=5))

# ------------------------

realDfPath = file.path("../../summary_stats/mask_stats/", datasetStr, "/grid_arrival_year.csv")
realDfRaw = read.csv(realDfPath)

ID = gsub("mask_uga_", "", realDfRaw$polySuffix)
realDf = cbind(realDfRaw, ID)

arrivalDf = merge(masksDf, realDf, by="ID") |>
    dplyr::filter(firstSurveyYear <= 2010) # Filter out any grids where surveys happen after 2010

# If first inf year is after 2010, set to NA i.e. never inf
arrivalDf$firstInfYear[arrivalDf$firstInfYear > 2010] = NA

p = 
    tm_shape(countryPolys, bbox=ugaPoly) +
    tm_polygons(alpha=0) +
    
    tm_shape(arrivalDf) +
    tm_polygons(
        "firstInfYear", 
        alpha=0.3, 
        colorNA="green", labels=c("2005", "2006", "2007", "2008", "2009", "2010"),
        textNA=">2010",
        title="Year of\nfirst CBSD\nreport",
        palette="-YlOrBr"
        ) +
    
    tm_shape(arrivalDf) +
    tm_text("firstInfYear") +
    
    tm_shape(arrivalDf) +
    tm_text("maskInt", xmod=-1.3, ymod=1.3) +

    tm_graticules(lines = FALSE, labels.size=1.2) +
    
    tm_layout(
        legend.outside = TRUE,
        legend.text.size = 1.2,
        legend.title.size = 1.2
    )

# p

tmap_save(tm=p, filename=file.path("plots", paste0("grid_", datasetStr, ".png")), width=6.82, height=5)

    