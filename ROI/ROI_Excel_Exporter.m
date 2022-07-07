% ROI  Excel Exporter

clear;
close all;

%% Parameters

lunarbead = 'LunarBeadH_1';

exceloutputfolder = 'TEST2ROI_excels';

electron_normalise = 1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Don't routinely modify anything below here.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Get the paths of the im file you are importing, and the png file you are
% creating and exporting
%--------------------------------------------------------------------------
imfilepath = ['im files/', lunarbead, '.im'];
pngfilename = ['ROI/FirstFrame/', lunarbead, '.png'];

%% Create folder to store the excels
%--------------------------------------------------------------------------

if ~isfolder(exceloutputfolder)
    [~, ~, ~] = mkdir(char(exceloutputfolder));
else
    fprintf('Already a folder \n')
end

%% Get the data from the im file
%--------------------------------------------------------------------------

% This line calls readNanoSIMSimage to get the header data
% (e.g. mass names, masses, analysis times, etc.)
[~, header_data] = readNanoSIMSimage(imfilepath);

% This line calls read_im_file_ro to get the image data.
% i.e. the counts in every pixel in every cycle for all of the masses
% analysed
[image_data, ~, ~] = read_im_file_ro(imfilepath);

%% Generate variables from the data and headers read from the im file
%--------------------------------------------------------------------------

%mass_amu: {[18.9708]  [36.9949]  [63.0276]  [79.0000]  [127.0000]  [0]}
[F_index, Cl_index, Cu_index, Br_index, I_index, e_index] = deal(1, 2, 3, 4, 5, 6);

% Get Counting Times
countingtimes = cell2mat(header_data.Tab_mass.countingtime);

% Get the number of pixels and cycles
ncycles = size(image_data, 3);

%% Get counts for each pixel in a 256x256 image over all cycles (256x256x50 matrix)
%--------------------------------------------------------------------------

Fcount_pixels = image_data(:, :, :, F_index);
Clcount_pixels = image_data(:, :, :, Cl_index);
Cucount_pixels = image_data(:, :, :, Cu_index);
Brcount_pixels = image_data(:, :, :, Br_index);
Icount_pixels = image_data(:, :, :, I_index);
ecount_pixels = image_data(:, :, :, e_index);

%% Normalise by electron counts
%--------------------------------------------------------------------------

initial_ecount_pixels = ecount_pixels(:, 1);
normalised_ecount_pixels = ecount_pixels ./ initial_ecount_pixels;

Fcount_pixels = Fcount_pixels .* normalised_ecount_pixels;
Clcount_pixels = Clcount_pixels .* normalised_ecount_pixels;
Cucount_pixels = Cucount_pixels .* normalised_ecount_pixels;
Brcount_pixels = Brcount_pixels .* normalised_ecount_pixels;
Icount_pixels = Icount_pixels .* normalised_ecount_pixels;

%% Import the ROI (Region of Interest) file
% This stores the x and y positions of the vertices of the ROI shape
%--------------------------------------------------------------------------

ROI_T = readtable(['ROI/H1_ROIs/', 'LunarBeadH_1_red1.txt']);

ROIX = ROI_T.X;
ROIY = ROI_T.Y;

%% Slice out counts from inside the ROI
%--------------------------------------------------------------------------

% Make a mesh to get coordinates
maxy = size(Fcount_pixels, 1);
maxx = size(Fcount_pixels, 1);
[Xmesh, Ymesh] = meshgrid(0:maxx, 0:maxy);

% Get the coordinates within the ROI

[in, on] = inpolygon(Xmesh, Ymesh, ROIX, ROIY);

X_inROI = Xmesh(in);
Y_inROI = Ymesh(in);

%% Create a figure showing the image with the ROI overlain
% This is done to confirm you have the right ROI
%--------------------------------------------------------------------------

figure()
I = imread(pngfilename);
figsizer(gcf, gca)
hold on
imshow(I)
hold on
plot(X_inROI, Y_inROI, 'r+') % Plot the pixels within the ROI
hold off

%% Extract the counts for pixels located within the ROI
%--------------------------------------------------------------------------

% Get the linear index of the pixels within the ROI. These are used to
% locate pixels within the ROI
plinear = sub2ind(size(Clcount_pixels(:, :, 1)), X_inROI, Y_inROI);

% Preallocate an matrix for counts within the ROI (counts_in_ROI)
counts_in_ROI = zeros(numel(X_inROI), ncycles);

% Populate the counts_in_ROI matrix with the count data from within the ROI
% by slicing out the pixels within the ROI using their linear index
for i = 1:ncycles
    A = Clcount_pixels(:, :, i);
    counts_in_ROI(:, i) = A(plinear);
end

%% Sum the total number of counts in each cycle
%--------------------------------------------------------------------------

Clbycycle = sum(counts_in_ROI);

%% Bootstrap to find error
%--------------------------------------------------------------------------

%Set the number of trials for bootstrapping error
ntrials = 1e2;

%Preallocate an array for replacing values
Cl_ = nan(ntrials, ncycles);
F_ = nan(ntrials, ncycles);
Cu_ = nan(ntrials, ncycles);
Br_ = nan(ntrials, ncycles);
I_ = nan(ntrials, ncycles);

npixels = numel(X_inROI); %Number of pixels

for ii = 1:ntrials %Parallel version

    % Randomly sample pixels within the ROI
    RandomIndex = randsample(npixels, npixels, true);
    RandomIndexLinear = plinear(RandomIndex);
    %%%%%%%%%% NO THIS RANDOMLY SAMPLES FROM EVERYWHERE!!!!!!!!!!!!!!!
    %!!!!!
    %!!!!!
    %!!!!!

    for jj = 1:ncycles

        Cl_boot = Clcount_pixels(:, :, jj);
        Cl_(ii, jj) = sum(Cl_boot(RandomIndexLinear));

    end

end

Cl_std = std(Cl_, 1);

%% Plot scatter plots with errorbars
%--------------------------------------------------------------------------

figure()
errorplotterfunction(Clbycycle, Cl_std, '#88CCEE', 'Cl', ncycles, 'Cl ROI')

%% Function to size the outut figure
%--------------------------------------------------------------------------
function figsizer(gcf, gca)

fig = gcf;
fig.Units = 'pixels';
fig.Position(3:4) = [500, 500];
g = gca;
g.Units = 'pixels';
g.Position(1:2) = 10;
g.Position(3:4) = 480; %= [0, 0, 500, 500];

end

%% Export to Text File
%--------------------------------------------------------------------------
