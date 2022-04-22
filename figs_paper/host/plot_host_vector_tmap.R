box::use(tmap[...])
box::use(../utils_plot)

# Read data / set up crs
vectorRaster = raster::raster("../../input_generation/vector_layer/vector_layer_data_C/idw_raster_param_1_data_C.tif", crs="EPSG:4326")
hostRaster = raster::raster("../../input_generation/host_landscape/fields_host/CassavaMap_Prod_v1_FIELDS.tif")

# --------------------------------

countryPolys = utils_plot$getUgaNeighbourPolys()
lakesPoly = sf::st_read("./GLWD-level1/lakes_glwd_1.gpkg")

# Process raster
vectorRaster[vectorRaster == 0] = NA
hostRaster[hostRaster == 0] = NA

# Crop all to Uga extent to speed up plotting
ugaPoly = countryPolys[countryPolys$GID_0=="UGA",]

vectorRasterCrop = raster::crop(vectorRaster, ugaPoly)
hostRasterCrop = raster::crop(hostRaster, ugaPoly)

countryPolysSmall = sf::st_crop(countryPolys, ugaPoly)
lakesPolySmall = sf::st_crop(lakesPoly, ugaPoly)

# ---------------------------------

# Vector
p = tm_shape(vectorRasterCrop) +
    tm_raster(
        style = "cont",
        breaks=seq(0,1, 0.1),
        legend.reverse = TRUE,
        title="",
        palette = tmaptools::get_brewer_pal("YlOrBr", n = 7)[1:6],
        alpha=0.7
    ) +
    tm_shape(lakesPolySmall) +
    tm_fill(col="#A1C5FF") +
    tm_shape(countryPolysSmall) +
    tm_borders(lwd=1.5) +
    tm_compass(position = c("right", "top"), size=5) +
    tm_scale_bar(position = c("left", "bottom"), text.size = 1.2) +
    tm_graticules(lines = FALSE, labels.size=1.5) +
    tm_layout(
        legend.position=c("right", "bottom"),
        legend.frame=TRUE,
        legend.bg.color="grey",
        legend.bg.alpha=0.8,
        legend.text.size = 1.2
    )

# p
tmap_save(p, "plots/vector_uga.png")

# ---------------------------------
 # Host
q = tm_shape(hostRasterCrop) +
    tm_raster(
        breaks=c(0, 1, 5, 10, 50, 100, 1000),
        labels=c("< 1", "1 to 5", "5 to 10", "10 to 50", "50 to 100", "100 to 1000"),
        colorNA = "white",
        textNA = "No production",
        palette = "Greens",
        title="",
        legend.reverse = TRUE
    ) +
    tm_shape(lakesPolySmall) +
    tm_fill(col="#A1C5FF") +
    tm_shape(countryPolysSmall) +
    tm_borders(lwd=1.5) +
    tm_compass(position = c("right", "top"), size=5) +
    tm_scale_bar(position = c("left", "bottom"), text.size = 1.2) +
    tm_graticules(lines = FALSE, labels.size=1.5) +
    tm_layout(
        legend.position=c("right", "bottom"),
        legend.frame=TRUE,
        legend.bg.color="grey",
        legend.bg.alpha=0.8,
        legend.text.size = 1.2
    )

# q
tmap_save(q, "plots/host_uga.png")
