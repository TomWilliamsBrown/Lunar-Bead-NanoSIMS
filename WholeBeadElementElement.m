%% Plot all analyses for each individual bead together

close all;
clear;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Element - Element Plots

%% Five Input Steps:

% [1] Choose which elements you want on the x axis:
% Total possible = {'F','Cl','Cu','Br','I'}
xaxiselements = {'Cl', 'F','Cu','Br','I'};

% [2] Where the excel files with the count data are saved:
directoryname = {'Cs Beam Excel Files electron'};

% [3] Which excel file(s) are to be used:
% Must be in format 'LunarBead[beadletter]_[analysisnumber]'
% e.g 'LunarBeadE_1'
Excel_files = {'LunarBeadE_1', ...
    'LunarBeadH_1', 'LunarBeadH_2', 'LunarBeadH_3', 'LunarBeadH_4', ...
    'LunarBeadI_1', 'LunarBeadI_2', 'LunarBeadI_3', ...
    'LunarBeadJ_1', 'LunarBeadJ_2', 'LunarBeadJ_3'};

% [4] Where to save the results:
elementelementdirectoryname = {'recursive MULTIPLE Element-Element Plots Test'};

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

beadnames = extractBetween(Excel_files,'Bead','_');
uniquebeads = unique(beadnames);

%%%%%%%%%%%%% Turn this into a for loop for all the excel files

%% Join all excel files

for beadnumber = 1:numel(uniquebeads)

T = [];

beadsiteindices = find(contains(beadnames,uniquebeads(beadnumber)));

for i = 1:numel(find(contains(beadnames,uniquebeads(beadnumber))))
    
    excelindex = beadsiteindices(i);
    Tnew = readtable([char(directoryname), '/', char(Excel_files(excelindex)), '.xlsx'], 'VariableNamingRule', 'preserve');
    T = [T;Tnew];

end

%% Then do bookeeping with 1 Excel file

numfiles = numel(find(contains(beadnames,uniquebeads(beadnumber))));

% Get name of bead

beadname = char(uniquebeads(beadnumber));

%% Iterate through every element

for j = 1:numel(xaxiselements)
    
    elementelementplots(T, elementelementdirectoryname, beadname, SavePlots_YN, char(xaxiselements(j)),numfiles)
    close all
end

end
%elementelementplots(T, elementelementdirectoryname, beadname, SavePlots_YN, 'Cl',numfiles)

    function elementelementplots(T, elementelementdirectoryname, beadname, SavePlots_YN, xaxiselement,numfiles)
        %When called, this function actually produces each individual element-element plot

        if strcmp(xaxiselement, 'F')

            xaxis = T.F_counts;
            xaxiserror = T.F_std;

            yaxis1 = T.Cl_counts;
            yaxiserror1 = T.Cl_std;
            yaxiselement1 = 'Cl';

            yaxis2 = T.Cu_counts;
            yaxiserror2 = T.Cu_std;
            yaxiselement2 = 'Cu';

            yaxis3 = T.Br_counts;
            yaxiserror3 = T.Br_std;
            yaxiselement3 = 'Br';

            yaxis4 = T.I_counts;
            yaxiserror4 = T.I_std;
            yaxiselement4 = 'I';

        elseif strcmp(xaxiselement, 'Cl')

            xaxis = T.Cl_counts;
            xaxiserror = T.Cl_std;

            yaxis1 = T.Br_counts;
            yaxiserror1 = T.Br_std;
            yaxiselement1 = 'Br';

            yaxis2 = T.Cu_counts;
            yaxiserror2 = T.Cu_std;
            yaxiselement2 = 'Cu';

            yaxis3 = T.F_counts;
            yaxiserror3 = T.F_std;
            yaxiselement3 = 'F';

            yaxis4 = T.I_counts;
            yaxiserror4 = T.I_std;
            yaxiselement4 = 'I';

        elseif strcmp(xaxiselement, 'Cu')

            xaxis = T.Cu_counts;
            xaxiserror = T.Cu_std;

            yaxis1 = T.Cl_counts;
            yaxiserror1 = T.Cl_std;
            yaxiselement1 = 'Cl';

            yaxis2 = T.Br_counts;
            yaxiserror2 = T.Br_std;
            yaxiselement2 = 'Br';

            yaxis3 = T.F_counts;
            yaxiserror3 = T.F_std;
            yaxiselement3 = 'F';

            yaxis4 = T.I_counts;
            yaxiserror4 = T.I_std;
            yaxiselement4 = 'I';

        elseif strcmp(xaxiselement, 'I')

            xaxis = T.I_counts;
            xaxiserror = T.I_std;

            yaxis1 = T.Cl_counts;
            yaxiserror1 = T.Cl_std;
            yaxiselement1 = 'Cl';

            yaxis2 = T.Cu_counts;
            yaxiserror2 = T.Cu_std;
            yaxiselement2 = 'Cu';

            yaxis3 = T.F_counts;
            yaxiserror3 = T.F_std;
            yaxiselement3 = 'F';

            yaxis4 = T.Br_counts;
            yaxiserror4 = T.Br_std;
            yaxiselement4 = 'Br';

        elseif strcmp(xaxiselement, 'Br')

            xaxis = T.Br_counts;
            xaxiserror = T.Br_std;

            yaxis1 = T.Cl_counts;
            yaxiserror1 = T.Cl_std;
            yaxiselement1 = 'Cl';

            yaxis2 = T.Cu_counts;
            yaxiserror2 = T.Cu_std;
            yaxiselement2 = 'Cu';

            yaxis3 = T.F_counts;
            yaxiserror3 = T.F_std;
            yaxiselement3 = 'F';

            yaxis4 = T.I_counts;
            yaxiserror4 = T.I_std;
            yaxiselement4 = 'I';
            

        else

            error("Not a valid input element. Enter, 'F', 'Cl, 'Cu', 'Br', or 'I'.")

        end

        % Find number of layers

        num_rows = length(T.Br_counts);

        % Labelling

        numbers = [(1:num_rows)]'; %#ok<NBRAK>
        labels = num2cell(num2str(numbers));

        % Colours
        % We want there to be the same number of colours as files
        colours = colormap;
        dividing_interval = round(linspace(1,length(colours),numfiles));
        colours = colours(dividing_interval, :); % Only include every few rows
        
        %% Then for rainbow on each
        
        rainbowcolours = colormap;
        rainbow_dividing_interval = round(linspace(1,length(rainbowcolours),num_rows/numfiles));
        rainbowcolours = rainbowcolours(rainbow_dividing_interval, :); % Only include every few rows
        

        %
%% Try replacing for loop where errorbar is created every point, to slicing the table into each site, and plot 
% them seperately - should be a few plots, instead of a few hundred!
        figure('Name',['Bead ', beadname])

        subplot(2, 2, 1)
        
        hold on
        for j = 1:numfiles
            
            rainbowcount = 0;
            for i = ((j-1)*num_rows/numfiles + 1):(num_rows/numfiles)*j
                
                rainbowcount = rainbowcount+1;
                if (yaxis1(i) - yaxiserror1(i)) > 0
                e = errorbar(xaxis(i), yaxis1(i), yaxiserror1(i), yaxiserror1(i), xaxiserror(i), xaxiserror(i), '.', 'Color', rainbowcolours(rainbowcount,:));
                set(get(e,'Parent'), 'YScale', 'log')
                set(get(e,'Parent'), 'XScale', 'log')
                end
                
            end

        end

        hold off
        xlabel([xaxiselement, ' Counts'])
        ylabel([yaxiselement1, ' Counts'])

        subplot(2, 2, 2)
        
       hold on
        
        for j = 1:numfiles
            rainbowcount = 0;
            for i = ((j-1)*num_rows/numfiles + 1):(num_rows/numfiles)*j
                rainbowcount = rainbowcount+1;
                if (yaxis2(i) - yaxiserror2(i)) > 0
                e = errorbar(xaxis(i), yaxis2(i), yaxiserror2(i), yaxiserror2(i), xaxiserror(i), xaxiserror(i), '.', 'Color', rainbowcolours(rainbowcount,:));
                set(get(e,'Parent'), 'YScale', 'log')
                set(get(e,'Parent'), 'XScale', 'log')
                end
            end

        end

        hold off
        xlabel([xaxiselement, ' Counts'])
        ylabel([yaxiselement2, ' Counts'])

        subplot(2, 2, 3)
        
        hold on
        
        for j = 1:numfiles
            rainbowcount = 0;
            for i = ((j-1)*num_rows/numfiles + 1):(num_rows/numfiles)*j
                rainbowcount = rainbowcount+1;
                if (yaxis3(i) - yaxiserror3(i)) >= 0.1
                e = errorbar(xaxis(i), yaxis3(i), yaxiserror3(i), yaxiserror3(i), xaxiserror(i), xaxiserror(i), '.', 'Color', rainbowcolours(rainbowcount,:));
                set(get(e,'Parent'), 'YScale', 'log')
                set(get(e,'Parent'), 'XScale', 'log')
                end
            end

        end

        hold off
        xlabel([xaxiselement, ' Counts'])
        ylabel([yaxiselement3, ' Counts'])

        subplot(2, 2, 4)
        
        hold on
        
        for j = 1:numfiles
            rainbowcount = 0;
            for i = ((j-1)*num_rows/numfiles + 1):(num_rows/numfiles)*j
                rainbowcount = rainbowcount + 1;
                if (yaxis4(i) - yaxiserror4(i)) > 0
                e = errorbar(xaxis(i), yaxis4(i), yaxiserror4(i), yaxiserror4(i), xaxiserror(i), xaxiserror(i), '.', 'Color', rainbowcolours(rainbowcount,:));
                set(get(e,'Parent'), 'YScale', 'log')
                set(get(e,'Parent'), 'XScale', 'log')
                end
            end

        end

        hold off
        xlabel([xaxiselement, ' Counts'])
        ylabel([yaxiselement4, ' Counts'])

        %% Resize Figures

        colours = gcf;
        colours.Position(3:4) = [1000, 500];

        % shg % Show Figure

        %% Save Plots

        if SavePlots_YN

            saveas(gca, [char(elementelementdirectoryname), '/', char(beadname), '_', xaxiselement, '.png']);

        end


    end
    
