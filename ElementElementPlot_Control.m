close all;
clear;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Element - Element Plots

%% Five Input Steps:

% [1] Choose which elements you want on the x axis:
% Total possible = {'F','Cl','Cu','Br','I'}
%xaxiselements = {'F','Cl','Cu','Br','I'};
xaxiselements = {'Cl', 'F','Cu','Br','I'};

% [2] Where the excel files with the count data are saved:
directoryname = {'Cs Beam Excel Files'};

% [3] Which excel file(s) are to be used:
%Excel_files = {'LunarBeadE_1'}; %, 'LunarBeadH_1'};
 Excel_files = {'LunarBeadE_1', ...
    'LunarBeadH_1', 'LunarBeadH_2', 'LunarBeadH_3', 'LunarBeadH_4', ...
    'LunarBeadI_1', 'LunarBeadI_2', 'LunarBeadI_3', ...
    'LunarBeadJ_1', 'LunarBeadJ_2', 'LunarBeadJ_3'};

% [4] Where to save the results:
elementelementdirectoryname = {'Element-Element Plots'};

% [5] Save plots? 1 for yes, 0 for no
SavePlots_YN = 1;


%%%%%%%%%%%%%%%%%%%%%%%%%% Don't routinely modify anything below this line!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Check if the directory already exists
% If it does, ask if you want to delete the contents.
% If yes, delete the contents

if isfolder(elementelementdirectoryname)

    prompt = (['The following folder already exists: ', char(elementelementdirectoryname), '\n', 'Press any key to continue and delete contents']);
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

% Find number of files

numfiles = numel(Excel_files);

%% Make directory name lists
% This repeats the names for the number of files we have.
% Needed for arrayfun.

elementelementdirectorynamelist = repmat(elementelementdirectoryname, 1, numfiles);
directorynamelist = repmat(directoryname, 1, numfiles);

%% Use the input to SavePlots_YN to create an array of 1s/0s for saving/not saving

if SavePlots_YN

    % Plots will be saved
    saveplots = ones(1, numfiles);

else

    % Plots won't be saved
    saveplots = zeros(1, numfiles); %#ok<UNRCH>

end

%% Get counters for progress:

% The first counter increments from 1 to the number of files
% We need to add to this if creating files for every element!
% See figure_set_number;
counter = 1:numfiles;
figure_set_number = 0;
% This is the highest the counter will go:
maxcount = numel(xaxiselements) * numfiles;
max_counter = ones(1, numfiles) * maxcount;

%% Stop figures from appearing

set(groot, 'defaultFigureVisible', 'off')

%% Check if we have requested each element on the x axis
% If so, produce the figures with the requested element

if ismember('F', xaxiselements)
    
    xaxiselement = {'F'};
    xaxiselementlist = repmat(xaxiselement, 1, numfiles);
    arrayfun(@ElementElementPlotterFunction, Excel_files, directorynamelist, elementelementdirectorynamelist, saveplots, xaxiselementlist, counter, max_counter)
    figure_set_number = figure_set_number + 1;
end

if ismember('Cl', xaxiselements)
    
    tempcounter = counter + figure_set_number * numfiles;
    xaxiselement = {'Cl'};
    xaxiselementlist = repmat(xaxiselement, 1, numfiles);
    arrayfun(@ElementElementPlotterFunction, Excel_files, directorynamelist, elementelementdirectorynamelist, saveplots, xaxiselementlist, tempcounter, max_counter)
    figure_set_number = figure_set_number + 1;
end

if ismember('Cu', xaxiselements)
    
    tempcounter = counter + figure_set_number * numfiles;
    xaxiselement = {'Cu'};
    xaxiselementlist = repmat(xaxiselement, 1, numfiles);
    arrayfun(@ElementElementPlotterFunction, Excel_files, directorynamelist, elementelementdirectorynamelist, saveplots, xaxiselementlist, tempcounter, max_counter)
    figure_set_number = figure_set_number + 1;
end

if ismember('Br', xaxiselements)
    
    tempcounter = counter + figure_set_number * numfiles;
    xaxiselement = {'Br'};
    xaxiselementlist = repmat(xaxiselement, 1, numfiles);
    arrayfun(@ElementElementPlotterFunction, Excel_files, directorynamelist, elementelementdirectorynamelist, saveplots, xaxiselementlist, tempcounter, max_counter)
    figure_set_number = figure_set_number + 1;
end

if ismember('I', xaxiselements)
    
    tempcounter = counter + figure_set_number * numfiles;
    xaxiselement = {'I'};
    xaxiselementlist = repmat(xaxiselement, 1, numfiles);
    arrayfun(@ElementElementPlotterFunction, Excel_files, directorynamelist, elementelementdirectorynamelist, saveplots, xaxiselementlist, tempcounter, max_counter)
end

%% Allow figures to appear

set(groot, 'defaultFigureVisible', 'on')

%% Print the finish message

lastslash_pos = find(mfilename('fullpath') == '/', 1, 'last');
fprintf(['Finished running ', extractAfter(mfilename('fullpath'), lastslash_pos), '\n'])
