# Element-Element Plotting

This folder contains codes to plot figures with an element on each axis (element-element plots), as well as the resulting figures.

To create element-element plots for each individual analysis, use Element-ElementPlot_Control.m and ElementElementPlotterFunction.m. Parameters 
(e.g. the excel files to be read, where figures are to be saved) are altered in Element-ElementPlot_Control.m, and this is the only code that should
be routinely modified.

To create element-element plots where the seperate sitse on each individual bead are grouped together, use WholeBeadElementElement.m. For example, if I 
have 3 measurements on Bead A, and 5 on Bead B, this script will create two plots, and the sites in each bead are all plotted next to one another).

The figures created by these scripts are stored in 'Whole Bead Element Element Plots' and 'Individual Element Element Plots'.
