# Lunar-Bead-NanoSIMS

## Author: Tom Williams

This repo contains the code I use to extract and visualise data collected using the Cameca NanoSIMS 50L. If you have any questions or comments, please contact me at [Thomas_Williams@Brown.edu](mailto:Thomas_Williams@Brown.edu).

## To Do:

* Work on movie plotting
  * Turn CountMovies into a function, then call it for each .im file
  * Add scalebar
* Define Regions of Interest (ROIs)
  * What to base this on? Can I do it using the movies? Maybe stacked heatmaps?
* Label every x points (maybe 5?)

## Sections

### 1. [Initial Processing](https://github.com/TomWilliamsBrown/Lunar-Bead-NanoSIMS/tree/main/Initial_Processing)

The files needed to intitially process data colleted by the NanoSIMS are in the folder initial processing.

### 2. [Data Extraction, and Cycle-Element Plots](https://github.com/TomWilliamsBrown/Lunar-Bead-NanoSIMS/tree/main/Import-and-Cyle-Plotting)

The files in Import-and-Cycle-Plotting are used to present the data in a readable format, and save it into excel. They also create plots of element counts on the y-axis against cycle number on the x-axis.

### 3. [Element-Element Plots](https://github.com/TomWilliamsBrown/Lunar-Bead-NanoSIMS/tree/main/Element-Element%20Plotting)

The files in Element-Element Plotting create figures where a different element is plotted on each axis.

### 4. [Movies](https://github.com/TomWilliamsBrown/Lunar-Bead-NanoSIMS/tree/main/Count_Movies)

This is used to create movies of counts over time, to show spatial and temporal changes in counts.

### 5. [Plotting Functions](https://github.com/TomWilliamsBrown/Lunar-Bead-NanoSIMS/tree/main/Plotting_Functions)

The files in Plotting Functions are called by the other scripts, and used to create consistent plots.


