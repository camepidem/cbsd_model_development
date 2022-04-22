getUgaNeighbourPolys = function(){
    
    codes = c(
        "UGA",
        "COD",
        "TZA",
        "KEN",
        "SSD"
    )
    
    
    polyList = list()
    for(thisCode in codes){
        
        thisPoly = sf::st_as_sf(raster::getData('GADM', country=thisCode, level=0))
        
        polyList[[thisCode]] = thisPoly
        
    }
    
    polyDf = dplyr::bind_rows(polyList)
    
    return(polyDf)
    
}
