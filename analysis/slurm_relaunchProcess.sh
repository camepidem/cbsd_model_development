#!/bin/bash
#! Name of the job:
#SBATCH -J davids_stuff
#! Project name for Gilligan group,use SL2 for paying queue:
#SBATCH -A GILLIGAN-SL2-CPU
#! Output filename:
#SBATCH --output=davids_stuff_%A_%a.out 
#! Errors filename:
#SBATCH --error=davids_stuff_%A_%a.err 

#! How many whole nodes should be allocated?
#SBATCH --nodes=1
#! How many tasks will there be in total?
#SBATCH --ntasks=1
#! How many many cores will be allocated per task? 
#SBATCH --cpus-per-task=1 
#! Estimated runtime (job is force-stopped after if exceeded):
#SBATCH --time=12:00:00
#! Estimated memory needed (job is force-stopped if exceeded):
#SBATCH --mem=17100mb
#! Submit a job array with index values between 0 and n e.g. 0-100
#SBATCH --array=0

#! This is the partition name. This will request for a node with 6GB RAM for each task
#SBATCH -p cclake

#! mail alert at start,end and abortion of execution
#SBATCH --mail-type=NONE

#! Modify the environment seen by the application. For this example we need the default modules.
. /etc/profile.d/modules.sh                # This line enables the module command
module purge                               # Removes all modules still loaded
module load rhel7/default-peta4            # REQUIRED - loads the basic environment
module load use.own                        # This line loads the own module list
module load /rds/project/cag1/rds-cag1-general/epidem-modules/epidem.modules         # Loads Epidemiology group module list
module load miniconda3/4.9.2

# Conda set up
# >>> conda initialize >>>
# Contents within this block are managed by 'conda init' !!
__conda_setup="$('/rds/project/cag1/rds-cag1-general/epidem-programs/miniconda3/4.9.2/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/rds/project/cag1/rds-cag1-general/epidem-programs/miniconda3/4.9.2/etc/profile.d/conda.sh" ]; then
        . "/rds/project/cag1/rds-cag1-general/epidem-programs/miniconda3/4.9.2/etc/profile.d/conda.sh"
    else
        export PATH="/rds/project/cag1/rds-cag1-general/epidem-programs/miniconda3/4.9.2/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# --------------------------------------------------------

# SET THIS CORRECTLY PER PROJECT
conda activate /rds/project/cag1/rds-cag1-general/epidem-userspaces/dsg38/conda_env_default/dsg38

# Run stuff
# Rscript process_0_gen_processed.R "process_config/model_2_artificial_fitting_params_2/config_model_2_fitting_$SLURM_ARRAY_TASK_ID.json"
Rscript process_0_gen_processed.R "process_config/model_3_validation/config_model_3_fit_0.json"
