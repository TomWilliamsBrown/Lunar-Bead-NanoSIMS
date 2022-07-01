# Import-and-Cycle-Plotting

These matlab scripts are used primarily to extract data from the NanoSIMS into a readable format (calling the files saved in 'Initial Processing').
They also create plots of counts against cycle number.

NanoSIMS_Import_Control.m and NanoSIMSImportFunction.m extract the data from .im files produced by the Cameca NanoSIMS 50L. They then process it, and save 
the counts by cycle, and standard errors by cycle, for each individual element. These are saved as .xlsx files for readability (normalised by electron counts in Excel Files electron). 

They also contain an option to plot the counts against cycle for each individual site analysed ('cycle-element figures'). The resulting figures are saved 
in 'Individual Cycle-Element Figures'.

To create cycle-element figures that combine all of the sites on each bead (e.g. all sites on Bead A plot together), Whole_Bead_Cycle_Count_Plotting.m 
is used. The resulting figures are saved in 'Whole Bead Cycle-Element Figures'.

