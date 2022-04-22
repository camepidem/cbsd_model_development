import subprocess
from pathlib import Path
from pytictoc import TicToc

t = TicToc()

configDir = Path("./results_fitting/process_config/model_2_fitting/")

configPathList = sorted(list(configDir.glob("*")))

count = 0
for configPath in configPathList:
    
    t.tic()

    cmd = [
        "Rscript",
        "process_0_gen_processed.R",
        configPath
    ]

    print(count)
    print(cmd)
    subprocess.call(cmd)

    count += 1

    t.toc()
