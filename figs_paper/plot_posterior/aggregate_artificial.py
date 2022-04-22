import shutil
from pathlib import Path

paperDir = Path('../../../cbsd_papers/cbsd_paper_abc/images/artificial/posterior/')

localDir = Path('./plots_artificial_model_2')

outDir = Path('./plots_artificial_model_2_agg')

outDir.mkdir(exist_ok=True)

figPathsPaper = list(paperDir.rglob('*.png'))

numRenamed = 0
for thisFigPathPaper in figPathsPaper:

    thisParts = thisFigPathPaper.parts

    plotName = thisParts[-1]

    print(thisFigPathPaper)

    thisFigPathLocal = localDir / thisParts[-3] / thisParts[-2] / plotName

    if not thisFigPathLocal.exists():
        print(thisFigPathLocal)
        raise Exception("File missing")

    outDirLocal = outDir / thisParts[-3] / thisParts[-2]
    outPath = outDirLocal / plotName

    outDirLocal.mkdir(exist_ok=True, parents=True)

    shutil.copy(thisFigPathLocal, outPath)

print(numRenamed)
