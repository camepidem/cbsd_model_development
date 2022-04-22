#!/bin/bash
python3.sh my_pmpem.py \
-o "../fitting/sim_output/model_0B/2021_03_12_batch_0/" \
--nsamplesperparamset 10000 \
--densityfile "../gen_prior/model_0B/fitting/2021_03_11_higher.txt" \
--opertype pd \
--scheduler s \
--slurmqueue "SL3" \
--memoryrequest 5980 \
--parametersfile "params/params_fitting_model_0B.txt" \
--runtimerequest "12:00:00" \
--landscapefolder "/rds/project/cag1/rds-cag1-general/epidem-userspaces/dsg38/cbsd_landscape_model/simulations/fitting/inputs/agg_inputs"
