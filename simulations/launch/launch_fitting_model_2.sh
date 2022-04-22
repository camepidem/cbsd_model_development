#!/bin/bash
python3.sh my_pmpem.py \
-o "../fitting/sim_output/model_2/2019_08_12_batch_0/" \
--nsamplesperparamset 10000 \
--densityfile "../gen_prior/model_2/fitting/2019_08_03_prior.txt" \
--opertype pd \
--scheduler s \
--slurmqueue "SL3" \
--memoryrequest 5980 \
--parametersfile "params/params_fitting_model_2.txt" \
--runtimerequest "12:00:00" \
--landscapefolder "/rds/project/cag1/rds-cag1-general/epidem-userspaces/dsg38/cbsd_landscape_model/simulations/fitting/inputs/agg_inputs"

