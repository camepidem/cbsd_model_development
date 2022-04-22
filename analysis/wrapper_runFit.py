import subprocess
from pathlib import Path

paramStart = 0
paramEnd = 2

jobStart = 0
jobEnd = 0

configList = [
    # 'artificial_sweep_only_mask_uga_kam',
    # 'artificial_sweep_only_mask_uga_hole',
    # 'artificial_sweep_only_grid_broad',
    'artificial_sweep_combo_broad'
]

for paramNum in range(paramStart, paramEnd+1):

    print(paramNum)

    for iJob in range(jobStart, jobEnd+1):

        print(iJob)

        paramDir = 'params_' + str(paramNum) + '_job' + str(iJob) + '_artificial_survey'

        inputDir = Path("results_fitting/sim_output_agg/model_2/2021_12_01_merged/survey_data_C") / paramDir

        paramsSpec = Path("../simulations/gen_prior/model_2/artificial") / ("params_" + str(paramNum) + ".csv")

        for configName in configList:

            print(configName)

            configDir = Path('results_fitting/fitting_config') / configName

            cmdList = [
                'Rscript',
                'fit_0_gen_results.R',
                inputDir,
                configDir,
                '0',
                paramsSpec
            ]

            print(cmdList)

            subprocess.call(cmdList)
