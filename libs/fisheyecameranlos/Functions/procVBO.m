function [vboTag] = procVBO(vboPath)
% Function to read and process .vbo files associated to the VBOX Fisheye
% camera
%
% Input:
% - vboPath: Pathname containing the .vbo file
%
% Ouput:
% - vboTag: Structure containing 
%       - Number of SVs used for PVT
%       - GPS time (seconds since 6th January 1980 00:00:00 (UT))
%       - Time of week of TPS time [seconds]
%       - Week Number of GPS time
%       - Latitude [deg]
%       - Longitude (East = positive) [deg]
%       - Magnitude of velocity [m/s]
%       - Camera heading [deg]
%       - Camera height (ENU frame) [m]
%       - Camera vertical velocity [m/s]
%       - Camera file index (referring to i in 'VBOX_YYYYMMDDhhmmss_000i.avi')
%       - Time tag of .avi file [s] -> Neglect -0.001 entries
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Author: Floor Melman
% Company: European Space Agency
%
% Date: 16.01.2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Change History
%
% - V0.1: Prototyping
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Read vbo datafile
tagFileID           = fopen(vboPath);
tagData             = cell2mat(textscan(tagFileID,'%f %f %f %f %f %f %f %f %f %f %f','headerlines',36));
fclose(tagFileID);

% Get Date from fileName
% Make sure fileName has format 'VBOX_YYYYMMDDhhmmss_000i.vbo'
[~,DateTemp]        = strtok(vboPath,'_');
[DateTemp1,~]       = strtok(DateTemp,'_');
Date                = strtok(DateTemp1,'_');
YY                  = str2num(Date(1,1:4)); 
MM                  = str2num(Date(1,5:6)); 
DD                  = str2num(Date(1,7:8));  

% Compute GPS ToW, GPSTime, Week number
HHMMSSS             = num2str(tagData(:,2),'%.1f');
tagHH               = str2num(HHMMSSS(:,1:2));
tagMM               = str2num(HHMMSSS(:,3:4));
tagSSS              = str2num(HHMMSSS(:,5:end));
tagTimeMatrix       = [YY*ones(size(tagHH)), MM*ones(size(tagHH)), DD*ones(size(tagHH)),...
                       tagHH, tagMM, tagSSS];
                   
[GPSTime,tagTOW,GPSWeek,~]	= utc2gpstime(tagTimeMatrix);

% Retrieve Other Variables with a timestamp similar to GPSTime
vboTag.noSV         = tagData(:,1);         % Number of SVs used for PVT
vboTag.GPSTime      = GPSTime;              % GPS time (seconds since 6th January 1980 00:00:00 (UT))
vboTag.tagTOW       = tagTOW;               % Time of week of TPS time [seconds]
vboTag.GPSWeek      = GPSWeek;              % Week Number of GPS time
vboTag.latitude     = tagData(:,3)/60;      % Latitude [deg]
vboTag.longitude    = -tagData(:,4)/60;     % Longitude (East = positive) [deg]
vboTag.camVel       = tagData(:,5)/3.6;     % Magnitude of velocity [m/s]
vboTag.camHead      = tagData(:,6);         % Camera heading [deg]
vboTag.camHeight    = tagData(:,7);         % Camera height (ENU frame) [m]
vboTag.camVVel      = tagData(:,8);         % Camera vertical velocity [m/s]
vboTag.fileIndex    = tagData(:,10);        % Camera file index (referring to i in 'VBOX_YYYYMMDDhhmmss_000i.avi')
vboTag.aviTime      = tagData(:,11)/1000;   % Time tag of .avi file [s] -> Neglect -0.001 entries

end

