#!/usr/bin/python3
import pdb
import numpy
import pandas as pd
import os
import shutil
from scipy.interpolate import interp1d
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


#--------------
num_strips = 100
density_val = 1
log_transform_y = True

model = 'model_0B'
outfilename = '2021_03_11_higher'

#--------------

out_folder = os.path.join(model, 'fitting')
copy_prior_in_path = os.path.join(out_folder, outfilename + '_prior_in.csv')
plot_path = os.path.join(out_folder, outfilename + '_plot.png')

out_path = os.path.join(out_folder, outfilename + '.txt')

os.makedirs(out_folder, exist_ok=True)


interesting_spec_path = 'prior_in.csv'
boring_spec_path = 'boring_in.csv'

density_label = 'Density'
nparams_label = 'nParameters'
nentries_label = 'nEntries'

which_param_prefix = 'Parameter_'
which_param_suffix = '_SampleLogSpace 1'


shutil.copy(interesting_spec_path, copy_prior_in_path)

# -------------------------------

x_y_vals = pd.read_csv(interesting_spec_path, index_col=False, skipinitialspace=True)

x_vals = x_y_vals['Kernel_0_Parameter']
y_min = x_y_vals['Rate_0_Sporulation_min']
y_max = x_y_vals['Rate_0_Sporulation_max']

plt.plot(x_vals, y_min, 'r')
plt.plot(x_vals, y_max, 'b')
plt.axis([0, 8, 0, 15])
plt.savefig(plot_path)


x_y_param_names = list(x_y_vals.columns.values)

x_param = x_y_param_names[0]
y_min_param = x_y_param_names[1]
y_max_param = x_y_param_names[2]
y_param = y_min_param.split("_min")[0]

prior_points_sorted = x_y_vals.sort_values(x_param)

x_min = prior_points_sorted[x_param].min()
x_max = prior_points_sorted[x_param].max()
x_range = x_max - x_min
dx = x_range / num_strips

lower_interp = interp1d(prior_points_sorted[x_param], prior_points_sorted[y_min_param])
upper_interp = interp1d(prior_points_sorted[x_param], prior_points_sorted[y_max_param])

out_data_dict = {}
out_data_dict['x_min'] = []
out_data_dict['x_max'] = []
out_data_dict['y_min'] = []
out_data_dict['y_max'] = []

out_data_dict[density_label] = density_val

current_x_min = x_min
for i in range(num_strips):

    # print(i)

    y_lower_val = float(lower_interp(current_x_min))
    y_upper_val = float(upper_interp(current_x_min))


    out_data_dict['x_min'].append(current_x_min)
    out_data_dict['x_max'].append(current_x_min + dx)

    out_data_dict['y_min'].append(y_lower_val)
    out_data_dict['y_max'].append(y_upper_val)

    current_x_min += dx

out_data = pd.DataFrame.from_dict(out_data_dict)

if log_transform_y:
    out_data['y_min'] = out_data['y_min'].apply(numpy.exp)
    out_data['y_max'] = out_data['y_max'].apply(numpy.exp)

out_data = out_data[[density_label, 'x_min', 'x_max', 'y_min', 'y_max']]
x_y_out_header_list = [density_label, x_param, y_param]


#----------------------

boring_param_data = pd.read_csv(boring_spec_path, index_col=False, skipinitialspace=True)

boring_header_list = []
boring_log_list = []
for index, row in boring_param_data.iterrows():

    thisParamName = row['param_name']

    print(thisParamName)

    if row['log_me'] == 1:

        boring_log_list.append(thisParamName)


    out_data[thisParamName + '_min'] = row['min']
    out_data[thisParamName + '_max'] = row['max']
    boring_header_list.append(thisParamName)

#----------------------

all_header = x_y_out_header_list + boring_header_list
all_header_str = " ".join(all_header)
nparams = len(all_header) - 1


f = open(out_path, 'w')
f.write(nparams_label + ' ' + str(nparams) + '\n')
f.write(nentries_label + ' ' + str(num_strips) + '\n')

if log_transform_y:
    f.write(which_param_prefix + '1' + which_param_suffix + '\n')


for logHeader in boring_log_list:

    for iHeader, thisHeader in enumerate(all_header):
        if logHeader == thisHeader:
            f.write(which_param_prefix + str(iHeader - 1) + which_param_suffix + '\n')


f.write(all_header_str + '\n')
f.close()

f = open(out_path, 'a')
out_data.to_csv(f, index=False, sep=' ', header=False)
f.close()

print(out_path)
