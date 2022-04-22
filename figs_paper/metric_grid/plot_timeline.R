box::use(ggplot2[...])
box::use(ggnewscale[...])

maxYear = 2010

# Data on yearly num surveys / num pos for each quadrat
statsDf = read.csv("./data/mask_stats_merged.csv") |>
    dplyr::mutate(infBool = propPos>0) |>
    dplyr::filter(year <= maxYear) |>
    dplyr::mutate(quadrat_index=gsub(pattern = "mask_uga_grid_", replacement = "", polySuffix))

# Summary of first survey / first inf years for each quadrat (NB: 21 quadrat have any surveys in their extent)
infYearDfRaw = read.csv("../../summary_stats/mask_stats/survey_data_C/grid_arrival_year.csv") |>
    dplyr::mutate(quadrat_index=gsub(pattern = "mask_uga_grid_", replacement = "", polySuffix)) |>
    dplyr::mutate(quadrat_index = factor(quadrat_index, levels=as.character(sort(as.numeric(quadrat_index))))) # Order by numeric val for plotting

# Drop the two quadrat that don't have surveys <= 2010 = 19 target quardrats
infYearDf = infYearDfRaw |>
    dplyr::filter(firstSurveyYear <= maxYear)

cols = c("TRUE"="red", "FALSE"="green")
pointCols = c("both"="blue", "one"="orange", "none"="black")

p = ggplot(mapping=aes(firstInfYear, quadrat_index)) +
    geom_point(data=infYearDf, aes(colour=neighbouring_data_cat), pch=3, size=3, stroke=1.2) +
    scale_colour_manual(values=pointCols) +
    labs(color='Neighbouring\nSurvey Category') +
    scale_x_continuous(breaks = seq(2004, 2010), limits=c(2004, 2010)) + # This cuts off the point where grid_10 gets inf but in 2012
    new_scale_color() +
    geom_point(data=statsDf, aes(x=year, y=quadrat_index, colour=infBool)) +
    scale_colour_manual(values=cols) +
    ylab("Quadrat index") +
    xlab("Survey Year") +
    labs(color='CBSD Positive\nSurvey')
    
# p

cowplot::save_plot(plot=p, filename = "plots/grid_timeline.png")
