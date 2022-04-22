#!/bin/bash
python3.sh my_pmpem.py \
-o "../fitting/sim_output/model_1/2020_09_04_batch_0/" \
--nsamplesperparamset 10000 \
--densityfile "../gen_prior/model_1/fitting/2020_09_04_narrow.txt" \
--opertype pd \
--scheduler s \
--slurmqueue "SL3" \
--memoryrequest 5980 \
--parametersfile "params/params_fitting_model_1.txt" \
--runtimerequest "12:00:00" \
--landscapefolder "/rds/project/cag1/rds-cag1-general/epidem-userspaces/dsg38/cbsd_landscape_model/simulations/fitting/inputs/agg_inputs"
