box::use(tmap[...])
box::use(sf[...])

ugaPoly = sf::st_as_sf(raster::getData('GADM', country='UGA', level=0))

kamPoly = sf::read_sf("../metric_inf/kam_polys.gpkg")

lakesPoly = sf::st_read("../host/GLWD-level1/lakes_glwd_1.gpkg")
lakesPolySmall = sf::st_crop(lakesPoly, ugaPoly)

kamSf = sf::read_sf("./kam.geojson")

controlDistrictsDf = sf::read_sf("../../input_generation/control_raster/inputs/uga_admbnda_ubos_20200824.gdb", layer="uga_admbnda_adm2_ubos_20200824") |>
    dplyr::rename(geom=Shape)|> 
    dplyr::filter(admin2Name_en%in%c("Luwero", "Mukono", "Nakasongola", "Wakiso")) # Filter out the 4 target districts

p = tm_shape(lakesPolySmall, bbox = sf::st_bbox(ugaPoly)) +
    tm_fill(col="#A1C5FF") +
    tm_shape(ugaPoly) +
    tm_borders() +
    tm_shape(controlDistrictsDf) +
    tm_polygons("admin2Name_en", title="", palette=c(Luwero='#F35E5A', Mukono='#6BA205', Nakasongola='#18B3B7',Wakiso='#BB5DFF')) +
    tm_shape(kamPoly) +
    tm_borders(lty="dashed", lwd=2) +
    
    tm_shape(kamSf) +
    tm_dots(size=2.3) +
    tm_text("name", xmod = 2.8, ymod = 1, size=1.3) +
    
    tm_graticules(lines = FALSE, labels.size=1.5) +
    tm_compass(position = c("right", "top"), size=5) + 
    tm_scale_bar(position = c("left", "bottom"), text.size = 1.2) +
    tm_layout(
        legend.text.size = 1.5,
        legend.bg.color = "grey",
        legend.bg.alpha = 0.3,
        legend.frame=TRUE
    )


# p
tmap_save(p, "control_districts_map.png")

