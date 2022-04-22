# How to process artificial

Run artificial sims on cluster

Copy simulation output locally into simulations dir

Run `artificial_survey_wrapper.R` to generate synthetic target survey data (in same format as real survey data)

Run `../summary_stats/gen_summary_stats.R` to calculate the summary statistics for the synthetic target surveillance data

Run processing on HPC with `slurm_relaunchProcess.sh` - to append to the fitting simulations how close they were to the synthetic target surveillance data

Run `runMerged.sh` for each job[0-9] of params_*
- Zip all + copy these dirs locally

Run `wrapper_runFit.py` for all job[0-9] for fitting configs (each metric individually + combo)
