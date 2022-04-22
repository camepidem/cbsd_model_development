from paramiko import SSHClient
from scp import SCPClient
import pandas as pd
from pathlib import Path

ssh = SSHClient()
ssh.load_system_host_keys()
ssh.connect(hostname='',
            username='',
            password='') # WARNING: DON'T LEAVE PASSWORD HARDCODED HERE

scp = SCPClient(ssh.get_transport())

# Read pass keys
passKeysDfPath = '../analysis/results_validation/fitting_output/model_3/2022_03_18_batch_0/survey_data_C/survey_data_C/2022_03_21_102007_2022_02_07_validation/grid-tol_applied_only_where_both_bool-0.48_mask_0/passKeys.csv'

batchStr = 'validation/sim_output/model_3/2022_03_18_batch_0/'

# --------------------------------------------

rootLocal = Path('./')
rootRemote = Path('/rds/project/rds-GzjXVr9dEIE/epidem-userspaces/dsg38/cbsd_landscape_model/simulations/')

batchPathLocal = rootLocal / batchStr
batchPathRemote = rootRemote / batchStr

passKeysDf = pd.read_csv(passKeysDfPath)

passKeys = list(passKeysDf['passKeys'])

passJobs = [x.split('_')[-2] for x in passKeys]

for thisJob in passJobs:

    thisJobPathLocal = batchPathLocal
    thisJobPathRemote = Path(batchPathRemote, thisJob)

    print(thisJobPathLocal)
    print(thisJobPathRemote)

    thisJobPathLocal.mkdir(parents=True, exist_ok=True)

    scp.get(thisJobPathRemote, thisJobPathLocal, recursive=True)

scp.close()
