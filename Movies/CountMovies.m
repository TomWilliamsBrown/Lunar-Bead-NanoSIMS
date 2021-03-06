clear;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% Modify Parameters Here


% [1] Specify the .im files you want
filename = {'LunarBeadI_1.im'};

im_files = {'LunarBeadE_1.im', ...
    'LunarBeadH_1.im', 'LunarBeadH_2.im', 'LunarBeadH_3.im', 'LunarBeadH_4.im', ...
    'LunarBeadI_1.im', 'LunarBeadI_2.im', 'LunarBeadI_3.im', ...
    'LunarBeadJ_1.im', 'LunarBeadJ_2.im', 'LunarBeadJ_3.im'};

% [2] Specify where you want the movies saved

moviesavefolder = 'Movies';



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Don't routinely modify anything below here.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Make movie folder
%--------------------------------------------------------------------------

% Check if the directory already exists
% If it does, ask if you want to delete the contents.
% If yes, delete the contents

if isfolder(moviesavefolder)

    % If the folder exists, tell the user. Continue if any key is pressed.
    prompt = (['The following folder already exists: ', moviesavefolder, '\n', 'Press any key to continue and delete contents']);
    input(prompt)

    % Delete contents if it already exists

    % Get a list of all files in the folder
    filePattern = fullfile(char(moviesavefolder));
    % Then delete the ones with a .png extension:
    delete([filePattern, '/*.mp4'])
    % Say that they've been deleted
    fprintf('Files Deleted. Starting figure creation. \n')

else % If it doesn't already exist, make it!

    [status, msg, msgID] = mkdir(char(moviesavefolder));

end

%% Iterate once for each of the .im files
%--------------------------------------------------------------------------

for i = 1:numel(im_files)

filename = im_files(i);

%% Read the NanoSIMS Image
%--------------------------------------------------------------------------

imfilename = ['im files/', char(filename)];

[~, filename_] = fileparts(filename);

% This line calls readNanoSIMSimage to get the header data 
% (e.g. mass names, masses, analysis times, etc.)
[~, header_data] = readNanoSIMSimage(imfilename);

% This line calls read_im_file_ro to get the image data. 
% i.e. the counts in every pixel in every cycle for all of the masses
% analysed
[image_data, ~, ~] = read_im_file_ro(imfilename);


%% Generate variables from the data and headers read above
%--------------------------------------------------------------------------

% Atomic Masses: {[18.97]  [36.99]  [63.02]  [79.00]  [127.00]  [0]}
[F_index, Cl_index, Cu_index, Br_index, I_index, e_index] = deal(1, 2, 3, 4, 5, 6);

% Counting Times
countingtimes = cell2mat(header_data.Tab_mass.countingtime);

%% Number of pixels and cycles
n_pixels = header_data(1).Header_image.width;
ncycles = size(image_data, 3);

%% Counts for each pixel in a 256x256 image over all cycles (256x256x50 matrix)

%Fcount_pixels = image_data(:, :, :, F_index);
%Clcount_pixels = image_data(:, :, :, Cl_index);
Cucount_pixels = image_data(:, :, :, Cu_index);
%Brcount_pixels = image_data(:, :, :, Br_index);
%Icount_pixels = image_data(:, :, :, I_index);
ecount_pixels = image_data(:, :, :, e_index);


%% Currently abundaces are very low, so converting from uint16 to uint8 converts
% counts to zero, so need to multiply first.
%--------------------------------------------------------------------------

%Fpixels = im2uint8(Fcount_pixels);
%Clpixels = im2uint8(Clcount_pixels) * 100;
Cupixels = im2uint8(Cucount_pixels*10000);
epixels = im2uint8(ecount_pixels*100);



%% Create and save the movie
%--------------------------------------------------------------------------

% Create VideoWriter Object (VwObj) to write video files
VwObj = VideoWriter([moviesavefolder, '/', extractBefore(char(filename),'.im'), '_electronmovie'], 'MPEG-4');
% modify property values before opening the video file for writing
VwObj.FrameRate = 15;
VwObj.Quality = 95;

%write each frame of the image to the file
open(VwObj);
for t = 1:size(epixels, 3)

    f.cdata = 0 + epixels(:, :, t); % Specify the colourmap to be used
    f.colormap = jet(256); %

    writeVideo(VwObj, f);

end
close(VwObj);

end
