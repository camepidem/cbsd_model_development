#!/bin/bash

module load python3
module load pmpem

python3.sh my_pmpem_model_3.py \
-o "../validation/sim_output/model_3/2022_03_16_batch_0/" \
--nsamplesperparamset 1000 \
--densityfile "../gen_prior/model_2/validation/2022_02_04_model_2_posterior.txt" \
--opertype pd \
--scheduler s \
--slurmqueue "SL2" \
--memoryrequest 6840 \
--parametersfile "params/params_validation_prelim_model_3.txt" \
--runtimerequest "36:00:00" \
--landscapefolder "/rds/project/cag1/rds-cag1-general/epidem-userspaces/dsg38/cbsd_landscape_model/simulations/fitting/inputs/agg_inputs" \
--launchscript `readlink -f $0` \
--dmtcp_restart_limit 30 \
--dmtcp_checkpoint_secs 122400
