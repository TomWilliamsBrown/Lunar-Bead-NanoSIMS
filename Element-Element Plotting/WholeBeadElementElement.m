%% Multiple Element Plots

close all;
clear;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Element - Element Plots

%% Five Input Steps:

% [1] Choose which elements you want on the x axis:
% Total possible = {'F','Cl','Cu','Br','I'}
% xaxiselements = {'Cl', 'F', 'Cu', 'Br', 'I'};
xaxiselements = {'Cl'};

% [2] Where the excel files with the count data are saved:
directoryname = {'Excel Files electron'};

% [3] Which excel file(s) are to be used:
% Must be in format 'LunarBead[beadletter]_[analysisnumber]'
% e.g 'LunarBeadE_1'
Excel_files = {'LunarBeadE_1', ...
    'LunarBeadH_1', 'LunarBeadH_2', 'LunarBeadH_3', 'LunarBeadH_4', ...
    'LunarBeadI_1', 'LunarBeadI_2', 'LunarBeadI_3', ...
    'LunarBeadJ_1', 'LunarBeadJ_2', 'LunarBeadJ_3'};
% Excel_files = {'LunarBeadI_1', 'LunarBeadI_2', 'LunarBeadI_3'};

% [4] Where to save the results:
elementelementdirectoryname = {'Whole Bead Element Element Plots'};

% [5] Save plots? 1 for yes, 0 for no
SavePlots_YN = 1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Don't routinely alter anything below this line!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Check if the directory already exists
% If it does, ask if you want to delete the contents.
% If yes, delete the contents

if isfolder(elementelementdirectoryname)

    prompt = (['The following folder already exists: ', char(elementelementdirectoryname), '\n', 'Press any key to delete and continue']);
    input(prompt)

    % Delete contents if it already exists

    % Get a list of all files in the folder
    filePattern = fullfile(char(elementelementdirectoryname));
    % Then delete the ones with a .png extension:
    delete([filePattern, '/*.png'])
    % Say that they've been deleted
    fprintf('Files Deleted. Starting figure creation. \n')

else %If it doesn't already exist, make it!:

    [status, msg, msgID] = mkdir(char(elementelementdirectoryname));

end

%%%%% Get the beads

beads_by_site = extractBetween(Excel_files, 'Bead', '_');
uniquebeads = unique(beads_by_site);

%%%%%%%%%%%%% Turn this into a for loop for all the excel files

%% Join all excel files

for beadnumber = 1:numel(uniquebeads)

    T = [];

    beadsiteindices = find(contains(beads_by_site, uniquebeads(beadnumber)));

    for i = 1:numel(find(contains(beads_by_site, uniquebeads(beadnumber))))

        excelindex = beadsiteindices(i);
        Tnew = readtable([char(directoryname), '/', char(Excel_files(excelindex)), '.xlsx'], 'VariableNamingRule', 'preserve');
        T = [T; Tnew];

    end

    %% Then do bookeeping with 1 Excel file

    numfiles = numel(find(contains(beads_by_site, uniquebeads(beadnumber))));

    % Get name of bead

    beadname = char(uniquebeads(beadnumber));

    %% Iterate through every element

    for j = 1:numel(xaxiselements)

        elementelementplots(T, elementelementdirectoryname, beadname, SavePlots_YN, char(xaxiselements(j)), numfiles)
        close all
    end

end

set(0, 'DefaultFigureVisible', 'on') % Allow plots to pop up on screen again

function elementelementplots(T, elementelementdirectoryname, beadname, SavePlots_YN, xaxiselement, numfiles)
%When called, this function actually produces each individual element-element plot

%% Here we control what gets plotted on the x and y axis
yaxis = [T.F_counts, T.Cl_counts, T.Cu_counts, T.Br_counts, T.I_counts];
yaxiserror = [T.F_std, T.Cl_std, T.Cu_std, T.Br_std, T.I_std];
yaxiselement = {'F', 'Cl', 'Cu', 'Br', 'I'};


if strcmp(xaxiselement, 'F')

    xaxis = T.F_counts;
    xaxiserror = T.F_std;

    yaxis(:, 1) = [];
    yaxiserror(:, 1) = [];
    yaxiselement(1) = [];

elseif strcmp(xaxiselement, 'Cl')

    xaxis = T.Cl_counts;
    xaxiserror = T.Cl_std;

    yaxis(:, 2) = [];
    yaxiserror(:, 2) = [];
    yaxiselement(2) = [];

elseif strcmp(xaxiselement, 'Cu')

    xaxis = T.Cu_counts;
    xaxiserror = T.Cu_std;

    yaxis(:, 3) = [];
    yaxiserror(:, 3) = [];
    yaxiselement(3) = [];

elseif strcmp(xaxiselement, 'Br')

    xaxis = T.Br_counts;
    xaxiserror = T.Br_std;

    yaxis(:, 4) = [];
    yaxiserror(:, 4) = [];
    yaxiselement(4) = [];

elseif strcmp(xaxiselement, 'I')

    xaxis = T.I_counts;
    xaxiserror = T.I_std;

    yaxis(:, 5) = [];
    yaxiserror(:, 5) = [];
    yaxiselement(:, 5) = [];

else

    error("Not a valid input element. Enter: 'F', 'Cl, 'Cu', 'Br', or 'I'.")

end

% Find number of layers

num_rows = length(T.Br_counts);

% Labelling

numbers = [(1:num_rows)]'; %#ok<NBRAK>
labels = num2cell(num2str(numbers));

% Colours
% We want there to be the same number of colours as files
colours = colormap;
dividing_interval = round(linspace(1, length(colours), numfiles));
colours = colours(dividing_interval, :); % Only include every few rows

%% Then for rainbow on each

rainbowcolours = colormap;
rainbow_dividing_interval = round(linspace(1, length(rainbowcolours), num_rows/numfiles));
rainbowcolours = rainbowcolours(rainbow_dividing_interval, :); % Only include every few rows

%% Make the Marker

marker = char({'.' 'x' '^' '+'});


set(0, 'DefaultFigureVisible', 'off') % Stop plots from popping up on screen

%% Try replacing for loop where errorbar is created every point, to slicing the table into each site, and plot
% them seperately - should be a few plots, instead of a few hundred!
figure('Name', ['Bead ', beadname])

for i = 1:4

    subplot(2, 2, i)
    coloursubplotter(numfiles, num_rows, xaxis, xaxiserror, xaxiselement, yaxis(:, i), yaxiserror(:, i), yaxiselement(i), rainbowcolours, marker);

end

%% Resize Figures

colours = gcf;
colours.Position(3:4) = [1000, 500];

% shg % Show Figure

%% Save Plots

if SavePlots_YN

    saveas(gca, [char(elementelementdirectoryname), '/Bead: ', char(beadname), '_', xaxiselement, '.png']);

end


end

function coloursubplotter(numfiles, num_rows, xaxis, xaxiserror, xaxiselement, yaxis, yaxiserror, yaxiselement, colourmap, marker)

yaxiselement = char(yaxiselement);

hold on

for j = 1:numfiles

    colourcount = 0;
    for i = ((j - 1) * num_rows / numfiles + 1):(num_rows / numfiles) * j
        colourcount = colourcount + 1;
        if (yaxis(i) - yaxiserror(i)) > 0.1 && (xaxis(i) - xaxiserror(i)) > 0.1
            % Some errorbars go very close to zero. Cutting these out so
            % that the log plot doesn't look bad. IS THIS OK TO DO?
            e = errorbar(xaxis(i), yaxis(i), yaxiserror(i), yaxiserror(i), xaxiserror(i), xaxiserror(i), marker(j), 'Color', colourmap(colourcount, :));
            set(get(e, 'Parent'), 'YScale', 'log')
            set(get(e, 'Parent'), 'XScale', 'log')
        end

    end
    
%% Numbering Points
    
%         numberpoint = 1:50;
%         numberpoint2 = repmat(numberpoint,1,3);
%         
%         lengthnum = numel(numberpoint2);
%         iteratedlabels = 1:7:lengthnum;
%         
%         numbereveryn = numberpoint2(1, iteratedlabels);
%         xaxiseveryn = xaxis(iteratedlabels, 1); % Only include every few rows
%         yaxiseveryn = yaxis(iteratedlabels, 1); % Only include every few rows
%         
%         labelpoints(xaxiseveryn, yaxiseveryn, numbereveryn);

end

hold off
xlabel([xaxiselement, ' Counts'])
ylabel([yaxiselement, ' Counts'])

end
