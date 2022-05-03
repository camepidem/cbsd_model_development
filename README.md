# CBSD Model Development

This repo contains the analysis code for the iterative development, parameter estimation, and validation of the CBSD model, which includes the configs for the epidemic simulation framework, MPEM. The hundreds of thousands of development, fitting and validation simulations required HPC infrastructure, so there are challenges involved in sharing the full development pipeline. Nonetheless, we have endeavoured to share as much code as possible and hopefully this readme will assist in understanding the workflow. Specifically, this repo includes:

- The code to download and process required inputs for the model e.g. the host landscape, vector layer, summary statistic target data etc.
- The config files for the wrapper around the MPEM simulator to run on the HPC
- The summarised output datasets from the MPEM simulator
- The ABC fitting code that acts upon these datasets
- The plotting code to generate the results presented in the paper

The code for the MPEM simulator can be found here: `TODO: INSERT RICH'S REPO URL`

It is important to note that fitting/validation simulations were generally run in batches of a few thousand simulations that were subsequently merged and then analysed. Therefore, this iterative generation of simulations, analysis and merging is integral to the code workflow.

## Code environment

Parameter estimation and analysis code OS: `macOS 12.3.1`

Simulation code OS: `Scientific Linux release 7.9 (Nitrogen)`

### R

Version: `4.1.3`

Packages: `./env_r.csv`

### Python

Version: `3.9.12`

Conda env: `./env_python.yml` 

## Summary of model naming

Models 0-2 follow the naming convention in the supplementary material of the paper. Model 0B represents preliminary attempts to parameterise a model with an exponential kernel. Model 3 represents the final validated model in the paper and is composed of the parameterised model_2 with the clean seed management intervention during 2013-2015. 

## Downloading input data

Run this first to download datasets that were under a 'no redistribution licence':

`bash ./download_data.sh`

## Generating simulation and parameter estimation input files

The simulation and parameter estimation input files that are derived from datasets in the previous step are already provided as part of this repo. However, if you wish to regenerate these:

- From within `./input_generation`, run `Rscript gen_inputs.R`
- From within `./input_generation/control_raster`, run `Rscript gen_control_raster.R`

## Generate summary statistic target data

Apply the summary statistics to the summarised Ugandan surveillance dataset.

- `cd ./summary_stats`
- `Rscript gen_summary_stats.R`

## Setup and run simulations

### Generate MPEM input files

- `cd ./simulations`
- `Rscript setup_sim_inputs.R`

### Configure simulations

For each of the different simulation / model types, a script in `./simulations/launch/launch_*.sh` specifies the configuration for the HPC wrapper around the MPEM simulator. Of particular note are the `--parametersfile` which specifies a few additional MPEM parameters and the first line e.g. `python3.sh my_pmpem.py` - this python file specifies the remaining MPEM parameters. 

In addition, the `--densityfile` argument specifies the region of the prior to sample parameters within for the given batch of simulations. The different regions of prior space to sample within and the posterior distributions for (preliminary) validation simulations are in `./simulations/gen_prior`.

## ABC parameter estimation and validation

### Summarise simulation output files

Prior to analysing simulations, it's necessary to summarise the raw simulation outputs on the HPC and then pull them down locally. The following commands all assume you're in `./analysis`.

The script `process_0_gen_processed.R` takes a single config JSON path as a command line argument. The configs for the different fitting/validation sims for the different models are located in `process_config`. This processes a single batch of simulations. This script saves summaries to the following generic path: `results_[fitting|validation]/sim_output_agg/model_*/DATE_BATCH-NAME/SURVEY-LOCATION-STRUCTURE/SURVEY-TARGET-DATA/`. The key summarised datasets are provided as part of this repo to enable re-running of analysis code on real simulation outputs. However, the raw simulation data is too large to provide in a git repo (>200,000 simulations in separate folders).

In order to merge multiple batches of simulations: `process_1_merge_processed.R`. Examples of the command line arguments to this script are commented out in the script.

The script `process_2_calc_bins.R` acts on a given set of outputs (single batch or merged) to create a necessary file for the calculation of the posterior distributions.

Having processed the raw simulation output to summarised versions ready for analysis, these files are pulled down locally from the HPC (e.g. SFTP / FileZilla).

### Applying the fitting or validation criteria

The key script in applying fitting or validation criteria is `fit_0_gen_results.R`. The command line arguments for the different analyses using this script are given in `fit_0_args.sh` which point to the configuration of tolerances for the different summary statistics.

In the case of the final parameterisation of model_2, a few outlier simulations out of >200,000 were dropped from the posterior distribution due to low sample density. See `fit_1_drop_outlier.R`.

Posterior distributions are generated using `fit_2_gen_posterior.R`. Arguments are provided in the script.

## Synthetic (artificial) simulations with known parameters

As documented in the supplementary methods of the paper, we developed a methodology to perform parameter estimation on synthetic surveillance data generated using MPEM with known parameter values and assess the ability of the parameter estimation methodology to recover these known parameter values.

Three different sets of known parameters were used to run 10 simulations per set. The simulation launch files are specified in: `./simulations/launch/launch_artificial_params_*.sh`

Run `./artificial/artificial_survey_wrapper.R` to generate synthetic target survey data (in same format as real survey data)

Run `../summary_stats/gen_summary_stats.R` to calculate the summary statistics for the synthetic target surveillance data

Run processing on HPC with `slurm_relaunchProcess.sh` - to append to the fitting simulations how close they were to the synthetic target surveillance data

Run `runMerged.sh` for each job[0-9] of params_*
- Zip all + copy these dirs locally

Run `wrapper_runFit.py` for all job[0-9] for fitting configs (each metric individually + combo)

## Generating figure for paper

See `./figs_paper`
