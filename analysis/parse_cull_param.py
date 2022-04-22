from pathlib import Path
import pandas as pd

topDir = Path('../simulations/validation/sim_output/model_3/2022_03_16_batch_0/')
outPath = './results_validation/sim_output_agg/model_3/2022_03_16_batch_0/survey_data_C/survey_data_C/ControlCullEffectiveness.csv'

# --------------------------------------------

jobDirs = list(topDir.glob('job*'))

simKeyList = []
paramList = []
for jobDir in jobDirs:

    print(jobDir)

    paramsDfPath = jobDir / 'parametersfile.txt'

    if not paramsDfPath.exists():

        print(paramsDfPath)

        raise Exception("paramsDfPath")

    else:

        paramsDf = pd.read_csv(paramsDfPath, delim_whitespace=True)

        simKey = topDir.parts[-1] + '_' + jobDir.parts[-1] + '_0'

        ControlCullEffectiveness = paramsDf['ControlCullEffectiveness'][0]

        simKeyList.append(simKey)
        paramList.append(ControlCullEffectiveness)

        # breakpoint()

outDf = pd.DataFrame({'simKey': simKeyList, 'ControlCullEffectiveness': paramList})

# Save df
outDf.to_csv(outPath, index=False)
