from pathlib import Path
import json

topDirList = [
    "../../analysis/results_fitting/fitting_output/model_2/2021_12_01_merged/survey_data_C/params_0_job0_artificial_survey",
    "../../analysis/results_fitting/fitting_output/model_2/2021_12_01_merged/survey_data_C/params_1_job0_artificial_survey",
    "../../analysis/results_fitting/fitting_output/model_2/2021_12_01_merged/survey_data_C/params_2_job0_artificial_survey",
]

# ---------------------------------------------

configDict = {}

for thisTopDirStr in topDirList:

    thisTopDir = Path(thisTopDirStr)

    datasetTargetInf = thisTopDir.parts[-1]
    datasetSurveyLocs = thisTopDir.parts[-2]
    mergedStr = thisTopDir.parts[-3]
    modelStr = thisTopDir.parts[-4]

    bigDfPath = Path('../../analysis/results_fitting/sim_output_agg/') / modelStr / mergedStr / datasetSurveyLocs / datasetTargetInf / 'results_summary_fixed_TARGET_MINIMAL.rds'

    # Recursively list fitting dirs
    fittingDirs = [f for f in thisTopDir.iterdir() if f.is_dir()]
    # breakpoint()
    plotTopDir = Path('./') / ("plots_artificial_" + modelStr) / datasetTargetInf

    paramsPath = Path("../../simulations/gen_prior/model_2/artificial/") / Path(datasetTargetInf[0:8] + '.csv')

    # For each fitting dir, recursively list the fitting sweep folders + create config for each
    for thisFittingDir in fittingDirs:

        sweepDirs = [f for f in thisFittingDir.glob('*_*') if f.is_dir()]

        for thisSweepDir in sweepDirs:

            passKeysPath = thisSweepDir / 'passKeys.csv'

            plotDir = plotTopDir / thisSweepDir.parts[-2][18:]

            plotPrefix = thisSweepDir.parts[-1] + '_'

            # breakpoint()

            configDict[thisSweepDir.as_posix()] = {
                'bigDfPath': bigDfPath.as_posix(),
                'passKeysDfPath': passKeysPath.as_posix(),
                'plotDir': plotDir.as_posix(),
                'plotPrefix': plotPrefix,
                'droppedBool': False,
                'batchBool': False,
                'bigFont': True,
                'passKeysDfPredroppedPath': None,
                'paramsPath': paramsPath.as_posix()
            }

with open("config_artificial.json", 'w') as fout:
    json_dumps_str = json.dumps(configDict, indent=4)
    print(json_dumps_str, file=fout)
