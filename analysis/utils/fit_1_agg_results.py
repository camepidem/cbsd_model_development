import os
import shutil
from pathlib import Path
import sys

# topDirStr = "./results_fitting/fitting_output/model_0/2020_01_12_batch_0/survey_data_C/2020_01_14_171859_broad"
topDirStr = sys.argv[1]


topDir = Path(topDirStr)
outDir = topDir / 'aggregated'

outDir.mkdir(parents=True, exist_ok=True)

dirPaths = [topDir / x for x in os.listdir(topDir) if x != 'aggregated']

for thisDirPath in dirPaths:

    print(thisDirPath)

    simKey = thisDirPath.name

    infUgaPath = thisDirPath / "mask_uga_hole_drop.png"
    infUgaOutPath = outDir / ("mask_uga_hole_drop_" + simKey + ".png")

    if infUgaPath.exists():
        shutil.copy(infUgaPath, infUgaOutPath)

    infKamPath = thisDirPath / "mask_uga_kam_drop.png"
    infKamOutPath = outDir / ("mask_uga_kam_drop_" + simKey + ".png")

    if infKamPath.exists():
        shutil.copy(infKamPath, infKamOutPath)

    for plotKey in ['plotA', 'plotB', 'plotC']:

        posteriorPath = thisDirPath / (plotKey + ".png")
        posteriorOutPath = outDir / (plotKey + "_" + simKey + ".png")

        if posteriorPath.exists():
            shutil.copy(posteriorPath, posteriorOutPath)
