%% Standard MATLAB
clear all
close all
clc

%% Add Data and Function Folders to Path
addpath('../image Processing/Data')
addpath('../image Processing/Functions')

%% Input Settings
% Input is given in a struct form

% Time Data
conf.constellation      =   'G';                                                                               %   Constellation: String containing RINEX SYS identifiers [G, E, GE, GR, GER].
conf.firstEpoch         =   '2018-07-26_12:50:00';                                                              %   First epoch for processing.
conf.lastEpoch          =   '2018-07-26_14:50:00';                                                              %   Last epoch for processing. 
conf.start              =   1;                                                                                  %   Epoch offset from start of RINEXobs  
conf.totalEpochs        =   4500;                                                                               %   Number of epochs to be processed.  
conf.ignoreSvs          =   {'G04' 'E20'}; 

% For time conversion
conf.YY             = 2018;
conf.MM             = 07;
conf.DD             = 26;

% Video Input 
conf.videoInput1    = 'VBOX_20180726101318_0001.avi';
conf.videoInput2    = 'VBOX_20180726101318_0002.avi';
conf.videoInput3    = 'VBOX_20180726101318_0003.avi';
conf.videoInput4    = 'VBOX_20180726101318_0004.avi';
conf.videoTag       = 'VBOX_20180726101318_0001.vbo';
conf.fileIDOut      = 'conf_coefs.txt';

% Read RINEX Nav Data
conf.RINEXnavGPS    = '..\image Processing\Data\FOC-2070.18N';
conf.RINEXnavGAL    = '..\image Processing\Data\FOC-2070.18L';
conf.RINEXnavGLO    = '..\image Processing\Data\FOC-2070.18G';

%% Load Navigation Data

% Read GPS navigation message
if(~isempty(findstr(conf.constellation,'G')))
    [nav.G.constellations]                                    =   multi_constellation_settings(1, 0, 0, 0, 0, 0);
    [nav.G.eph, nav.G.iono, nav.G.corrSysTime]                =   load_RINEX_nav(conf.RINEXnavGPS, nav.G.constellations, 0);
end

% Read GLONASS navigation message
if(~isempty(findstr(conf.constellation,'R')))
    [nav.R.constellations]                                    =   multi_constellation_settings(0, 1, 0, 0, 0, 0);
    [nav.R.eph, ~, nav.R.corrSysTime]                         =   load_RINEX_nav(conf.RINEXnavGLO, nav.R.constellations, 0);
end

% Read Galileo navigation message
if(~isempty(findstr(conf.constellation,'E')))
    [nav.E.constellations]                                    =   multi_constellation_settings(0, 0, 1, 0, 0, 0);
    [nav.E.eph, nav.E.iono, nav.E.corrSysTime]                =   load_RINEX_nav(conf.RINEXnavGAL, nav.E.constellations, 0);
    if(~(~isempty(findstr(conf.constellation,'G'))))
        nav.G.iono                                            =   nav.E.iono;
    end
end

%% Read SPAN Data
% File Format
% GPSTime [sec] X-ECEF [m] Y-ECEF [m] Z-ECEF [m] Week [weeks]

spanFileID          = fopen('EXP18-02_ReferenceTrajectory_MMAntenna.txt');
spanRef             = textscan(spanFileID,'%f %f %f %f %f','headerlines',22);
fclose(spanFileID);

% Get XYZ Vector from Span Data
xSpanEcef           = spanRef{1,2};
ySpanEcef           = spanRef{1,3};
zSpanEcef           = spanRef{1,4};

% Convert to geodetic coordinates
spanLat             = NaN(size(xSpanEcef));
spanLong            = NaN(size(xSpanEcef));
spanHeight          = NaN(size(xSpanEcef));

for i = 1:length(spanLat)
    [spanLat(i),spanLong(i),spanHeight(i)] = togeod(6378137,298.257223563,xSpanEcef(i),ySpanEcef(i),zSpanEcef(i));
end

%% Read Tagging file & Load Video File Objects
% File Format
% sats time lat long velocity heading height vert-vel dgps avifileindex
% avitime

tagFileID           = fopen(conf.videoTag);
tagData             = cell2mat(textscan(tagFileID,'%f %f %f %f %f %f %f %f %f %f %f','headerlines',36));
fclose(tagFileID);

% Compute GPS ToW and Week No
HHMMSSS             = num2str(tagData(:,2),'%.1f');
tagHH               = str2num(HHMMSSS(:,1:2));
tagMM               = str2num(HHMMSSS(:,3:4));
tagSSS              = str2num(HHMMSSS(:,5:end));
tagTimeMatrix       = [conf.YY*ones(size(tagHH)), conf.MM*ones(size(tagHH)), conf.DD*ones(size(tagHH)),...
                       tagHH, tagMM, tagSSS];
                   
[~,tagTOW,~,~]      = utc2gpstime(tagTimeMatrix);

% Load Video File Objects
% xyloObj1            = VideoReader(conf.videoInput1);
% xyloObj2            = VideoReader(conf.videoInput2);
% xyloObj3            = VideoReader(conf.videoInput3);
% xyloObj4            = VideoReader(conf.videoInput4);

%% TEST

% conf.videoInput1    = 'VBOX_20180726101318_0001.avi';
% xyloObj1            = VideoReader(conf.videoInput1);
% % currAxes = axes;
% i = 1;
% while hasFrame(xyloObj1)    
% readFrame(xyloObj1);
% xyloObj1.CurrentTime
% a(i) = xyloObj1.CurrentTime;
% i = i + 1;
% % image(vidFrame,'Parent',currAxes);
% % currAxes.Visible = 'off';
% % pause(1/xyloObj1.FrameRate);
% end

%% Calculate Frames per tag

% Indices per Video File
idxVid1             = find(tagData(:,10) == 1);
idxVid2             = find(tagData(:,10) == 2);
idxVid3             = find(tagData(:,10) == 3);
idxVid4             = find(tagData(:,10) == 4);

%% Combine timescales

% aviSyncTime
aviSyncTime1        = tagData(idxVid1,11);
tagTOW1             = tagTOW(idxVid1);

figure()
hold on
plot(aviSyncTime1/1000)
plot(tagTOW1-tagTOW1(1))
legend('AVI','TOW')



%% Plot Map With Different PVT Solutions (of different Rx)

figure()
hold on
plot(-tagData{1,4}/60,tagData{1,3}/60)
plot(spanLong,spanLat,'LineWidth',2)
title('Trajectory')
xlabel('Longitude [deg]')
ylabel('Latitude [deg]')
legend('Camera','SPAN')
grid on
axis equal




