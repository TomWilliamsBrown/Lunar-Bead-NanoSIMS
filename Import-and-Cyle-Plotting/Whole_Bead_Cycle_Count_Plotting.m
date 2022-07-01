%%%%%%%%%%%% Whole Bead Cycle-Count Plotting

%% Description:
%
% This plots all of the measured elements on the y axis, against the cycle
% numner on the x axis
%
close all;
clear;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% Modify Parameters Here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Input Steps:

% [1] Get where the firectory in which the excel files are saved:
directoryname = {'Excel Files electron'};

% [2] Which excel file(s) are to be used:
% Must be in format 'LunarBead[beadletter]_[analysisnumber]'
% e.g 'LunarBeadE_1'

Excel_files = {'LunarBeadE_1', ...
    'LunarBeadH_1', 'LunarBeadH_2', 'LunarBeadH_3', 'LunarBeadH_4', ...
    'LunarBeadI_1', 'LunarBeadI_2', 'LunarBeadI_3', ...
    'LunarBeadJ_1', 'LunarBeadJ_2', 'LunarBeadJ_3'};

%Excel_files = {'LunarBeadI_1', 'LunarBeadI_2', 'LunarBeadI_3'};

% [3] Where to save the results:
Plotdirectoryname = {'Whole Bead Cycle-Element Plots'};

% [5] Save plots? 1 for yes, 0 for no
SavePlots_YN = 1;

% [6] Plot colours

F_colour  = '#6699CC';
Cl_colour = '#88CCEE';
Cu_colour = '#999933';
Br_colour = '#332288';
I_colour  = '#AA4499';



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% Don't routinely modify anything below this line!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Check if the directory already exists
%--------------------------------------------------------------------------

% If it does, ask if you want to delete the contents.
% If yes, delete the contents

if isfolder(Plotdirectoryname)

    % If the folder exists, tell the user. Continue if any key is pressed.
    prompt = (['The following folder already exists: ', char(Plotdirectoryname), '\n', 'Press any key to continue and delete contents']);
    input(prompt)

    % Delete contents if it already exists

    % Get a list of all files in the folder
    filePattern = fullfile(char(Plotdirectoryname));
    % Then delete the ones with a .png extension:
    delete([filePattern, '/*.png'])
    % Say that they've been deleted
    fprintf('Files Deleted. Starting figure creation. \n')

else % If it doesn't already exist, make it!

    [status, msg, msgID] = mkdir(char(Plotdirectoryname));

end

%% Stop figures from appearing
%--------------------------------------------------------------------------

set(groot, 'defaultFigureVisible', 'off')

%% Set up the grouping of sites by bead
%--------------------------------------------------------------------------

% Find which bead each individual site is on:
beads_by_site = extractBetween(Excel_files, 'Bead', '_'); %
% Finds the name of each bead:
uniquebeads = unique(beads_by_site);

% For each unique bead, combine all of the individual analyses on the bead into
% one table, and then plot each site on the bead all together.

for beadnumber = 1:numel(uniquebeads)

    % Get the name of bead currently being iterated upon:
    beadname = char(uniquebeads(beadnumber));

    % Get the indices of analyses sites on this bead from the list of all of
    % the sites.

    beadsiteindices = find(contains(beads_by_site, uniquebeads(beadnumber)));

    % For each individual site on the selected bead, plot its counts against
    % cycle number. To do this, find the number of sites, and plot by
    % iterating through them

    numsites = numel(find(contains(beads_by_site, uniquebeads(beadnumber))));

    % Create and name the figure for this bead
    f = figure('Name', ['Element Counts by Cycle: ', beadname]);

    % Set the size of the figure
    f.Position(3:4) = [1200, 600];

    % Set the number of cycles.
    ncycles = 50; %size(SBT, 1) / numsites;

    % Choose how you want each site to be plotted
    markers = char({'-o', '-x', '-^', '-*'});

    %% Now, extract the values on the site for each element, and plot
    %  using 'errorplotterfunction'
    %--------------------------------------------------------------------------

    % For each individual site on the bead, plot counts against cycle

    for i = 1:numsites

        % First, get the table for this site on this bead:
        T = readtable([char(directoryname), '/', char(Excel_files(beadsiteindices(i))), '.xlsx'], ...
            'VariableNamingRule', 'preserve');

        % Now make the scatter plots with errorbars by calling
        % errorplotterfunction
        % Leave hold on so that the plots for each site plot on top of one
        % another.

        hold on
        subplot(2, 3, 1)
        errorplotterfunction(T.F_counts, T.F_std, F_colour, 'F', ...
            ncycles, beadname, markers(i, :))
        hold on
        subplot(2, 3, 2)
        errorplotterfunction(T.Cl_counts, T.Cl_std, Cl_colour, 'Cl', ...
            ncycles, beadname, markers(i, :))
        hold on
        subplot(2, 3, 3)
        errorplotterfunction(T.Cu_counts, T.Cu_std, Cu_colour, 'Cu', ...
            ncycles, beadname, markers(i, :))
        hold on
        subplot(2, 3, 4)
        errorplotterfunction(T.Br_counts, T.Br_std, Br_colour, 'Br', ...
            ncycles, beadname, markers(i, :))
        hold on
        subplot(2, 3, 5)
        errorplotterfunction(T.I_counts, T.I_std, I_colour, 'I', ...
            ncycles, beadname, markers(i, :))

    end

    hold off
    
%% Save the plots
% If SavePlots_YN is set to 1, the plot will be saved to the plot directory
%--------------------------------------------------------------------------

    if SavePlots_YN

        saveas(gca, [char(Plotdirectoryname), '/Bead:', char(beadname),...
            ' cycle-count', '.png']);

    end

end

%% Print the finish message
%--------------------------------------------------------------------------

lastslash_pos = find(mfilename('fullpath') == '/', 1, 'last');
fprintf(['Finished running ', extractAfter(mfilename('fullpath'), lastslash_pos), '\n'])

%--------------------------------------------------------------------------