function [videoFrameStore,pbMat,videoReadID] = processVideo(conf,vboTag,cameraImSel)
% [videoFrameStore,pbMat,videoReadID] = processVideo(conf,vboTag)
%
% Function that reads specific frames which are tied to the times at which
% the receiver get an observation. If requested (specified in conf) a
% probility of sky detection is generated.
%
% Input:
%
% Output:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Author: Floor Melman
% Company: European Space Agency
%
% Date: 12.02.2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Change History
%
% - V0.1: Prototyping
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Vectors required for selection of camera frames
videosToLoad        = unique(vboTag.fileIndex(cameraImSel));
aviSyncTimeSel      = vboTag.aviTime(cameraImSel);
videoIDTag          = vboTag.fileIndex(cameraImSel);

% Read first video to get characteristics (size)
VideoReaderTest     = VideoReader(strcat(conf.videoPath,num2str(videoIDTag(1),'%04.f'),conf.videoExtension));

% Open file to store confindence results
if(conf.getProbMat == 1)
    
    % Open created file to enable writing of confidence results
    confFileID      = fopen(conf.probConf,'w'); 
    
    % Create an empty matrix for probability per frame
    pbMat           = NaN(VideoReaderTest.Height,VideoReaderTest.Width,length(videoIDTag));
end

% Matrices required for storage of probabilty maps
videoFrameStore     = zeros(VideoReaderTest.Height,VideoReaderTest.Width,3,length(videoIDTag),'uint8');
videoReadID         = zeros(size(videoIDTag));

% Waitbar
f   = waitbar(0,strcat('Reading Video ',{' '},num2str(videosToLoad(1),'%04.f')));

for i = 1:length(videosToLoad)
    
    % Load Video 
    VideoReaderStruct   = VideoReader(strcat(conf.videoPath,num2str(videosToLoad(i),'%04.f'),conf.videoExtension));
    durationCurrVideo   = VideoReaderStruct.Duration;
    
    % Indices vbo struct for current video
    IDCurrVideo         = find(videoIDTag == videosToLoad(i));          % Find indices belonging to current video
    indicesProcessed    = length(find(videoIDTag < videosToLoad(i)));   % Count images processed in previous loop
    
    % Show Progress
    waitbarstring       = strcat('Reading Video ',{' '},num2str(videosToLoad(i),'%04.f'));
    
    for j = 1:length(IDCurrVideo)
        % Counter
        waitbar((indicesProcessed + j)/length(videoReadID),f,waitbarstring)
        % Check aviSyncTimeSel for -1
        if aviSyncTimeSel(IDCurrVideo(j)) ~= -0.001 && aviSyncTimeSel(IDCurrVideo(j)) < durationCurrVideo
            videoReadID(IDCurrVideo(j))     = 1;                                    % Video tag: Read
            VideoReaderStruct.CurrentTime   = aviSyncTimeSel(IDCurrVideo(j));       % Time of frame to be read
            videoFrameStore(:,:,:,IDCurrVideo(j))   = readFrame(VideoReaderStruct); % Read RGB Video data per pixel
        
            % Generate probability map if requested
            if(conf.getProbMat == 1)
                [pbFrame, pbConf]   = img_PbMap_Conf(videoFrameStore(:,:,:,IDCurrVideo(j)));
                fprintf(confFileID,'%d %f %f \n',j,aviSyncTimeSel(IDCurrVideo(j)),pbConf);
                pbMat(:,:,j)        = pbFrame;
            end
        
        else
            videoReadID(IDCurrVideo(j))     = -1;                                   % Video tag: Not Read
        end
    end
    
end

close(f)

%% Save/Load Probability Matrix
% Probability matrix will be saved/loaded depending on conf.getProbMat

switch conf.getProbMat
    case 0  % If probability matrix is not generated here -> load it from previous run
    
    datetimeMat     = [sscanf(conf.firstEpoch,conf.dateFormat)';...
                       sscanf(conf.lastEpoch,conf.dateFormat)'];
    timeStartStop   = datetimeMat(:,4:6);
    load(strcat(conf.saveProbMatPath,conf.saveProbMatName,...
        num2str(timeStartStop(1,:),'%02.f%02.f%02.f'),'-',...
        num2str(timeStartStop(2,:),'%02.f%02.f%02.f'),'.mat'),...
        'pbMat','pbConf','commonTime')   

    case 1  % If probability matrix is generated here -> save it for later use
    
    datetimeMat     = [sscanf(conf.firstEpoch,conf.dateFormat)';...
                       sscanf(conf.lastEpoch,conf.dateFormat)'];
    timeStartStop   = datetimeMat(:,4:6);
    save(strcat(conf.saveProbMatPath,conf.saveProbMatName,...
        num2str(timeStartStop(1,:),'%02.f%02.f%02.f'),'-',...
        num2str(timeStartStop(2,:),'%02.f%02.f%02.f'),'.mat'),...
        'pbMat','pbConf','commonTime')  
    
    case 2  % If both pbMat and toolboxes are unavailable
    
    pbMat           = [];
    
end

end