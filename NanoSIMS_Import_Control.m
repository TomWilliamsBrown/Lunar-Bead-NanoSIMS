%% Cs Beam Matlab Control Panel


list_of_im_files = {'LunarBeadE_1.im', ...
    'LunarBeadH_1.im', 'LunarBeadH_2.im', 'LunarBeadH_3.im', 'LunarBeadH_4.im', ...
    'LunarBeadI_1.im', 'LunarBeadI_2.im', 'LunarBeadI_3.im', ...
    'LunarBeadJ_1.im', 'LunarBeadJ_2.im', 'LunarBeadJ_3.im'};


%list_of_im_files = {'LunarBeadE_1.im'};
% Directory name where figures are saved:

Figure_directoryname = {'Cs Beam Cycle-Element Figures electron'};
Figure_directorynamelist = repmat(Figure_directoryname, 1, length(list_of_im_files));

Excel_directoryname = {'Cs Beam Excel Files electron'};
Excel_directorynamelist = repmat(Excel_directoryname, 1, length(list_of_im_files));

% Get somewhere to save the plots

[~, ~, ~] = mkdir(char(Figure_directoryname));
[~, ~, ~] = mkdir(char(Excel_directoryname));

%% Comment/Uncomment as needed
saveplots = ones(1, length(list_of_im_files)); %This will result in plots being saved
%saveplots = zeros(1, length(list_of_im_files)); %This will result in plots NOT being saved

saveexcel = ones(1, length(list_of_im_files)); %This will result in Excels being saved
%saveexcel = zeros(1, length(list_of_im_files)); %This will result in Excels NOT being saved

%% Normalise by Electron counts?

enormalise = ones(1, length(list_of_im_files));

%%
arrayfun(@NanoSIMSImportFunction, list_of_im_files, Figure_directorynamelist, Excel_directorynamelist, enormalise, saveplots, saveexcel)

%% Print the finish message

lastslash_pos = find(mfilename('fullpath') == '/', 1, 'last');
fprintf(['Finished running ', extractAfter(mfilename('fullpath'), lastslash_pos)])
