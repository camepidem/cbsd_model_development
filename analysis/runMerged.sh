#!/bin/bash

# Rscript process_1_merge_processed.R \
# "results_fitting/sim_output_agg/model_2/" \
# "survey_data_C" \
# "params_0_job0_artificial_survey" \
# "2021_12_01_merged"

for i in {0..9}
do
    Rscript process_1_merge_processed.R \
    "results_fitting/sim_output_agg/model_2/" \
    "survey_data_C" \
    "params_1_job${i}_artificial_survey" \
    "2021_12_01_merged"
done
