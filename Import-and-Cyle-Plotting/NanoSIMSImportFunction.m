function NanoSIMSImportFunction(filename, Figure_directoryname, Excel_directoryname, normalise, saveplots, saveexcel)
% This function exports counts and errors into Excel
% It also create plots of counts against cycle for each element

% Convert to character arrays to allow concantantion with other elements of
% where the directory/file is for access and saving.

Figure_directoryname = char(Figure_directoryname);
Excel_directoryname = char(Excel_directoryname);
filename = char(filename);

%%

close all;

%% Read the NanoSIMS Image
%--------------------------------------------------------------------------

% Get the path of the .im file you want
imfilepath = ['im files/', filename, '.im'];

% This line calls readNanoSIMSimage to get the header data
% (e.g. mass names, masses, analysis times, etc.)
[~, header_data] = readNanoSIMSimage(imfilepath);

% This line calls read_im_file_ro to get the image data.
% i.e. the counts in every pixel in every cycle for all of the masses
% analysed
[image_data, ~, ~] = read_im_file_ro(imfilepath);

%% Generate variables from the data and headers read above
%--------------------------------------------------------------------------

%mass_amu: {[18.9708]  [36.9949]  [63.0276]  [79.0000]  [127.0000]  [0]}
[F_index, Cl_index, Cu_index, Br_index, I_index, e_index] = deal(1, 2, 3, 4, 5, 6);

% Get Counting Times
countingtimes = cell2mat(header_data.Tab_mass.countingtime);

%% Get the number of pixels and cycles
n_pixels = header_data(1).Header_image.width;
ncycles = size(image_data, 3);

% Get counts for each pixel in a 256x256 image over all cycles (256x256x50 matrix)

Fcount_pixels = image_data(:, :, :, F_index);
Clcount_pixels = image_data(:, :, :, Cl_index);
Cucount_pixels = image_data(:, :, :, Cu_index);
Brcount_pixels = image_data(:, :, :, Br_index);
Icount_pixels = image_data(:, :, :, I_index);
ecount_pixels = image_data(:, :, :, e_index);

%% Remove 5 pixels around the margin
%--------------------------------------------------------------------------

marginpixels = 5;

innerpixels = false(n_pixels, n_pixels); %Creates logical array size of the image, filled with 0
innervalues = true(n_pixels-marginpixels*2, n_pixels-marginpixels*2); %The inner values that we want are 1s
innerpixels((marginpixels + 1):(end -marginpixels), (marginpixels + 1):(end -marginpixels)) = innervalues;

% Preallocate a matrix for the pixels that are not removed
n_interior = (256 - 2 * marginpixels)^2;
Fcount_pixels_interior = zeros(n_interior, ncycles);
Clcount_pixels_interior = zeros(n_interior, ncycles);
Cucount_pixels_interior = zeros(n_interior, ncycles);
Brcount_pixels_interior = zeros(n_interior, ncycles);
Icount_pixels_interior = zeros(n_interior, ncycles);
ecount_pixels_interior = zeros(n_interior, ncycles);

parfor i = 1:ncycles

    Ftemp = Fcount_pixels(:, :, i);
    Fcount_pixels_interior(:, i) = Ftemp(innerpixels);

    Cltemp = Clcount_pixels(:, :, i);
    Clcount_pixels_interior(:, i) = Cltemp(innerpixels);

    Cutemp = Cucount_pixels(:, :, i);
    Cucount_pixels_interior(:, i) = Cutemp(innerpixels);

    Brtemp = Brcount_pixels(:, :, i);
    Brcount_pixels_interior(:, i) = Brtemp(innerpixels);

    Itemp = Icount_pixels(:, :, i);
    Icount_pixels_interior(:, i) = Itemp(innerpixels);

    etemp = ecount_pixels(:, :, i);
    ecount_pixels_interior(:, i) = etemp(innerpixels);

end

%% Get normalised electron counts
%--------------------------------------------------------------------------

if normalise

    initial_ecount_pixels_interior = ecount_pixels_interior(:, 1);

    normalised_ecount_pixels_interior = ecount_pixels_interior ./ initial_ecount_pixels_interior;

    Fcount_pixels_interior = Fcount_pixels_interior .* normalised_ecount_pixels_interior;
    Clcount_pixels_interior = Clcount_pixels_interior .* normalised_ecount_pixels_interior;
    Cucount_pixels_interior = Cucount_pixels_interior .* normalised_ecount_pixels_interior;
    Brcount_pixels_interior = Brcount_pixels_interior .* normalised_ecount_pixels_interior;
    Icount_pixels_interior = Icount_pixels_interior .* normalised_ecount_pixels_interior;

end

%% Sum pixels across all cycles for a count of each element in each cycle
%--------------------------------------------------------------------------

Fsum = sum(Fcount_pixels_interior);
Clsum = sum(Clcount_pixels_interior);
Cusum = sum(Cucount_pixels_interior);
Brsum = sum(Brcount_pixels_interior);
Isum = sum(Icount_pixels_interior);

%% Get the sum of counts for each cycle
%--------------------------------------------------------------------------

Fbycycle = zeros(1, ncycles);
Clbycycle = zeros(1, ncycles);
Cubycycle = zeros(1, ncycles);
Brbycycle = zeros(1, ncycles);
Ibycycle = zeros(1, ncycles);

parfor i = 1:ncycles

    Fbycycle(1, i) = Fsum(i);
    Clbycycle(1, i) = Clsum(i);
    Cubycycle(1, i) = Cusum(i);
    Brbycycle(1, i) = Brsum(i);
    Ibycycle(1, i) = Isum(i);

end

%% Bootstrap to find standard error
%--------------------------------------------------------------------------

%Set the number of trials for bootstrapping error
ntrials = 1e2;

%Preallocate an array for replacing values
Cl_ = nan(ntrials, ncycles);
F_ = nan(ntrials, ncycles);
Cu_ = nan(ntrials, ncycles);
Br_ = nan(ntrials, ncycles);
I_ = nan(ntrials, ncycles);

nInner = sum(sum(innerpixels)); %Number of inner pixels
iInner = find(innerpixels); % Creates a vector of the index of all the pixels that are true in R
% (so not the ones that are zero around the edges). Linear indexing.

% Take ntrials repeated samples with replacement from the dataset:
%This is the slowest part of the code! Speed it up?

parfor ii = 1:ntrials %Parallel version

    % Random sampling of nInner number of samples
    % for values up to nInner (number of pixels)

    iiR = randsample(nInner, nInner, true);
    iinnerR = iInner(iiR);

    for jj = 1:ncycles

        % Sequential Memory Access! Instead

        F_boot = Fcount_pixels(:, :, jj);
        F_(ii, jj) = sum(F_boot(iinnerR));

        Cl_boot = Clcount_pixels(:, :, jj);
        Cl_(ii, jj) = sum(Cl_boot(iinnerR));

        Cu_boot = Cucount_pixels(:, :, jj);
        Cu_(ii, jj) = sum(Cu_boot(iinnerR));

        Br_boot = Brcount_pixels(:, :, jj);
        Br_(ii, jj) = sum(Br_boot(iinnerR));

        I_boot = Icount_pixels(:, :, jj);
        I_(ii, jj) = sum(I_boot(iinnerR));

    end


end

%%

%Find the standard deviation for each cycle

%For each sample, calculate the standard error
%This results in ntrials different estimates for the standard error.
%To find the bootstrapped standard error, take the mean of the ntrials standard errors
% This creates a standard error for each cycle

F_std = std(F_, 1);
Cl_std = std(Cl_, 1);
Cu_std = std(Cu_, 1);
Br_std = std(Br_, 1);
I_std = std(I_, 1);

%% Plot scatter plots with errorbars
%--------------------------------------------------------------------------

% Get the name of the bead
beadlabel = filename(1:end-3);
beadlabel = replace(beadlabel, '_', '');
beadlabel = replace(beadlabel, 'LunarBead', 'Lunar Bead ');

set(0, 'DefaultFigureVisible', 'off') % Stop plots from popping up on screen

f = figure('Name', ['Element Counts by Cycle: ', beadlabel]);
f.Position(3:4) = [1200, 600];

% Create a subplot for each of the 5 elements

subplot(2, 3, 1)
errorplotterfunction(Fbycycle, F_std, '#6699CC', 'F', ncycles, beadlabel)
subplot(2, 3, 2)
errorplotterfunction(Clbycycle, Cl_std, '#88CCEE', 'Cl', ncycles, beadlabel)
subplot(2, 3, 3)
errorplotterfunction(Cubycycle, Cu_std, '#999933', 'Cu', ncycles, beadlabel)
subplot(2, 3, 4)
errorplotterfunction(Brbycycle, Br_std, '#332288', 'Br', ncycles, beadlabel)
subplot(2, 3, 5)
errorplotterfunction(Ibycycle, I_std, '#AA4499', 'I', ncycles, beadlabel)

%% Save the figure
% If saveplots is set to 1, the plot will be saved to the plot directory
%--------------------------------------------------------------------------

if saveplots

    saveas(gca, [Figure_directoryname, '/', filename, '.png']);

end

%% Save the excel document
% If saveexcel is set to 1, the excel document will be saved to the excel directory
%--------------------------------------------------------------------------

if saveexcel

    countsbycycletable = table(Fbycycle', F_std', ...
        Clbycycle', Cl_std', ...
        Cubycycle', Cu_std', ...
        Brbycycle', Br_std', ...
        Ibycycle', I_std', ...
        'VariableNames', {'F_counts', 'F_std', 'Cl_counts', 'Cl_std', ...
        'Cu_counts', 'Cu_std', 'Br_counts', 'Br_std', 'I_counts', 'I_std'});

    writetable(countsbycycletable, [Excel_directoryname, '/', filename, '.xlsx']);


end

end
