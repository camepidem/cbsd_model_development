box::use(tmap[...])
box::use(../utils_plot)

countryPolys = utils_plot$getUgaNeighbourPolys()
lakesPoly = sf::st_read("../host/GLWD-level1/lakes_glwd_1.gpkg")

# Crop all to Uga extent to speed up plotting
ugaPoly = countryPolys[countryPolys$GID_0=="UGA",]

kamPoly = sf::read_sf("./kam_polys.gpkg")

# ---------------------------------
# Vector
p = 
    tm_shape(ugaPoly) + 
    tm_fill(col="#99D8C9") +
    
    tm_shape(kamPoly) + 
    tm_fill(col="#2CA25F") +
    tm_borders() +
    
    tm_shape(lakesPoly) +
    tm_borders(lwd=0.5) +
    tm_fill(col="#A1C5FF") +
    
    tm_shape(countryPolys) +
    tm_borders() +

    tm_compass(position = c("right", "top"), size=5) + 
    tm_scale_bar(position = c("left", "bottom"), text.size = 1.2) +
    tm_graticules(lines = FALSE, labels.size=1.5) +
    tm_layout(
        legend.position=c("right", "bottom"),
        legend.frame=TRUE,
        legend.bg.color="grey",
        legend.bg.alpha=0.8,
        legend.outside.size = 0.2,
        legend.text.size = 1.2
    ) +
    
    tm_credits(expression(S[cen]), position=c(0.5,0.33), size = 2) +
    tm_credits(expression(S[nat]), position=c(0.5,0.65), size = 2)

# p

tmap_save(p, "inf_prop_map.png")
