%% InitialImageCreator

movies = {'LunarBeadE_1_electronmovie',...
    'LunarBeadH_1_electronmovie','LunarBeadH_2_electronmovie','LunarBeadH_3_electronmovie','LunarBeadH_4_electronmovie',...
    'LunarBeadI_1_electronmovie','LunarBeadI_2_electronmovie','LunarBeadI_3_electronmovie',...
    'LunarBeadJ_1_electronmovie','LunarBeadJ_2_electronmovie','LunarBeadJ_3_electronmovie'};

movies = strcat(movies,'.mp4');

outputfolder = 'FirstFrame';

[status, msg, msgID] = mkdir(char(outputfolder));

for i = 1:numel(movies)
    
    
    movie = char(movies(i));
    moviename = extractBefore(movie, '_electron');
    fullmovie = VideoReader(movie); %#ok<TNMLP>
    movieFrames = read(fullmovie);
    
    OutputFileName = [outputfolder, '/', moviename, '.png'];
    
    imwrite(movieFrames(:,:,:,1),OutputFileName);
    
    
end