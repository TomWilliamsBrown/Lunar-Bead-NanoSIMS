%% NanoSIMS import Control Panel
%
% This calls the function NanoSIMSImportFunction for all of the files
% listed in 'list_of_im_files'. Each one of hese is the image file for
% each individual analysis carried out by the NanoSIMS.
%
% This function then gets counts for each element with each cycle in the
% NanoSIMS. It also finds the standard error of the counts.
%
% It then saves the counts and standard errors for each cycle to an excel
% file, named after the .im filem and saved in the directory
% Excel_directoryname.
%
% It also creates plots of count rate against cycle, and saves them in the
% directory Figure_directory name
%
% Saving the plots and excels is controlled by a boolean variable
%
% If you want to normalise divide by the number of electron counts, se this
% to 1.


bead_names = {'LunarBeadE_1', ...
    'LunarBeadH_1', 'LunarBeadH_2', 'LunarBeadH_3', 'LunarBeadH_4', ...
    'LunarBeadI_1', 'LunarBeadI_2', 'LunarBeadI_3', ...
    'LunarBeadJ_1', 'LunarBeadJ_2', 'LunarBeadJ_3'};


%list_of_im_files = {'LunarBeadE_1.im'};

% Directory name where figures and excel documents are saved:

Figure_directoryname = {'Cycle-Element Figures electron'};
Excel_directoryname = {'Excel Files electron'};

% save count-cycle plots?

savecountplots = 1;

% save excels?

save_excels = 1;

%normalise by electrons?

electron_normalise = 1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Don't routinely modify anything below here.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Add file name

list_of_im_files = strcat(bead_names, '.im');

% Create a list, to allow entry into arrayfun

Figure_directorynamelist = repmat(Figure_directoryname, 1, length(list_of_im_files));
Excel_directorynamelist = repmat(Excel_directoryname, 1, length(list_of_im_files));

% Get somewhere to save the plots

[~, ~, ~] = mkdir(char(Figure_directoryname));
[~, ~, ~] = mkdir(char(Excel_directoryname));

%% Here we create double arrays for saving/not saving plots and excels.
% Need as an array to input into arrayfun

if savecountplots
    saveplots = ones(1, length(list_of_im_files)); %This will result in plots being saved
else
    saveplots = zeros(1, length(list_of_im_files)); %This will result in plots NOT being saved
end

if save_excels
    saveexcel = ones(1, length(list_of_im_files)); %This will result in Excels being saved
else
    saveexcel = zeros(1, length(list_of_im_files)); %This will result in Excels NOT being saved
end

%% Here we reate double arrays for normalising/not notmalising by electron counts

if electron_normalise

    enormalise = ones(1, length(list_of_im_files));
else
    enormalise = zeros(1, length(list_of_im_files));
end

%% Now run NanoSIMSImportFunction on all of the .im files

arrayfun(@NanoSIMSImportFunction, list_of_im_files, Figure_directorynamelist, Excel_directorynamelist, enormalise, saveplots, saveexcel)

%% Print the finish message once complete

lastslash_pos = find(mfilename('fullpath') == '/', 1, 'last');
fprintf(['Finished running ', extractAfter(mfilename('fullpath'), lastslash_pos)])
