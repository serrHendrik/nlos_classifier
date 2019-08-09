
function [aZeLStructure, az_calibration, el_calibration] = get_AzEl(rootFisheye)

    %% Add Data and Function Folders to Path 

    addpath(strcat(rootFisheye,'Data'))
    addpath(strcat(rootFisheye,'Functions'))

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

    run(strcat(rootFisheye,'Data/Config/HAA_2018_EXP02.m'))

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

    %% Get SPAN Reference Trajectory
    % conf.refTraj -> WeekNr - ToW - Xpos - Ypos - Zpos - Xvel - Yvel - Zvel
    % conf.refRot -> WeerNr - ToW - Roll - Pitch - Yaw
    % Produces structure with:
    % - refPos -> reference position for selected epochs
    % - refVel -> reference velocity for selected epochs
    % - refRot -> orientation of camera w.r.t. the ENU frame

    refPosVel   = loadSPANRef(conf,physCon,nav.timeScale);

    %% Compute SV elevation and azimuth

    [aZeLStructure]     = aZeLfromNav(conf,nav,refPosVel);

    %% Load calibration matrices and associate SV to pixel
    % Calibration can be performed using:
    % -https://sites.google.com/site/scarabotix/ocamcalib-toolbox
    % Additionally fisheye_calib_datastruct.m is required

    % Load calibration matrices
    load(conf.azCalib,'az'); 
    az_calibration = az-180; 
    clear az;

    load(conf.elCalib,'el'); 
    el_calibration = el; 
    clear el;

end
