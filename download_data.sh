#!/bin/bash

root=`pwd`

# Build polygons for summary stats
cd summary_stats
Rscript gen_polys.R
cd $root

# Download surveillance data
cd input_generation/surveillance_data/raw_data
bash download_paper_data.sh
cd $root

# Download host data
cd input_generation/host_landscape/raw_host
bash download_host_data.sh
cd $root

# Download UGA district polys
cd input_generation/control_raster/inputs
bash download_polys.sh
cd $root

# Download lakes polys
cd figs_paper/host/GLWD-level1
bash download_lakes.sh
cd $root
