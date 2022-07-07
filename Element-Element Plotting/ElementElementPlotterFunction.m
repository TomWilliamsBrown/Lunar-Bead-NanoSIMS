function ElementElementPlotterFunction(Excel_file, directoryname, elementelementsavefolder, saveplots, xaxiselement, counter, max_counter)
%
% This function plots element counts of one element on the x axis against
% element counts of the other elements on the y axis.
%
% The form of this function is:
% ElementElementPlotterFunction(Excel_file, directoryname,elementelementdirectoryname ,saveplots, xaxiselement)
%
% The element on the x axis is specified by xaxiselement. Enter as text,
% e.g. 'Br'
%
% Excel_file is the name of the excel file that contains the counts and
% standard deviations for each element. These are found in the directory
% directoryname.
%
% If saveplots is set to 1, the plots produced by this function will be
% saved in the directory elementelementdirectoryname. The names of the
% images will be saved in the format samplename_elementonxaxis_X.png,
% e.g. LunarBeadH_1_Cu.png
%
% Counter and max_counter are used for displaying putputs while running.

tStart = tic;

close all;

%% Convert to character arrays
%--------------------------------------------------------------------------
xaxiselement = char(xaxiselement);
directoryname = char(directoryname);
Excel_file = char(Excel_file);

%% Read the Excel file every analysis

T = readtable([directoryname, '/', Excel_file, '.xlsx'], 'VariableNamingRule', 'preserve');

elementelementplots(T, elementelementsavefolder, Excel_file, saveplots, xaxiselement)

    function elementelementplots(T, elementelementsavefolder, Excel_file, saveplots, xaxiselement)
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

        num_layers = length(T.Br_counts);

        %% Labelling
        %------------------------------------------------------------------
        numbers = [(1:num_layers)]'; %#ok<NBRAK>
        labels = num2cell(num2str(numbers));
        
        %numbers = 1:num_layers;
        slicednumbers = [(1:3:num_layers)]';

        % Colours

        colours = colormap;
        dividing_interval = floor(length(colours)/num_layers);
        colours = colours(1:dividing_interval:end, :); % Only include every few rows
        colours = colours(1:num_layers, :); %Remove the excess rows

        %

        figure()

        subplot(2, 2, 1)
        hold on
        for i = 1:num_layers
            errorbar(xaxis(i), yaxis1(i), yaxiserror1(i), yaxiserror1(i), xaxiserror(i), xaxiserror(i), '.', 'Color', colours(i, :));
        end
        labelpoints(xaxis(slicednumbers), yaxis1(slicednumbers), labels(slicednumbers,:), 'Color', colours(slicednumbers,:));
        hold off
        xlabel([xaxiselement, ' Counts'])
        ylabel([yaxiselement1, ' Counts'])

        subplot(2, 2, 2)
        hold on
        for i = 1:num_layers
            errorbar(xaxis(i), yaxis2(i), yaxiserror2(i), yaxiserror2(i), xaxiserror(i), xaxiserror(i), '.', 'Color', colours(i, :));
        end
        labelpoints(xaxis(slicednumbers), yaxis2(slicednumbers), labels(slicednumbers,:), 'Color', colours(slicednumbers,:));
        hold off
        xlabel([xaxiselement, ' Counts'])
        ylabel([yaxiselement2, ' Counts'])

        subplot(2, 2, 3)
        hold on
        for i = 1:num_layers
            errorbar(xaxis(i), yaxis3(i), yaxiserror3(i), yaxiserror3(i), xaxiserror(i), xaxiserror(i), '.', 'Color', colours(i, :));
        end
        labelpoints(xaxis(slicednumbers), yaxis3(slicednumbers), labels(slicednumbers,:), 'Color', colours(slicednumbers,:));
        hold off
        xlabel([xaxiselement, ' Counts'])
        ylabel([yaxiselement3, ' Counts'])

        subplot(2, 2, 4)
        hold on
        for i = 1:num_layers
            errorbar(xaxis(i), yaxis4(i), yaxiserror4(i), yaxiserror4(i), xaxiserror(i), xaxiserror(i), '.', 'Color', colours(i, :));
        end
        labelpoints(xaxis(slicednumbers), yaxis4(slicednumbers), labels(slicednumbers,:), 'Color', colours(slicednumbers,:));
        hold off
        xlabel([xaxiselement, ' Counts'])
        ylabel([yaxiselement4, ' Counts'])

        %% Resize Figures

        colours = gcf;
        colours.Position(3:4) = [1000, 500];

        %shg % Show Figure

        %% Save Plots

        if saveplots

            saveas(gca, ['Element-Element-Plotting/', char(elementelementsavefolder), '/', char(Excel_file), '_', xaxiselement, '.png']);

        end


    end

fprintf(['Figure ', num2str(counter), '/', num2str(max_counter), ': '])
tEnd = toc(tStart);
fprintf(['est. time remaining: ', num2str((max_counter - counter)*tEnd), ' s \n'])

end
