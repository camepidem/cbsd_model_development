#!/bin/bash
python3.sh my_pmpem.py \
-o "../artificial/sim_output/model_2/params_2/" \
--nsamplesperparamset 10 \
--densityfile "../gen_prior/model_2/artificial/params_2.txt" \
--opertype pd \
--scheduler s \
--slurmqueue "SL2" \
--memoryrequest 5980 \
--parametersfile "params/params_fitting_model_2.txt" \
--runtimerequest "12:00:00" \
--landscapefolder "/rds/project/cag1/rds-cag1-general/epidem-userspaces/dsg38/cbsd_landscape_model/simulations/fitting/inputs/agg_inputs"
