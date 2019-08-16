close all
clc

%_________________________________________________________________________%
%%INPUT VIDEO FILE: change name of the file to compute on another video
xyloObj = VideoReader('VBOX_20180726101318_0001.avi');
%_________________________________________________________________________%

%_________________________________________________________________________%
%%OUTPUT FILES:
fileID = fopen('conf_coefs.txt','w');% file containing confidence 
% coefficients for each computed frame - interface with TASF
cipVidObjOut1 = VideoWriter('out_Sky_Pb_Map');% output video file (.avi) 
% contaning the output probability maps - for viewing purposes only
%_________________________________________________________________________%
open(cipVidObjOut1);

maxindex = xyloObj.NumberOfFrames; % get total no. of frames of the input video
fprintf('maxindex=%d\n', maxindex);
cont = 1;    
for k=1:25:maxindex,% loop for video frames, subsampling by a pace of 12
    fprintf('processed %d\n', k);% display computation progress
    I = read(xyloObj, k);% read frame
    [M, c] = img_PbMap_Conf(I);% compute probability map & confidence coefficient for a single frame
    writeVideo(cipVidObjOut1, M);% write probability map to video file
    fprintf(fileID,'%d %d %f \n',cont,k,c);% write confidence coefficient to file
    
    fr(:,:,cont) = M;% output containing probability maps, file to be used further in localization module
    cont = cont+1;
   
end

close(cipVidObjOut1);% close video handler
fclose(fileID);% close txt output file
clearvars -EXCEPT fr% clear all variables except the output file containing probability maps

%_________________________________________________________________________%
%%OUTPUT FILE: save output file containing probability maps, in .mat format
%%(to be used with the localization module - interface with TASF)
save('Frames_ProbMap.mat', '-v7.3');
%_________________________________________________________________________%