function [nav] = ubxProcessing(conf)
% Function to read and process UBX observables which are already parced by
% parseUbxFile.m as ([cds, cells] = parseUbxFile( 'fileName' ).
% Consesequently cds should be saved -> 
% save('inputCdsObsData','-struct','cds')
%
% Input:
% - conf:
%
% Ouput:
% - nav: 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author: Floor Melman
% Company: European Space Agency
%
% Date: 21.01.2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Change History
% 
% - V0.1: Prototyping
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize Speed of Light and Frequency Bands
init_toolchain;

% Labels for datatag
labelC  = 'C1C$';   % Code phase observable) [m]
labelS  = 'S1C$';   % CN0 [dbHz]
labelD  = 'D1C$';   % Doppler Observable [??] -> Check

% Read .mat file and store under appropriate Rx name
gnssObservables.(conf.receiver) = cdsAddSource(conf.MMRxData);

% Retreive and process input settings for cdsSelectObservables.m
obsConfig.receiver          = {conf.receiver};                      % Selected Rx
obsConfig.constellation     = conf.constellation;                   % Selected Constellations (G/E/R)
obsConfig.channels          = {'^CH$'};                             % Channels
obsConfig.ignoreSvs         = conf.ignoreSvs;                       % SVs tp be ignored
obsConfig.firstEpoch        = utc2gpstime(sscanf(conf.firstEpoch,conf.dateFormat)');% First epoch for selected data
obsConfig.lastEpoch         = utc2gpstime(sscanf(conf.lastEpoch,conf.dateFormat)'); % Last epoch for selected data

% Pre selection -> Ss, OBS, CHS but only truncated to timespan
% Process originating from pnt2_run_prepro.m
selObs                      = cdsSelectObservables(gnssObservables, obsConfig);

%% write it out for each sv
% Following is copied from pnt2_run_prepro.m
% Copyright: ??

rxs = fieldnames(selObs);   % Retrieve Receiver

for i = 1:length(rxs)       % Loop over all receivers (should be 1)
    rx = rxs{i};            % Current receiver
    targetPrefix = ['PREPRO.OBS.GNSS.' rx];     % Set structure layout for storage of observables
    
    % Set target fields in struct to be read (from field LABELS) 
    % -> all SVs with all observable types
    targets = structMapAdresses( selObs.(rx).labels, targetPrefix, 2 );     

    % Save timescale
    eval( [targetPrefix '.timescale = selObs.' rx '.timescale ;'] );
    
    % Loop over number of SVs with number of Observables
    for j = 1:length(targets)
       target = targets{j};
       
       % Apply Phase to Meter conversion (only for carrier phase and
       % Doppler observables)
       sTarget = split(target, '.');
       sObs = sTarget{end};
       sType = sObs(1);
       if (strcmp(sType, 'L') && length(sObs) == 3) || (strcmp(sType, 'D') && length(sObs) == 3)
            sSv = sTarget{end-2};
            key = sprintf('%s%s', sSv(1), sObs(2));
            phaseToMeter = C / BANDS.(key).f;
            selObs.(rx).Obs(j,:) = selObs.(rx).Obs(j,:) * phaseToMeter * (-1)^strcmp(sType, 'D');
       end
       % Save in cds format (evaluate string operation)
       cmd = sprintf('%s = selObs.%s.Obs(%d,:);', target, rx, j) ;  
       eval( cmd );
    end
end

%% Load RINEX navigation files

% Read GPS navigation message (File extension should end with .yyN)
if(~isempty(strfind(conf.constellation,'G')))
    [nav.G.constellations]                                    =   multi_constellation_settings(1, 0, 0, 0, 0, 0);
    [nav.G.eph, nav.G.iono, nav.G.corrSysTime]                =   load_RINEX_nav(conf.RINEXnavGPS, nav.G.constellations, 0);
end

% Read GLONASS navigation message (File extension should end with .yyL)
if(~isempty(strfind(conf.constellation,'R')))
    [nav.R.constellations]                                    =   multi_constellation_settings(0, 1, 0, 0, 0, 0);
    [nav.R.eph, ~, nav.R.corrSysTime]                         =   load_RINEX_nav(conf.RINEXnavGLO, nav.R.constellations, 0);
end

% Read Galileo navigation message (File extension should end with .yyG)
if(~isempty(strfind(conf.constellation,'E')))
    [nav.E.constellations]                                    =   multi_constellation_settings(0, 0, 1, 0, 0, 0);
    [nav.E.eph, nav.E.iono, nav.E.corrSysTime]                =   load_RINEX_nav(conf.RINEXnavGAL, nav.E.constellations, 0);
    if(~(~isempty(strfind(conf.constellation,'G'))))
        nav.G.iono                                            =   nav.E.iono;
    end
end

%% Convert the OBSERVATION data from (preprocessed) CDS to a MATRIX

% Get the fields that contain all the satellites that have been observed
nav.allSv                                                     =   fieldnames(PREPRO.OBS.GNSS.(conf.receiver)); % For preprocessed.

% Remove the timescale field name from the list with available SVs
nav.allSv{1}                                                  =   [];
nav.allSv                                                     =   nav.allSv(~cellfun('isempty',nav.allSv));     % Correct matrix size

% Add time vector to nav structure
nav.timeScale                                                 =   PREPRO.OBS.GNSS.(conf.receiver).timescale;    % Add tag with timescale

%% Load GPS Observables (if selected)

if(~isempty(strfind(conf.constellation,'G')))   
    % Selection of observables
    if(~isempty(strfind(conf.ObsToProcess,'C')))    % Only load Code Observables if selected
        filter                                                  =   {{'G\d\d'} {} {labelC}};                    % Select GPS C1C measurements.
        [nav.G.matObs, ~]                                       =   cds2matrix(PREPRO.OBS.GNSS.(conf.receiver), filter);
    end
    
    if(~isempty(strfind(conf.ObsToProcess,'S')))    % Only load CN0 Observables if selected
        filter                                                  =   {{'G\d\d'} {} {labelS}};                    % Select C/N0 of the C1C measurements.
        [nav.G.matCN0, ~]                                       =   cds2matrix(PREPRO.OBS.GNSS.(conf.receiver), filter);
    end
    
    if(~isempty(strfind(conf.ObsToProcess,'D')))    % Only load Doppler Observables if selected
        filter                                                  =   {{'G\d\d'} {} {labelD}};                    % Select GPS D1C measurements.
        [nav.G.matDopp, ~]                                      =   cds2matrix(PREPRO.OBS.GNSS.(conf.receiver), filter);
        
        % Check if there are any Doppler measurements for GPS
        if isempty(nav.G.matDopp)
            conf.flagDopplerGPS = 0;        
        else
            conf.flagDopplerGPS = 1;
        end    
    end
       
    % Convert the observed SVs from string to numbers
    nav.G.allSv                                               =   regexp(nav.allSv,'G\d*','match');
    nav.G.allSv                                               =   nav.G.allSv(~cellfun('isempty',nav.G.allSv));
    nav.G.allSv                                               =   vertcat(nav.G.allSv{:});
    nav.G.allSv                                               =   regexp(nav.G.allSv,'\d*','match');
    nav.G.allSv                                               =   cellfun(@str2num,[nav.G.allSv{:,1}]);
end

%% Load Galileo Observables (if selected)

if(~isempty(strfind(conf.constellation,'E')))
    % Selection of observables
    if(~isempty(strfind(conf.ObsToProcess,'C')))    % Only load Code Observables if selected
        filter                                                  =   {{'E\d\d'} {} {labelC}};                    % Select Galileo C1C measurements.
        [nav.E.matObs, ~]                                       =   cds2matrix(PREPRO.OBS.GNSS.(conf.receiver), filter);
    end
    
    if(~isempty(strfind(conf.ObsToProcess,'S')))    % Only load CN0 Observables if selected
        filter                                                  =   {{'E\d\d'} {} {labelS}};                    % Select Galileo of the C1C measurements.
        [nav.E.matCN0, ~]                                       =   cds2matrix(PREPRO.OBS.GNSS.(conf.receiver), filter);
    end
    
    if(~isempty(strfind(conf.ObsToProcess,'D')))    % Only load Doppler Observables if selected
        filter                                                  =   {{'E\d\d'} {} {labelD}};                    % Select Galileo D1C measurements.
        [nav.E.matDopp, ~]                                      =   cds2matrix(PREPRO.OBS.GNSS.(conf.receiver), filter);
        
        % Check if there are any Doppler measurements for Galileo
        if isempty(nav.E.matDopp)
            conf.flagDopplerGAL = 0;        
        else
            conf.flagDopplerGAL = 1;
        end    
    end
    
    % Convert the observed SVs from string to numbers
    nav.E.allSv                                               =   regexp(nav.allSv,'E\d*','match');
    nav.E.allSv                                               =   nav.E.allSv(~cellfun('isempty',nav.E.allSv));
    nav.E.allSv                                               =   vertcat(nav.E.allSv{:});
    nav.E.allSv                                               =   regexp(nav.E.allSv,'\d*','match');
    nav.E.allSv                                               =   cellfun(@str2num,[nav.E.allSv{:,1}]);
end

%% Load GLONASS Observables (if selected)

if(~isempty(strfind(conf.constellation,'R')))   
    % Selection of observables
    if(~isempty(strfind(conf.ObsToProcess,'C')))    % Only load Code Observables if selected
        filter                                                  =   {{'R\d\d'} {} {labelC}};                    % Select GLONASS C1C measurements.
        [nav.R.matObs, ~]                                       =   cds2matrix(PREPRO.OBS.GNSS.(conf.receiver), filter);
    end
    
    if(~isempty(strfind(conf.ObsToProcess,'S')))    % Only load CN0 Observables if selected
        filter                                                  =   {{'R\d\d'} {} {labelS}};                    % Select GLONASS of the C1C measurements.
        [nav.R.matCN0, ~]                                       =   cds2matrix(PREPRO.OBS.GNSS.(conf.receiver), filter);
    end
    
    if(~isempty(strfind(conf.ObsToProcess,'D')))    % Only load Doppler Observables if selected
        filter                                                  =   {{'R\d\d'} {} {labelD}};                    % Select GLONASS D1C measurements.
        [nav.R.matDopp, ~]                                      =   cds2matrix(PREPRO.OBS.GNSS.(conf.receiver), filter);
        
        % Check if there are any Doppler measurements for GLONASS
        if isempty(nav.R.matDopp)
            conf.flagDopplerGLO = 0;        
        else
            conf.flagDopplerGLO = 1;
        end    
    end
    
    % Convert the observed SVs from string to numbers
    nav.R.allSv                                               =   regexp(nav.allSv,'R\d*','match');
    nav.R.allSv                                               =   nav.R.allSv(~cellfun('isempty',nav.R.allSv));
    nav.R.allSv                                               =   vertcat(nav.R.allSv{:});
    nav.R.allSv                                               =   regexp(nav.R.allSv,'\d*','match');
    nav.R.allSv                                               =   cellfun(@str2num,[nav.R.allSv{:,1}]);
end

%% Deduce the total number of satellites that have been observed

nav.allSVnb                                                   =   length(nav.allSv);    % Total number of SVs for selected constellation

end



