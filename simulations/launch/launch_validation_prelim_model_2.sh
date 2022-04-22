#!/bin/bash

module load python3
module load pmpem

python3.sh my_pmpem.py \
-o "../validation/sim_output/model_2/2022_01_31_prelim_validation_025/" \
--nsamplesperparamset 1000 \
--densityfile "../gen_prior/model_2/validation_prelim/grid-tol_applied_only_where_both_bool-0.53_mask_0_025.txt" \
--opertype pd \
--scheduler s \
--slurmqueue "SL2" \
--memoryrequest 6840 \
--parametersfile "params/params_validation_model_2.txt" \
--runtimerequest "12:00:00" \
--landscapefolder "/rds/project/cag1/rds-cag1-general/epidem-userspaces/dsg38/cbsd_landscape_model/simulations/fitting/inputs/agg_inputs" \
--launchscript `readlink -f $0` \
--dmtcp_restart_limit 30 \
--dmtcp_checkpoint_secs 39600
