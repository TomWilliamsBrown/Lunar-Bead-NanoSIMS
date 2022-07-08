%% Image Subplots

clear all;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Parameters

%lunarbead = 'LunarBeadH_1';

lunarbeads = {'LunarBeadE_1', ...
    'LunarBeadH_1', 'LunarBeadH_2', 'LunarBeadH_3', 'LunarBeadH_4', ...
    'LunarBeadI_1', 'LunarBeadI_2', 'LunarBeadI_3', ...
    'LunarBeadJ_1', 'LunarBeadJ_2', 'LunarBeadJ_3'};

%lunarbeads = {'LunarBeadE_1'};

plotoutputfolder = 'TESTImageSubplotOutputs';

speciestoplot = {'Cl', 'F', 'Cu', 'Br', 'I', 'e'};

saveplots = 1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Don't routinely modify anything below here.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Create folder to store the output
%--------------------------------------------------------------------------

if ~isfolder(plotoutputfolder)
    [~, ~, ~] = mkdir(plotoutputfolder);
else
    fprintf('Already a folder. Deleting Contents \n')

end

%% Name folders for each species 

Ffolder = [plotoutputfolder, '/F'];
Clfolder = [plotoutputfolder, '/Cl'];
Cufolder = [plotoutputfolder, '/Cu'];
Brfolder = [plotoutputfolder, '/Br'];
Ifolder = [plotoutputfolder, '/I'];
efolder = [plotoutputfolder, '/e'];

%% Delete Contents if it already exists

delete([Ffolder, '/*.png'])
delete([Clfolder, '/*.png'])
delete([Cufolder, '/*.png'])
delete([Brfolder, '/*.png'])
delete([Ifolder, '/*.png'])
delete([efolder, '/*.png'])

fprintf('Deleted \n');
 
%% Create folders for each species 
if ~isfolder(Ffolder)
    [~, ~, ~] = mkdir(Ffolder);
end
if ~isfolder(Clfolder)  
    [~, ~, ~] = mkdir(Clfolder);
end
if ~isfolder(Cufolder) 
    [~, ~, ~] = mkdir(Cufolder);
end
if ~isfolder(Brfolder)  
    [~, ~, ~] = mkdir(Brfolder);
end
if ~isfolder(Ifolder)   
    [~, ~, ~] = mkdir(Ifolder);
end
if ~isfolder(efolder)   
    [~, ~, ~] = mkdir(efolder);
end

%% Stop figures from appearing
%--------------------------------------------------------------------------

set(groot, 'defaultFigureVisible', 'off')

%--------------------------------------------------------------------------

for i = 1:numel(lunarbeads)
    
lunarbead = char(lunarbeads(i));

%% Get the paths of the im file you are importing, and the png file you are
% creating and exporting
%--------------------------------------------------------------------------
imfilepath = ['im files/', lunarbead, '.im'];
pngfilename = ['ROI/FirstFrame/', lunarbead, '.png'];



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

%% Choose Species Pixel Maps
%--------------------------------------------------------------------------

speciespixels = strcat(speciestoplot, 'count_pixelsN');

%% Create colormaps for images
%--------------------------------------------------------------------------

close all

xwidth = 0.3;
yheight = 0.3;
buffer = 0.02;


if sum(strcmp(speciestoplot, 'F'))
    speciesplotter(Fcount_pixelsN, xwidth, yheight, buffer, 'F', Ffolder, lunarbead)
    shg   
end
if sum(strcmp(speciestoplot, 'Cl'))
    speciesplotter(Clcount_pixelsN, xwidth, yheight, buffer, 'Cl', Clfolder, lunarbead)
    shg   
end
if sum(strcmp(speciestoplot, 'Cu'))
    speciesplotter(Cucount_pixelsN, xwidth, yheight, buffer, 'Cu', Cufolder, lunarbead)
    shg   
end
if sum(strcmp(speciestoplot, 'Br'))
    speciesplotter(Brcount_pixelsN, xwidth, yheight, buffer, 'Br', Brfolder, lunarbead)
    shg   
end
if sum(strcmp(speciestoplot, 'I'))
    speciesplotter(Icount_pixelsN, xwidth, yheight, buffer, 'I', Ifolder, lunarbead)
    shg   
end
if sum(strcmp(speciestoplot, 'e'))
    speciesplotter(ecount_pixelsN, xwidth, yheight, buffer, 'e', efolder, lunarbead)
    shg   
end


end

%% Allow figures to appear again
%--------------------------------------------------------------------------

set(groot, 'defaultFigureVisible', 'on')

%--------------------------------------------------------------------------
function speciesplotter(speciesmap, xwidth, yheight, buffer, species, plotoutputfolder, lunarbead)

    figure('visible','off')
    % 
    colormap hot

    hold on
    colormapsubplot(speciesmap, 1, 1, xwidth, yheight, buffer)
    colormapsubplot(speciesmap, 30, 2, xwidth, yheight, buffer)
    colormapsubplot(speciesmap, 10, 3, xwidth, yheight, buffer)
    colormapsubplot(speciesmap, 40, 4, xwidth, yheight, buffer)
    colormapsubplot(speciesmap, 20, 5, xwidth, yheight, buffer)
    colormapsubplot(speciesmap, 50, 6, xwidth, yheight, buffer)
    cb = colorbar('eastoutside');
    cb.FontSize = 12;
    %cb.FontWeight = 'bold';
    cb.Label.String = [species, ' Counts per Pixel'];
    cb.Position(1) = cb.Position(1) + 1e-1;
    cb.Position(4) = cb.Position(4) * 3 + 2*buffer;
    hold off

    saveas(gca, [char(plotoutputfolder), '/', char(lunarbead),...
            '_', species,'_image subplots', '.png']);
    close all
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



