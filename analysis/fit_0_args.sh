#!/bin/bash

# Fixed params to be overwritten
cullBool=0
paramsPath=""

# Commands
# topDataDir="./results_fitting/sim_output_agg/model_0/2022_01_20_merged/survey_data_C/survey_data_C/"
# topDataDir="./results_fitting/sim_output_agg/model_1/2022_01_20_merged/survey_data_C/survey_data_C/"
# topDataDir="./results_fitting/sim_output_agg/model_2/2022_01_19_sample/survey_data_C/survey_data_C/"
# topDataDir="./results_fitting/sim_output_agg/model_0B/2022_02_03_merged/survey_data_C/survey_data_C/"
# configDir="./results_fitting/fitting_config/2022_01_31_fitting_prelim_03"

# topDataDir="./results_validation/sim_output_agg/model_2/2022_01_20_prelim_validation/survey_data_C/survey_data_C"
# configDir="./results_validation/fitting_config/2022_01_21_validation_prelim"
# configDir="./results_validation/fitting_config/2022_01_21_validation_prelim_nothing"


# topDataDir="./results_validation/sim_output_agg/model_0/2022_01_20_batch_0/survey_data_C/survey_data_C/"
# topDataDir="./results_validation/sim_output_agg/model_1/2022_01_20_batch_0/survey_data_C/survey_data_C/"
# topDataDir="./results_validation/sim_output_agg/model_2/2022_01_20_prelim_validation/survey_data_C/survey_data_C"
# configDir="./results_validation/fitting_config/2022_01_31_validation_02"


# topDataDir="./results_validation/sim_output_agg/model_0/2022_01_31_batch_1_025/survey_data_C/survey_data_C"
# topDataDir="./results_validation/sim_output_agg/model_1/2022_01_31_batch_1_025/survey_data_C/survey_data_C"
# topDataDir="./results_validation/sim_output_agg/model_2/2022_01_31_prelim_validation_025/survey_data_C/survey_data_C"
# configDir="./results_validation/fitting_config/2022_02_01_validation_prelim_025"


# topDataDir="./results_validation/sim_output_agg/model_2/2021_12_06_batch_0/survey_data_C/survey_data_C/"
# configDir="./results_validation/fitting_config/2022_02_01_broad/"

# topDataDir="./results_fitting/sim_output_agg/model_2/2021_12_01_merged/survey_data_C/survey_data_C/"
# configDir="./results_fitting/fitting_config/2022_02_03_single/"

# topDataDir="./results_validation/sim_output_agg/model_2/2022_02_04_batch_0/survey_data_C/survey_data_C/"
# configDir="./results_validation/fitting_config/2022_02_07_validation/"

# topDataDir="./results_validation/sim_output_agg/model_3/2022_03_16_batch_0/survey_data_C/survey_data_C"
# configDir="./results_validation/fitting_config/2022_02_18_cullParam/"
# cullBool=1

topDataDir="./results_validation/sim_output_agg/model_3/2022_03_18_batch_0/survey_data_C/survey_data_C/"
configDir="./results_validation/fitting_config/2022_02_07_validation/"

Rscript fit_0_gen_results.R $topDataDir $configDir $cullBool $paramsPath
