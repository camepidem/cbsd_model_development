# bigDf = readRDS("../analysis/results_fitting/sim_output_agg/model_2/2020_01_27_merged/survey_data_C/survey_data_C/results_summary_fixed_TARGET_MINIMAL.rds") |>
#     dplyr::mutate(Rate_0_Sporulation_log = log(Rate_0_Sporulation), batch=substr(simKey, 1, 18))
# 
# x = bigDf |>
#     dplyr::count(batch)
# 
# 
# write.csv(x, "batch_count.csv", row.names=FALSE)

x = read.csv("./batch_count.csv") 

y = x |>
    dplyr::count(set, wt=n)

write.csv(y, "set_count.csv", row.names=FALSE)