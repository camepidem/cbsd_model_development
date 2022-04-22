tempRasterPath = "./outputs/control_raster_TEMP.asc"
rasterPath = "./outputs/control_raster.asc"

posValTemp = 12345
negValTemp = 54321

posVal = "CULL"
negVal = "NONE"

# -----------------------

controlDistrictsDf = sf::read_sf("./inputs/uga_admbnda_ubos_20200824.gdb", layer="uga_admbnda_adm2_ubos_20200824") |>
    dplyr::rename(geom=Shape)|> 
    dplyr::filter(admin2Name_en%in%c("Luwero", "Mukono", "Nakasongola", "Wakiso")) # Filter out the 4 target districts

# Merge the districts into a single poly
geom = controlDistrictsDf |>
    sf::st_union()

# Convert poly to sf df
controlMergedDf = sf::st_sf(
    poly_name="uga_merged_districts_control",
    geom=geom
)

# Read in template raster
hostRaster = raster::raster("../../simulations/fitting/inputs/agg_inputs/L_0_HOSTDENSITY.txt")
raster::crs(hostRaster) = "EPSG:4326"

# Create bool raster using the poly 
polyRaster = raster::rasterize(x=controlMergedDf, y=hostRaster, field=posValTemp, background=negValTemp)

# Save raster
dir.create("./outputs", showWarnings = FALSE)
raster::writeRaster(polyRaster, tempRasterPath, overwrite=TRUE)

# Replace temp values with required string values
readLines(tempRasterPath) |>
    stringr::str_replace_all(
        pattern = as.character(posValTemp), 
        replace = posVal) |>
    stringr::str_replace_all(
        pattern = as.character(negValTemp), 
        replace = negVal) |>
    stringr::str_replace_all(
        pattern = ".000000000000000", 
        replace = "") |>
    writeLines(con = rasterPath)

# Delete the temp raster
file.remove(tempRasterPath)
