#!/usr/bin/python3

import sys, pdb
import time
import pmpem.mngr, pmpem.utils, pmpem.landscape
from pmpem.pmpemopts import PmpemOpts
import numpy as np
import pandas as pd
import subprocess
import os
import re
import ast

writeRasters = 0

surveyTimingJson = '{"2005":"2004_raster_total.asc","2006":"2005_raster_total.asc","2007":"2006_raster_total.asc","2008":"2007_raster_total.asc","2009":"2008_raster_total.asc","2010":"2009_raster_total.asc","2011":"2010_raster_total.asc","2012":"2011_raster_total.asc","2013":"2012_raster_total.asc","2014":"2013_raster_total.asc","2015":"2014_raster_total.asc","2016":"2015_raster_total.asc","2018":"2017_raster_total.asc"}'

## Sets the parameters of the MPEM model.
def setmodelparameters(x=None):

	# Generate the PMPEM parameters
	opts=PmpemOpts(0)
	opts.setParamsToDefault()

	opts.changempemparams('SimulationStartTime', x['SimulationStartTime'])
	opts.changempemparams('SimulationLength', x['SimulationLength'])
	opts.changempemparams('BatchEnable', 0)
	opts.changempemparams('BatchRuns', 1)

	opts.changempemparams('Model', 'SI')
	opts.changempemparams('MaxHosts', 1000)
	opts.changempemparams('Kernel_0_Type', x['Kernel_0_Type'])
	opts.changempemparams('Kernel_0_Parameter', 1)
	opts.changempemparams('Kernel_0_WithinCellProportion', 1)
	opts.changempemparams('Kernel_0_Range', 500)
	opts.changempemparams('Kernel_0_VirtualSporulationTransition', 1.0)
	opts.changempemparams('Kernel_0_VirtualSporulationTransitionByRange', x['Kernel_0_VirtualSporulationTransitionByRange'])
	opts.changempemparams('Rate_0_Sporulation', 1)
	opts.changempemparams('DPCFrequency', 0.25)
	opts.changempemparams('DPCTimeFirst', 0)
	opts.changempemparams('WeatherEnable', x['WeatherEnable'])
	opts.changempemparams('WeatherFileName', 'P_WeatherSwitchTimes.txt')
	opts.changempemparams('ManagementEnable', 1)
	opts.changempemparams('ManagementDetectionProbability', x['ManagementDetectionProbability'])
	opts.changempemparams('ManagementSurveillanceTimesAndFiles', surveyTimingJson)

	opts.changempemparams('RasterEnable', writeRasters)
	opts.changempemparams('RasterFrequency', writeRasters)
	opts.changempemparams('RasterFirst', writeRasters)
	opts.changempemparams('RasterDisable_ALL', writeRasters)
	opts.changempemparams('RasterEnable_0_INFECTIOUS', writeRasters)

	return opts


def processonerun(folder):
	results = pmpem.utils.getparamsandsummarystats(folder)
	return 1

def processallruns(outputpath, runfolders):
	pmpem.utils.combineresultsfiles(outputpath, runfolders)
	return 1


if __name__ ==  '__main__':
	start = time.time()

	outputpath = 'output'

	#processonerun("ManagementFits/job0/output/runfolder0/")


	############################################################################
	# Initialise the object with reference to the functions that
	# generate the run folders and the generation of simulation parameters
	mngr = pmpem.mngr.mngr( outputpath=outputpath,
							genfoldersfunc=None,
							setmodelparametersfunc=setmodelparameters,
							processonerunfunc=processonerun,
							processallrunsfunc=processallruns)


	############################################################################
	# Do the runs and process the results
	mngr.runoperation(nbatchrunscatofftime=7200)

	end = time.time()
	print("Simulations execution time: ", end - start, " seconds.")
