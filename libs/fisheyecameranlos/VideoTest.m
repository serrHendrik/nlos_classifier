
%% Standard MATLAB
clear all
close all
clc

%% Load Data

load('D:\FisheyeCamera/IMFUSING/Code/back up/FishEye_camera_codes/Imfusing_UPT_code/os_sample/Frames_ProbMap.mat')

%% Loop to Create Video

vidfile     = VideoWriter('testmovie.mp4','MPEG-4');

figure(1)
open(vidfile);
for i = 1:size(fr,3)
    imagesc(fr(:,:,i)),colormap
    drawnow
    F(i)    = getframe(gcf);
    writeVideo(vidfile, F(i));
end
close(vidfile)