genHostLandscape = function(
    rawProdRasterPath, 
    outRasterPathFields,
    outRasterPathNorm
){
    
    options(stringsAsFactors = F)
    library(raster)
    library(rworldmap)

    rawProdRaster = raster(rawProdRasterPath)

    dir.create(dirname(outRasterPathFields), showWarnings = F)
    dir.create(dirname(outRasterPathNorm), showWarnings = F)

    avg_yield_t_per_ha = 10
    avg_field_size_ha = 0.1

    ha_per_sqkm = 100
    cellsize_sqkm = 1

    min_prop_field_possible = 0.1

    # -------------------

    # Define constants
    num_ha_per_cell = cellsize_sqkm * ha_per_sqkm
    max_num_fields_per_cell = num_ha_per_cell / avg_field_size_ha
    single_field_yield_t = avg_field_size_ha * avg_yield_t_per_ha
    min_production_t_per_cell = min_prop_field_possible * single_field_yield_t

    # Remove cells with production below a lower threshold
    cells_to_remove = rawProdRaster<min_production_t_per_cell & rawProdRaster>0

    ## Sanity check: What prop of total production is reduced to 0
    tooLowVals = rawProdRaster[cells_to_remove]
    sumTooLowVals = sum(tooLowVals)
    sumAllVals = cellStats(rawProdRaster, 'sum', asSample=F)
    propToRemove = sumTooLowVals / sumAllVals
    print(paste0("Removing small vals: ", propToRemove, " of host"))
    ## -----------------

    prodRasterRemovedLow = rawProdRaster
    prodRasterRemovedLow[cells_to_remove] = 0

    # Convert to number of fields and normalise
    numFieldsRaster = prodRasterRemovedLow / single_field_yield_t
    normNumFieldsRaster = numFieldsRaster / max_num_fields_per_cell

    # Write out
    writeRaster(numFieldsRaster, outRasterPathFields, overwrite=TRUE)
    print(paste0("Written out: ", outRasterPathFields))

    writeRaster(normNumFieldsRaster, outRasterPathNorm, overwrite=TRUE)
    print(paste0("Written out: ", outRasterPathNorm))

}
