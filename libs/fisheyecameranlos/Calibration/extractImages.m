%% Script to extract images from a calibration video

% Required input
%  .vbo file (with time-tag)
%  .avi files (actual video files)

%% Standard MATLAB
clear all
close all
clc

addpath('../Functions')

%% Input Settings

% Time of image extraction
startImageExtraction    = '2019-03-05_09:19:45';    % First epoch for processing [UTC] - Format yyyy-mm-dd_hh:mm:ss
stopImageExtraction     = '2019-03-05_09:21:45';    % Last epoch for processing [UTC] - Format yyyy-mm-dd_hh:mm:ss

% Framerate
frameRateFraction       = 0.2;                      % [fraction]*video frame rate

% Input Files
vboFilePath             = 'D:/staticTest/2019-03-06/Camera/VBOX_20190305084534_0001.vbo';
videoPath               = 'D:/staticTest/2019-03-06/Camera/VBOX_20190305084534_';
videoExtension          = '.avi';

% Output Path
outputPathNormal        = 'D:/calibration/2019_03_06/Images/';
outputPathEnhContrast   = 'D:/calibration/2019_03_06/ImagesContrast/';

if ~exist(outputPathNormal,'dir')
    mkdir(outputPathNormal)
end

if ~exist(outputPathEnhContrast,'dir')
    mkdir(outputPathEnhContrast)
end

imageName               = 'img';
imageExtension          = '.jpg';

%% Process video tagfile
% Produces a struct with 12 fields containing a number of associated
% variables per frame of the accompanying video's. Most importantly:
% - vboTag.GPSTime -> GPS ToW [s] per frame
% - vboTag.GPSWeek -> GPS week [-] per frame
% - vboTag.fileIndex -> 000n refers to video 000n
% - vboTag.aviTime -> Time tag of .avi file (from start) [s]

vboTag              = procVBO(vboFilePath);     % Structure with associated fisheye camera data

%% Extraction Initialization

% Convert start and stop input to GPS time (seconds after 01-01-1980)
dateFormat      = '%4d - %2d - %2d _ %2d : %2d : %2d';	% Format to split input (first/last) epoch
[firstEpochGPS] = utc2gpstime(sscanf(startImageExtraction,dateFormat)');    % First epoch for selected data
[lastEpochGPS]  = utc2gpstime(sscanf(stopImageExtraction,dateFormat)');     % Last epoch for selected data

% Find the incides of the VBO file which should be processed according to
% the input
cameraImSel     = find(vboTag.GPSTime >= firstEpochGPS & vboTag.GPSTime <= lastEpochGPS);

% Vectors required for selection of camera frames
videosToLoad        = unique(vboTag.fileIndex(cameraImSel));
aviSyncTimeSel      = vboTag.aviTime(cameraImSel);
videoIDTag          = vboTag.fileIndex(cameraImSel);

% Read first video to get characteristics (size)
VideoReaderTest     = VideoReader(strcat(videoPath,num2str(videoIDTag(1),'%04.f'),videoExtension));

% Matrices required for storage of probabilty maps
videoFrameStore     = zeros(VideoReaderTest.Height,VideoReaderTest.Width,3,length(videoIDTag),'uint8');
videoReadID         = zeros(size(videoIDTag));

% Adjust image rate
cameraImSel         = cameraImSel(1:round(frameRateFraction*VideoReaderTest.FrameRate):end);
videosToLoad        = unique(vboTag.fileIndex(cameraImSel));
aviSyncTimeSel      = vboTag.aviTime(cameraImSel);
videoIDTag          = vboTag.fileIndex(cameraImSel);

%% Extraction Loop

% Waitbar
f   = waitbar(0,strcat('Reading Video ',{' '},num2str(videosToLoad(1),'%04.f')));

for i = 1:length(videosToLoad)
    
    % Load Video 
    VideoReaderStruct   = VideoReader(strcat(videoPath,num2str(videosToLoad(i),'%04.f'),videoExtension));
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
        
            % Store image
            imwrite(videoFrameStore(:,:,:,IDCurrVideo(j)),strcat(outputPathNormal,imageName,num2str(IDCurrVideo(j),'%04.f'),imageExtension))
            imwrite(adapthisteq(rgb2gray(videoFrameStore(:,:,:,IDCurrVideo(j)))),strcat(outputPathEnhContrast,imageName,num2str(IDCurrVideo(j),'%04.f'),imageExtension))
        else
            videoReadID(IDCurrVideo(j))     = -1;                                   % Video tag: Not Read
        end
    end
    
end

close(f)



