# Lunar-Bead-NanoSIMS

This repo contains code used to analyse and visualise data collected using NanoSIMS

Five files are needed to intitially process data colleted by the NanoSIMS: read_im_file_ro.m, readNanoSIMSimage.m, read_bytes.m, remove_blanks.m, and wmean.m

NanoSIMS_Import_Control.m calls the function NanoSIMSImportfunction.m. Together they create excel files for each analysis with counts and standard errors for each cycle, and create plots of counts against cycle number.

ElementElementPlot_control.m and ElementElementPlotterFunction.m create plots of an element on the x-axis against another element on the y-axis for each individual analysis. WholeBeadElementElement.m does the same but combines all analyses on one bead into one. The aim is to eventually combine these into one, more versatile script, if I have spare time. 

labelpoints.m and errorplotterfunction.m are used in plotting figures.
