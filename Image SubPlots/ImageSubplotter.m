%% Image Subplots

clear;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Parameters

lunarbead = 'LunarBeadH_1';

plotoutputfolder = 'ImageSubplotOutputs';

electron_normalise = 1;

saveplots = 1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Don't routinely modify anything below here.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Get the paths of the im file you are importing, and the png file you are
% creating and exporting
%--------------------------------------------------------------------------
imfilepath = ['im files/', lunarbead, '.im'];
pngfilename = ['ROI/FirstFrame/', lunarbead, '.png'];

%% Create folder to store the output
%--------------------------------------------------------------------------

if ~isfolder(plotoutputfolder)
    [~, ~, ~] = mkdir(char(plotoutputfolder));
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
npixels = size(image_data, 1); %Assumes square

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
ecount_pixelsN = ecount_pixels ./ initial_ecount_pixels;

Fcount_pixelsN = Fcount_pixels   .* ecount_pixelsN;
Clcount_pixelsN = Clcount_pixels .* ecount_pixelsN;
Cucount_pixelsN = Cucount_pixels .* ecount_pixelsN;
Brcount_pixelsN = Brcount_pixels .* ecount_pixelsN;
Icount_pixelsN = Icount_pixels   .* ecount_pixelsN;

%% Create colormaps for images
%--------------------------------------------------------------------------

close all

xwidth = 0.3;
yheight = 0.3;

buffer = 0.02;

figure()
% 
colormap hot

hold on
colormapsubplot(ecount_pixelsN, 1, 1, xwidth, yheight, buffer)
colormapsubplot(ecount_pixelsN, 30, 2, xwidth, yheight, buffer)
colormapsubplot(ecount_pixelsN, 10, 3, xwidth, yheight, buffer)
colormapsubplot(ecount_pixelsN, 40, 4, xwidth, yheight, buffer)
colormapsubplot(ecount_pixelsN, 20, 5, xwidth, yheight, buffer)
colormapsubplot(ecount_pixelsN, 50, 6, xwidth, yheight, buffer)
cb = colorbar('eastoutside');
cb.FontSize = 12;
%cb.FontWeight = 'bold';
cb.Label.String = 'Counts per Pixel';
cb.Position(1) = cb.Position(1) + 1e-1;
cb.Position(4) = cb.Position(4) * 3 + 2*buffer;
hold off
shg

%% Save the plots
%--------------------------------------------------------------------------

if saveplots
    
    
    saveas(gca, [char(plotoutputfolder), '/', char(lunarbead),...
            ' image subplots', '.png']);
    
    
end




%--------------------------------------------------------------------------
function colormapsubplot(pixelmap, cycle, subplotindex, xwidth, yheight, buffer)

a = subplot(3, 2, subplotindex);

xpos = 0.2;

if ~mod(subplotindex, 2)
    xpos = xpos + xwidth + buffer;
end

ypos = 0.68;

if subplotindex > 2 && subplotindex <= 4
    ypos = ypos - yheight - buffer;
elseif subplotindex > 4
    ypos = ypos - 2*(yheight + buffer);
end
a.Position = [xpos ypos xwidth yheight];

imagesc(pixelmap(:,:,cycle));

% Add the cycle number

dim = [xpos ypos+0.68*yheight 0.1 0.1];
a = annotation('textbox',dim,'String', num2str(cycle), 'Color', 'white', 'FontSize', 16);
a.LineStyle = 'none';
a.FontWeight = 'bold';

set(gca,'xtick',[])
set(gca,'ytick',[])
set(gca,'xticklabel',[])
set(gca,'yticklabel',[])

end



