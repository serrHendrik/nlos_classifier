function [nav] = RINEX_Processing(conf)
 
% SYNTAX;
%   [nav] = RINEX_Processing(conf)
%
% INPUT:
% - conf:
%
% OUTPUT:
% - nav: 
%
% DESCRIPTION
%   Function that reads the RINEX observation and navigation files. The
%   resulting navigation and observation parameters are processed for the
%   requested timescale as specified in the conf struct (see INPUT)
%
% NOTE Time in the RINEX files refers to GPS TIME -> Thus transfer to UTC
% is required if necessary
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author: Floor Melman
% Company: European Space Agency
%
% Date: 07.02.2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Change History
% 
% - V0.1: Prototyping
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get Frequency Bands
init_toolchain;

% Get time window for which observations should be processed
[firstEpochGPS] = utc2gpstime(sscanf(conf.firstEpoch,conf.dateFormat)');    % First epoch for selected data
[lastEpochGPS]  = utc2gpstime(sscanf(conf.lastEpoch,conf.dateFormat)');     % Last epoch for selected data

% Create Empty Struct for Storage field of all detected spacecraft
nav.allSv       = [];

% Assign RINEX File location selected Receiver
if strcmp(conf.receiver,'MMRx5')
    receiverRINEX   = conf.RINEXobsMMRx;
elseif strcmp(conf.receiver,'PRORx2')
    receiverRINEX   = conf.RINEXobsPRORx2;
end

% Load GPS RINEX Observation files
if(~isempty(strfind(conf.constellation,'G')))
    
    % Define constellation settings
    [nav.G.constellations]                                    =   multi_constellation_settings(1, 0, 0, 0, 0, 0);
    
    % Retrieve ephemeris settings
    [nav.G.eph, nav.G.iono, nav.G.corrSysTime]                =   load_RINEX_nav(conf.RINEXnavGPS, nav.G.constellations, 0);
    
    % Get Observation data
    [pr1, ~, ~, ~, dop1, ~, snr1, ~, ~, time, ~, ~, ~, ~, ~, ~] 	= ...
        load_RINEX_obs(receiverRINEX, nav.G.constellations);
    
    % Selected timescale
    indicesTimeSelected = find(round(time) >= round(firstEpochGPS) & round(time) < round(lastEpochGPS));
       
    % Find detected GPS spacecraft within selected timeframe
    gpsPRNselected      = find(any(pr1(:,indicesTimeSelected)'));
    
    % Remove spacecraft observations that are selected for ignorance
    [~,indexIgnoreSv]   = intersect(cellstr(strcat('G',num2str(gpsPRNselected','%02.0f'))),conf.ignoreSvs);
    
    % Remove spacecraft to be ignored form PRN selection
    if ~isempty(indexIgnoreSv)
        for i = 1:length(indexIgnoreSv)
            gpsPRNselected(indexIgnoreSv(i))    = [];
        end
    end
    
    % Store Code Observables
    if(~isempty(strfind(conf.ObsToProcess,'C')))    % Only load Code Observables if selected
        matObs              = pr1(gpsPRNselected,indicesTimeSelected);
        matObs(matObs == 0) = NaN;
        nav.G.matObs        = matObs;
    end
    
    % Store CN0 Observables
    if(~isempty(strfind(conf.ObsToProcess,'S')))    % Only load CN0 Observables if selected
        matCN0              = snr1(gpsPRNselected,indicesTimeSelected);
        matCN0(matCN0 == 0) = NaN;
        nav.G.matCN0        = matCN0;
    end
    
    % Store Doppler Observables (only phase
    if(~isempty(strfind(conf.ObsToProcess,'D')))    % Only load Doppler Observables if selected
        matDopp                 = dop1(gpsPRNselected,indicesTimeSelected);
        matDopp(matDopp == 0)   = NaN;
        
        % Convert carrier phase observable to meters
        phaseToMeter            = C / BANDS.('G1').f;
        nav.G.matDopp           = -matDopp.*phaseToMeter;
        
        % Check if there are any Doppler measurements for GPS
        if isempty(nav.G.matDopp)
            conf.flagDopplerGPS = 0;        
        else
            conf.flagDopplerGPS = 1;
        end   
    end
    
    % Store spacecraft PRN
    nav.G.allSv                 = gpsPRNselected;
    
    % Store all spacecraft Identifiers in nav struct
    nav.allSv                   = [nav.allSv; cellstr(strcat('G',num2str(gpsPRNselected','%02.0f')))];
    
    % Save Timescale
    if ~isfield(nav,'timeScale')
        nav.timeScale   = time(indicesTimeSelected)';
    end
    
end

% Load GLONASS RINEX Observation files
if(~isempty(strfind(conf.constellation,'R')))
    
    % Define constellation settings
    [nav.R.constellations]                                    =   multi_constellation_settings(0, 1, 0, 0, 0, 0);
    
    % Retrieve ephemeris settings
    [nav.R.eph, nav.R.iono, nav.R.corrSysTime]                =   load_RINEX_nav(conf.RINEXnavGLO, nav.R.constellations, 0);
    
    % Get Observation data
    [pr1, ~, ~, ~, dop1, ~, snr1, ~, ~, time, ~, ~, ~, ~, ~, ~] 	= ...
        load_RINEX_obs(receiverRINEX, nav.R.constellations);
    
    % Selected timescale
    indicesTimeSelected = find(round(time) >= round(firstEpochGPS) & round(time) < round(lastEpochGPS));
       
    % Find detected GLONASS spacecraft within selected timeframe
    gloPRNselected      = find(any(pr1(:,indicesTimeSelected)'));
    
    % Remove spacecraft observations that are selected for ignorance
    [~,indexIgnoreSv]   = intersect(cellstr(strcat('R',num2str(gloPRNselected','%02.0f'))),conf.ignoreSvs);
    
    % Remove spacecraft to be ignored form PRN selection
    if ~isempty(indexIgnoreSv)
        for i = 1:length(indexIgnoreSv)
            gloPRNselected(indexIgnoreSv(i))    = [];
        end
    end
    
    % Store Code Observables
    if(~isempty(strfind(conf.ObsToProcess,'C')))    % Only load Code Observables if selected
        matObs              = pr1(gloPRNselected,indicesTimeSelected);
        matObs(matObs == 0) = NaN;
        nav.R.matObs        = matObs;
    end
    
    % Store CN0 Observables
    if(~isempty(strfind(conf.ObsToProcess,'S')))    % Only load CN0 Observables if selected
        matCN0              = snr1(gloPRNselected,indicesTimeSelected);
        matCN0(matCN0 == 0) = NaN;
        nav.R.matCN0        = matCN0;
    end
    
    % Store Doppler Observables
    if(~isempty(strfind(conf.ObsToProcess,'D')))    % Only load Doppler Observables if selected
        matDopp                 = dop1(gloPRNselected,indicesTimeSelected);
        matDopp(matDopp == 0)   = NaN;
        
        % Convert carrier phase observable to meters
        phaseToMeter            = C / BANDS.('R1').f;
        nav.R.matDopp           = -matDopp.*phaseToMeter;

        % Check if there are any Doppler measurements for GLONASS
        if isempty(nav.R.matDopp)
            conf.flagDopplerGLO = 0;        
        else
            conf.flagDopplerGLO = 1;
        end   
    end
    
    % Store spacecraft PRN
    nav.R.allSv                 = gloPRNselected;
    
    % Store all spacecraft Identifiers in nav struct
    nav.allSv                   = [nav.allSv; strcat('R',cellstr(num2str(gloPRNselected','%02.0f')))]; 
    
    % Save Timescale
    if ~isfield(nav,'timeScale')
        nav.timeScale   = time(indicesTimeSelected)';
    end
    
end

% Load Galileo RINEX Observation files
if(~isempty(strfind(conf.constellation,'E')))
    
    % Define constellation settings
    [nav.E.constellations]                                    =   multi_constellation_settings(0, 0, 1, 0, 0, 0);
    
    % Retrieve ephemeris settings
    [nav.E.eph, nav.E.iono, nav.E.corrSysTime]                =   load_RINEX_nav(conf.RINEXnavGAL, nav.E.constellations, 0);
    
    % Get Observation data
    [pr1, ~, ~, ~, dop1, ~, snr1, ~, ~, time, ~, ~, ~, ~, ~, ~] 	= ...
        load_RINEX_obs(receiverRINEX, nav.E.constellations);
    
    % Selected timescale
    indicesTimeSelected = find(round(time) >= round(firstEpochGPS) & round(time) < round(lastEpochGPS));
       
    % Find detected Galileo spacecraft within selected timeframe
    galPRNselected      = find(any(pr1(:,indicesTimeSelected)'));
    
    % Remove spacecraft observations that are selected for ignorance
    [~,indexIgnoreSv]   = intersect(cellstr(strcat('E',num2str(galPRNselected','%02.0f'))),conf.ignoreSvs);
    
    % Remove spacecraft to be ignored form PRN selection
    if ~isempty(indexIgnoreSv)
        for i = 1:length(indexIgnoreSv)
            galPRNselected(indexIgnoreSv(i))    = [];
        end
    end
    
    % Store Code Observables
    if(~isempty(strfind(conf.ObsToProcess,'C')))    % Only load Code Observables if selected
        matObs              = pr1(galPRNselected,indicesTimeSelected);
        matObs(matObs == 0) = NaN;
        nav.E.matObs        = matObs;
    end
    
    % Store CN0 Observables
    if(~isempty(strfind(conf.ObsToProcess,'S')))    % Only load CN0 Observables if selected
        matCN0              = snr1(galPRNselected,indicesTimeSelected);
        matCN0(matCN0 == 0) = NaN;
        nav.E.matCN0        = matCN0;
    end
    
    % Store Doppler Observables
    if(~isempty(strfind(conf.ObsToProcess,'D')))    % Only load Doppler Observables if selected
        matDopp                 = dop1(galPRNselected,indicesTimeSelected);
        matDopp(matDopp == 0)   = NaN;
        
        % Convert carrier phase observable to meters
        phaseToMeter            = C / BANDS.('E1').f;
        nav.E.matDopp           = -matDopp.*phaseToMeter;
        
        % Check if there are any Doppler measurements for Galileo
        if isempty(nav.E.matDopp)
            conf.flagDopplerGAL = 0;        
        else
            conf.flagDopplerGAL = 1;
        end   
    end
    
    % Store spacecraft PRN
    nav.E.allSv                 = galPRNselected;
    
    % Store all spacecraft Identifiers in nav struct
    nav.allSv                   = [nav.allSv; cellstr(strcat('E',num2str(galPRNselected','%02.0f')))]; 
    
    % Save Timescale
    if ~isfield(nav,'timeScale')
        nav.timeScale   = time(indicesTimeSelected)';
    end
    
end

% Store total number of Detected Spacecraft during selected epochs
nav.allSVnb     = length(nav.allSv);

end
