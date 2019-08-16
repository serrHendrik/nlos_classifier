%% Scenario information
% Information about the scenario

% Location: Rotterdam
% Date: 26 July 2018
% Receiver: U-blox 5 (MMRx5)

%% Input Settings

% Date and Time Input (input should be in UTC)
conf.firstEpoch     = '2018-07-26_14:17:26';    % First epoch for processing [UTC] - Format yyyy-mm-dd_hh:mm:ss
conf.lastEpoch      = '2018-07-26_14:17:27';    % Last epoch for processing [UTC] - Format yyyy-mm-dd_hh:mm:ss
conf.dateFormat     = '%4d - %2d - %2d _ %2d : %2d : %2d';	% Format to split input (first/last) epoch

% Video Files Location
conf.videoPath      = '..\fisheyecameranlos\Data\VideoData\EXP18_ROT02\VBOX_20180726101318_';
conf.videoExtension = '.avi';
conf.vboFilePath    = '..\fisheyecameranlos\Data\VideoData\EXP18_ROT02\VBOX_20180726101318_0001.vbo';

% Reference Trajectories
conf.refTraj        = '..\fisheyecameranlos\Data\SPAN\EXP18_ROT02\EXP18-02_ReferenceTrajectory_3GCAntenna_VelocityData.txt';	% SPAN reference position
conf.refRot         = '..\fisheyecameranlos\Data\SPAN\EXP18_ROT02\EXP18_Rotterdam_02_RTK_SPAN_Roll_Pitch_Heading.txt';          % SPAN reference orientation

% GNSS Related Input
conf.constellation  = 'GER';    % Define constellations to be used [G] -> GPS / [E] -> Galileo / [R] -> GLONASS

% Path to RINEX Input Files (Navigation)
conf.RINEXnavGPS    = '..\fisheyecameranlos\Data\RINEXNav\EXP18_ROT02\FOC-2070.18N';                               
conf.RINEXnavGAL    = '..\fisheyecameranlos\Data\RINEXNav\EXP18_ROT02\FOC-2070.18L';                                           
conf.RINEXnavGLO    = '..\fisheyecameranlos\Data\RINEXNav\EXP18_ROT02\FOC-2070.18G';       

% Path to calibration .mat files
conf.azCalib        = '..\fisheyecameranlos\Data\Calibration\az_calibration.mat';
conf.elCalib        = '..\fisheyecameranlos\Data\Calibration\el_calibration.mat';

% MMRx5 Observations (RINEX) and Settings 
conf.RINEXobsMMRx   = '..\fisheyecameranlos\Data\UbxData\EXP18_ROT02\COM36_180726_122440_Rx5_EXP02_2018_NEW.obs';	% MMrx5 observables and time
conf.receiver       = 'MMRx5';          % Name of the receiver
conf.ObsToProcess   = 'CSD';            % Observables to process [C] -> Code / [S] -> CN0 / [D] -> Doppler (Should contain C)
conf.ignoreSvs      = {'G04' 'E20'};    % Spacecraft to be ignored

% Output file names
conf.testVideo      = '..\fisheyecameranlos\Output\EXP18_ROT02\testVideo.mp4';  % Name and location of testvideo
conf.probConf       = '..\fisheyecameranlos\Output\EXP18_ROT02\conf_coefs.txt'; % Output txt file containing confidence coefficients for each computed timeframe
conf.FrameRate      = 1;                                            % Frame rate [frames/second] for testVideo
conf.camForwardDir  = 0;                                            % Boolean describing weather camera calibration is in forward [1] or rearward [0] direction

% Probability map settings
conf.saveProbMatPath    = '..\fisheyecameranlos\Data\ProbabilityData\EXP18_ROT02\';
conf.saveProbMatName    = 'probmat_EXP18_02_Rotterdam_';
conf.Filter             = '..\fisheyecameranlos\Data\Calibration\Filter.mat';

% Span Reader Settings (Ensure your input files have this format)
conf.idxSpWn        = 1;
conf.idxSpTow       = 2;
conf.idxSpX         = 3;
conf.idxSpY         = 4;
conf.idxSpZ         = 5;
conf.idxSpVx        = 6;
conf.idxSpVy        = 7;
conf.idxSpVz        = 8;
conf.idxSpRoll      = 3;
conf.idxSpPitch     = 4;
conf.idxSpHeading   = 5;
