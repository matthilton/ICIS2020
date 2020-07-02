
folder='imgs/NBNB1'

%% fetch images
imgpath = [folder '/*.png'];
imgfiles = dir(imgpath);
disp(['Found ' int2str(length(imgfiles)) ' image files.'])

%%
images    = cell(length(imgfiles),1);
for ix=1:length(imgfiles)
 images{ix} = imread(fullfile(imgfiles(ix).folder, imgfiles(ix).name));
 disp(['Processing image: ' int2str(ix) '.'])
end
Folder='indiSegs';

%% new
%disp(['Processing seg: ' int2str(iSeg) '.'])
vidfilename='DD.mp4';

% create the video writer with 25 fps
 writerObj = VideoWriter(vidfilename, 'MPEG-4');
 writerObj.FrameRate = 2;
 % open the video writer
 open(writerObj);


for ix = 1:length(images)
    
    writeVideo(writerObj, images{ix})
end

 

close(writerObj);

