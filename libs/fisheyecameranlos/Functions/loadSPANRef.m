function [refPosVel] = loadSPANRef(conf,physCon,MMrxTime)
%[refPosVel] = loadSPANRef(conf,physCon,MMrxSelectedInd)ere
%   This function loads the reference position and orientation of a moving
%   receiver for a selected time-scale of a receiver under consideration
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
% Date: 28.01.2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Change History
% 
% - V0.1: Prototyping
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load MMrx5 timescale
MMrxGPSTime         = MMrxTime;     % Observation Epochs in GPS Time [s]

% Load SPAN Reference Trajectory (in ECEF Coordinates)
spanRef             = importdata(conf.refTraj);
spanRefTime         = spanRef.data(:,conf.idxSpTow) + spanRef.data(:,conf.idxSpWn)*physCon.week2second;

% Load SPAN Reference Orientation
spanRot             = importdata(conf.refRot);
spanRotTime         = spanRot.data(:,conf.idxSpTow) + spanRot.data(:,conf.idxSpWn)*physCon.week2second;

% Find common timescale different SPAN files
[commonRefRotTime,idxRef,idxRot]	= intersect(round(spanRefTime),round(spanRotTime));

% Ensure both SPAN datasets have the same amount of entries
if length(idxRef) >= length(idxRot)     
    spanRefComm     = spanRef.data(idxRef,:);
    spanRotComm     = spanRot.data;
elseif length(idxRef) < length(idxRot)
    spanRefComm     = spanRef.data;
    spanRotComm     = spanRot.data(idxRot,:);   
end

% Find common timescale (use round)
[commonTimeSPAN,idxSPAN,~]  = intersect(round(commonRefRotTime),round(MMrxGPSTime));   % Indices of SPAN reference coinciding with MMrx time
if isempty(commonTimeSPAN)
    error('No common timescale between selected receiver and SPAN found')
end

% Convert to geodetic coordinates
spanLat             = NaN(size(idxSPAN));
spanLong            = NaN(size(idxSPAN));
spanHeight          = NaN(size(idxSPAN));

for i = 1:length(idxSPAN)
    [spanLat(i),spanLong(i),spanHeight(i)] = togeod(physCon.Re,physCon.f,spanRefComm(idxSPAN(i),conf.idxSpX),spanRefComm(idxSPAN(i),conf.idxSpY),spanRefComm(idxSPAN(i),conf.idxSpZ));
end

% Store Reference Longitude and Latitude
refPosVel.spanLat       = spanLat;      % Reference latitude (WGS-84)
refPosVel.spanLong      = spanLong;     % Reference longitude (WGS-84)
refPosVel.spanHeight    = spanHeight;   % Reference height (WGS-84)

% Store Reference Position, Velocity, and Orientation in reference struct
refPosVel.refPos    = [spanRefComm(idxSPAN,conf.idxSpX), spanRefComm(idxSPAN,conf.idxSpY), spanRefComm(idxSPAN,conf.idxSpZ)];
refPosVel.refVel    = [spanRefComm(idxSPAN,conf.idxSpVx), spanRefComm(idxSPAN,conf.idxSpVy), spanRefComm(idxSPAN,conf.idxSpVz)];
refPosVel.refRot    = [spanRotComm(idxSPAN,conf.idxSpRoll), spanRotComm(idxSPAN,conf.idxSpPitch), spanRotComm(idxSPAN,conf.idxSpHeading)];

end

