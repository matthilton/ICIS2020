%%

vid=VideoReader('vids/NBNB1.mp4');
  numFrames = vid.NumberOfFrames;
  n=numFrames;
  
  %%
  Folder = 'imgs/NBNB1Frames';
for iFrame = 1:n
  frames = read(vid, iFrame);
  imwrite(frames, fullfile(Folder, sprintf('%06d.jpg', iFrame)));
end 
FileList = dir(fullfile(Folder, '*.jpg'));
for iFile = 1:length(FileList)
  aFile = fullfile(Folder, FileList(iFile).name);
  %img  
end

%%

vid=VideoReader('vids/BCPD1.mp4');
  numFrames = vid.NumberOfFrames;
  n=numFrames;
  
  %%
  Folder = 'imgs/BCPD1Frames';
for iFrame = 1:n
  frames = read(vid, iFrame);
  imwrite(frames, fullfile(Folder, sprintf('%06d.jpg', iFrame)));
end 
FileList = dir(fullfile(Folder, '*.jpg'));
for iFile = 1:length(FileList)
  aFile = fullfile(Folder, FileList(iFile).name);
  %img  
end