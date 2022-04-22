# CBSD Model Development

This repo contains the analysis code for the iterative development, parameter estimation, and validation of the CBSD model, which includes the configs for the epidemic simulation framework, MPEM. The hundreds of thousands of development, fitting and validation simulations required HPC infrastructure, so there are challenges involved in sharing the full development pipeline. Nonetheless, we have endevored to share as much code as possible and hopefully this readme will assist in understanding the workflow. Specifically, this repo includes:

- The code to download and process required inputs for the model e.g. the host landscape, vector layer, summary statistic target data etc.
- The config files for the wrapper around the MPEM simulator to run on the HPC
- The summarised output datasets from the MPEM simulator
- The ABC fitting code that acts upon these datasets
- The plotting code to generate the results presented in the paper

The code for the MPEM simulator can be found here: `TODO: INSERT RICH'S REPO URL`

## Code environment

Parameter estimation and analysis code OS: `macOS 12.3.1`

Simulation code OS: `Scientific Linux release 7.9 (Nitrogen)`

### R

Version: `4.1.3`

Packages: `./env_r.csv`

### Python

Version: `3.9.12`

Conda env: `./env_python.yml` 

## Downloading input data

Run this first to download datasets that were under a 'no redistribution license':

`bash ./download_data.sh`
