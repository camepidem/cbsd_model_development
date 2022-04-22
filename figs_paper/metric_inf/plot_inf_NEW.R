library(ggplot2)

statsDir = "../../summary_stats/mask_stats/survey_data_C/"

kamDfPath = file.path(statsDir, "mask_uga_kam.csv")
ugaDfPath = file.path(statsDir, "mask_uga_hole.csv")

kamDf = read.csv(kamDfPath) |> dplyr::mutate(mask="Kam")
ugaDf = read.csv(ugaDfPath) |> dplyr::mutate(mask="Uga")

statsDf = rbind(kamDf, ugaDf)

lab1 = c("Kam" = expression(S[kam]), "Uga" = expression(S[nat]))

p = ggplot(statsDf, aes(x=year, y=propPos, col=mask)) + 
    geom_line() +
    geom_point() +
    ylim(0,1) +
    ylab("Proportion of survey sites infected") +
    xlab("Year") +
    scale_color_discrete(labels = lab1, name=NULL) +
    geom_vline(xintercept = 2010, linetype="dashed") +
    theme(
        axis.text=element_text(size=12),
        axis.title = element_text(size=12),
        legend.text = element_text(size=12)
    )
# p
cowplot::save_plot("inf_prop_target_data.png", p, base_asp=1.2)
