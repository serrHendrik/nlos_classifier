%% Disclaimer
% This script will process any fisheye imagery and will determine whether a
% SV is LOS/NLOS
%
% Requirements on camera files
% - Video format can be in any format supported by MATLAB VideoReader
% - A metafile associating a certain frame in [ms] from the start of the
%   video with a time in UTC (format HHMMSS.SS). This file should also
%   contain a reference to the video (000i) and has a .vbo extension
%
% Required toolboxes:
% - image processing toolbox
% - signal processing toolbox
%
% Required subfunctions:
% - procVBO.m -> Processing of .vbo image
% - utc2gpstime.m -> Converts a time in UTC to GPS Time (since 6th January 
%   1980 00:00:00 (UT)
% -
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author: Floor Melman
% Company: European Space Agency
%
% Date: 18.01.2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Change History
% 
% - V0.1: Prototyping
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Standard MATLAB
clear all
close all
clc

%% Add Data and Function Folders to Path 

addpath('../fisheyecameranlos/Data')
addpath('../fisheyecameranlos/Functions')

%% GENERAL algorithm settings

% Settings regarding video output
conf.testVideoOn        = 1;    % Generate video visualizing results
conf.svLabelLeftPos     = 3;    % Offset to (left +) of the SV label w.r.t. the SV point
conf.FrameRate          = 5;    % Frame rate [frames/second] for testVideo

% Settings regarding image processing
conf.getProbMat         = 1;    % Generate Probability matrix for each frame [0] -> From file / [1] -> generate / [2] -> do not use

% Request plotting output
conf.runVerValPlots     = 1;    % [0] -> not plot / [1] -> plot verification/validation plots

% Request plotting statistics output
conf.runStatPlots       = 1;    % [0] -> not plot / [1] -> plot statistical plots

%% Run configuration file

run('Data/Config/HAA_2018_EXP02.m')

%% Physical Constants

physCon.Re          = 6378137;          % Radius Earth [m]
physCon.f           = 298.257223563;    % Flatting Earth [-]
physCon.week2second = 604800;           % Seconds per week [s/week]

%% Load Observations MMRx
% nav main struct
% - allSv -> struct with all detected SV names
% - timeScale -> Timescale (GPS Time in [s]) for all epochs
% - allSVnb -> number of observed SVs in selected window
% nav structure contains per constellation (G/E/R):
% - eph matrix (34xn)
% - iono correction
% - corrSysTime
% - matObs -> Code Pseudoranges
% - matCN0 -> Carrier to noise ratio [Optional]
% - matDopp -> Doppler observables [Optional]
% - allSv -> All PRN of detected SVs per constellation

nav                 = RINEX_Processing(conf);

%% Process video tagfile
% Produces a struct with 12 fields containing a number of associated
% variables per frame of the accompanying video's. Most importantly:
% - vboTag.GPSTime -> GPS ToW [s] per frame
% - vboTag.GPSWeek -> GPS week [-] per frame
% - vboTag.fileIndex -> 000n refers to video 000n
% - vboTag.aviTime -> Time tag of .avi file (from start) [s]

vboTag              = procVBO(conf.vboFilePath);	% Structure with associated fisheye camera data

%% Find Common Timescale
% - commonTime -> timescale of the intersection between the camera and 
%   video epochs
% - cameraImSel -> indices of vboTag fields coincident with MMRx epochs
% - MMRxSelectedInd -> indices of the timevector of the MMRx epoch vector
%   in the selected time interval

% Find camera frames which are coincident in time with receiver obs epochs
[commonTime,cameraImSel]	= findCommonTime(vboTag,nav); 

%% Get SPAN Reference Trajectory
% conf.refTraj -> WeekNr - ToW - Xpos - Ypos - Zpos - Xvel - Yvel - Zvel
% conf.refRot -> WeerNr - ToW - Roll - Pitch - Yaw
% Produces structure with:
% - refPos -> reference position for selected epochs
% - refVel -> reference velocity for selected epochs
% - refRot -> orientation of camera w.r.t. the ENU frame

refPosVel   = loadSPANRef(conf,physCon,nav.timeScale);

%% Process Video (fisheye camera)

% Process video and get probability maps
[videoFrameStore,pbMat,videoReadID] = processVideo(conf,vboTag,cameraImSel,commonTime);

%% Compute SV elevation and azimuth

[aZeLStructure]     = aZeLfromNav(conf,nav,refPosVel);

%% Load calibration matrices and associate SV to pixel
% Calibration can be performed using:
% -https://sites.google.com/site/scarabotix/ocamcalib-toolbox
% Additionally fisheye_calib_datastruct.m is required

% Load calibration matrices
load(conf.azCalib,'az'); az_calibration = az-180; clear az;
load(conf.elCalib,'el'); el_calibration = el; clear el;

%% Compute sample/line coordinate for each SV

[sampleLine]        = aZeL2PixelLoc(conf,aZeLStructure,az_calibration,el_calibration,pbMat);

%% Generate plots for verification/validation

% Run subscript
if conf.runVerValPlots == 1
    verValPlots;
end
    
%% Generate plots for statistical analysis

% Run subscript
if conf.runStatPlots == 1
    statisticPlot;
end

%% Generate Video

% Run video  generation script
if conf.testVideoOn == 1    
    videoGen;
end
