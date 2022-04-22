#!/bin/bash

# Model 2 

# Fitting

## Initial broad sweep 

# Rscript fit_0_gen_results.R \
# "results_fitting/sim_output_agg/model_2/2021_12_01_merged//survey_data_C/survey_data_C" \
# "results_fitting/fitting_config/2021_12_03_narrow_sweep"

# Rscript fit_0_gen_results.R \
# "results_fitting/sim_output_agg/model_2/2021_12_01_merged//survey_data_C/survey_data_C" \
# "results_fitting/fitting_config/2021_12_03_single"












# --------------------------------------------------
# --------------------------------------------------
# --------------------------------------------------
# --------------------------------------------------
# --------------------------------------------------
# --------------------------------------------------
# --------------------------------------------------
# --------------------------------------------------
# --------------------------------------------------
# --------------------------------------------------
# OLD
# --------------------------------------------------
# --------------------------------------------------
# --------------------------------------------------
# --------------------------------------------------
# --------------------------------------------------
# --------------------------------------------------
# --------------------------------------------------
# --------------------------------------------------
# --------------------------------------------------

# Model 0

## Fitting

# Rscript fit_0_gen_results.R \
# "results_fitting/sim_output_agg/model_0/2020_09_19_merged/survey_data_C/survey_data_C" \
# "results_fitting/fitting_config/broad"

## Validation

# Rscript fit_0_gen_results.R \
# "results_validation/sim_output_agg/model_0/2020_01_27_batch_0/survey_data_C/survey_data_C" \
# "results_validation/fitting_config/2020_12_20_narrower"


# Model 0B

## Fitting
Rscript fit_0_gen_results.R \
"results_fitting/sim_output_agg/model_0B/2022_02_03_merged/survey_data_C/survey_data_C" \
"results_fitting/fitting_config/2022_01_31_fitting_prelim_03"



# --------------------------------------------------
# Model 1

## Fitting

# Rscript fit_0_gen_results.R \
# "results_fitting/sim_output_agg/model_1/2020_09_13_merged/survey_data_C/survey_data_C" \
# "results_fitting/fitting_config/broad"

## Validation

# Rscript fit_0_gen_results.R \
# "results_validation/sim_output_agg/model_1/2020_09_13_batch_0/survey_data_C/survey_data_C" \
# "results_validation/fitting_config/2020_12_20_narrower"

# --------------------------------------------------
# Model 2 (preliminary)

## Fitting

# Rscript fit_0_gen_results.R \
# "results_fitting/sim_output_agg/model_2/2020_12_28_sample/survey_data_C/survey_data_C" \
# "results_fitting/fitting_config/broad"

## Validation

# Rscript fit_0_gen_results.R \
# "results_validation/sim_output_agg/model_2/2020_12_20_prelim_validation/survey_data_C/survey_data_C" \
# "results_validation/fitting_config/2020_12_20_narrower"

# --------------------------------------------------
# Fitting artificial
# NB: BELOW IS DEAD CODE?!?!? Use `wrapper_runFit.py` for artificial instead

# Rscript fit_0_gen_results.R \
# "results_fitting/sim_output_agg/model_2/2021_12_01_merged/survey_data_C/survey_data_C" \
# "results_fitting/fitting_config/artificial_sweep_only_mask_uga_kam/" \
# "../simulations/gen_prior/model_2/artificial/params_0.csv"

# Rscript fit_0_gen_results.R \
# "results_fitting/sim_output_agg/model_2/2020_01_27_merged/survey_data_C/params_0_job0_artificial_survey" \
# "results_fitting/fitting_config/sweep_only_mask_uga_hole" \
# "../simulations/gen_prior/model_2/artificial/params_0.csv"

# Rscript fit_0_gen_results.R \
# "results_fitting/sim_output_agg/model_2/2020_01_27_merged/survey_data_C/params_0_job0_artificial_survey" \
# "results_fitting/fitting_config/sweep_only_grid" \
# "../simulations/gen_prior/model_2/artificial/params_0.csv"

