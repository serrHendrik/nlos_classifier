function [outObsModel, nbObsSvConst, store] = genObservationModel(nav, store, conf, estimStates, ii)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% The function generates the parameters related to the pseudorange
% observation model:
%
%   G        - observation (geometry) matrix
%   R        - variance-covariance matrix of the measurement noise
%   y        - observation vector (for WLS)
%   predMeas - predicted measurement (for EKF)
%
% Called in: posKFupdate.m, posWLSE.m
%
% created by: Sebastian Ciuban
% company   : European Space Agency
%
%%%%%%%%%%%%%%%%%%%% History (from PNT2 V1.1 onwards) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% PNT2 V1.2 : - This function was not present in V1.1 (Sebastian Ciuban)
%             - Handles the particularities of the iono correction for
%               GLONASS (Sebastian Ciuban)
%             - Added the calling history in the header description
%              (Sebastian Ciuban 20.11.2018)
%             - Handles the case when no Galileo, GLONASS satellites are
%               visible (required only for WLS estimator)
%
% PNT2 V1.3 : - Added processing of precise products (IONEX, TROPO, ANTEX,
%               Shapiro Delay
%             - Added third order difference weighting
%             - Added SV exclusion based on camera NLOS/LOS classification

%             - Added storage of weights
% 

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% INPUT:
%
%       nav           =  structure containing navigation related variables
%       store         =  structure containing stored variables
%       conf          =  structure containing the processing configurations
%       estimStates   =  structure containing the estimated states (pos, vel)
%       ii            =  epoch counter
%
%
% OUTPUT:
%
%       outObsModel    = structure containing the generated parameters of
%                        the observation model
%       nbObsSvConst   = structure containing information about the
%                        observed satellites for each GNSS constellation
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Input variables and other initializations

% Constants
C   = 299792458;            % speed of light [m/s]
R2D = 180/pi;               % Radians to degrees


if strcmp(conf.frequency,'E5a') || strcmp(conf.frequency,'L5')
    measurementPR_type= 'prC5Q';
    measurementPRR_type= 'prrD5Q';
elseif strcmp(conf.frequency,'E1') || strcmp(conf.frequency,'L1')
    measurementPR_type = 'prC1C';
    measurementPRR_type = 'prrD1C';
else
        measurementPR_type = 'prC1C';
    measurementPRR_type = 'prrD1C';
end


% Dependency on the estimator
if (conf.posAlgorithm == 1)
    xHat                        =   nav.xHat;
end

% Initialize Vectors
satPos                          =   [];
outObsModel.measurement         =   [];
dtSat                           =   [];
CN0                             =   [];
nbObsSvConst                    =   [];
outObsModel.obsSv               =   [];
satVel                          =   [];
thirdOrddiff                    =   [];
ionoCoeff                       =   nav.G.iono;

% Create Additional vectors if Camera Usage is Enabled

if conf.cameraUsage == 1
    indexIslosVector                =   find(nav.islos.time == round(nav.timeRx));
    islosVector                     =   [];
    nbObsSvConstRej                 =   [];
end

% Read GPS Data
if(~isempty(findstr(conf.constellation,'G')))
    satPos                      =   [satPos; nav.G.satCoord];
    outObsModel.measurement     =   [outObsModel.measurement; nav.G.(measurementPR_type)];
    dtSat                       =   [dtSat; nav.G.dtSat];
    nbObsSvConst                =   [nbObsSvConst; nav.G.nbObsSvConst];
    outObsModel.obsSv           =   [outObsModel.obsSv; nav.G.obsSv];
    % Retrieve Additional Variables when Camera Filtering is Enabled

    if conf.cameraUsage == 1 
        [~,svRowsSelected]      =   intersect(nav.islos.G.svPRN,nav.G.obsSv);
        islosVector             =   [islosVector; nav.islos.G.data(svRowsSelected,indexIslosVector)];
        nbObsSvConstRej         =   [nbObsSvConstRej; length(find(nav.islos.G.data(svRowsSelected,indexIslosVector) <= 0.45))];
    end
    if conf.flagCNoGPS      % Only save this data when availble

        CN0                      =   [CN0; nav.G.CN0];
    end
    if conf.prefiltering    % Only save this data when prefiltering is set
        thirdOrddiff             =   [thirdOrddiff;nav.G.thirdorderdiff];
    end
    nbObsSvConstGPS             =   nav.G.nbObsSvConst;

end

% Read Galileo Data
if(~isempty(findstr(conf.constellation,'E')))
    satPos                      =   [satPos; nav.E.satCoord];
    outObsModel.measurement     =   [outObsModel.measurement; nav.E.(measurementPR_type)];
    dtSat                       =   [dtSat; nav.E.dtSat];
    CN0                         =   [CN0; nav.E.CN0];
    nbObsSvConst                =   [nbObsSvConst; nav.E.nbObsSvConst];
    outObsModel.obsSv           =   [outObsModel.obsSv; nav.E.obsSv];
    if conf.timeOffset == 0
        TimeOffsetsBrdc.storeTOGAL_brdc =   store.E.TO_brdc(ii);
    elseif conf.timeOffset == 2
        TimeOffsetsBrdc.storeTOGAL_brdc =   store.E.XGTO(ii);
    end
    if conf.prefiltering    % Only save this data when prefiltering is set

        thirdOrddiff             =   [thirdOrddiff;nav.E.thirdorderdiff];
    end
    nbObsSvConstGAL             =   nav.E.nbObsSvConst;
    % Retrieve Additional Variables when Camera Filtering is Enabled
    if conf.cameraUsage == 1
        [~,svRowsSelected]      =   intersect(nav.islos.E.svPRN,nav.E.obsSv);
        islosVector             =   [islosVector; nav.islos.E.data(svRowsSelected,indexIslosVector)];
        nbObsSvConstRej         =   [nbObsSvConstRej; length(find(nav.islos.E.data(svRowsSelected,indexIslosVector) <= 0.45))];
    end
    
end

% Read GLONASS Data
if(~isempty(findstr(conf.constellation,'R')))
    satPos                      =   [satPos; nav.R.satCoord];
    outObsModel.measurement     =   [outObsModel.measurement; nav.R.(measurementPR_type)];
    dtSat                       =   [dtSat; nav.R.dtSat];
    CN0                         =   [CN0; nav.R.CN0];
    nbObsSvConst                =   [nbObsSvConst; nav.R.nbObsSvConst];
    outObsModel.obsSv           =   [outObsModel.obsSv; nav.R.obsSv];
    if(~conf.timeOffset)
        TimeOffsetsBrdc.storeTOGLO_brdc =   store.R.TO_brdc(ii);
    end
    if conf.prefiltering    % Only save this data when prefiltering is set

        thirdOrddiff             =   [thirdOrddiff;nav.R.thirdorderdiff];
    end
    % Retrieve Additional Variables when Camera Filtering is Enabled
    if conf.cameraUsage == 1
        [~,svRowsSelected]      =   intersect(nav.islos.R.svPRN,nav.R.obsSv);
        islosVector             =   [islosVector; nav.islos.R.data(svRowsSelected,indexIslosVector)];
        nbObsSvConstRej         =   [nbObsSvConstRej; length(find(nav.islos.R.data(svRowsSelected,indexIslosVector) <= 0.45))];
    end

end

% Only Evaluate if Camera is used to reject observations
if conf.cameraUsage == 1
    islosVector(isnan(islosVector)) 	= 1;
    indicesRejected                     = [];
    % indicesRejected                    	= islosVector == 0; % For SVs with hybrid probability of 0 -> reject
end

% Store CN0 for usage in Kalman fitler update function
outObsModel.CN0         = CN0;


% Add Doppler data if Doppler usage is enabled
if conf.usePrRate
    if(~isempty(findstr(conf.constellation,'G')))
        satVel                  =   [satVel; nav.G.satVel];
        outObsModel.measurement =   [outObsModel.measurement; nav.G.(measurementPRR_type)];
    end
    
    if(~isempty(findstr(conf.constellation,'E')))
        satVel                  =   [satVel; nav.E.satVel];
        outObsModel.measurement =   [outObsModel.measurement; nav.E.(measurementPRR_type)];
    end
    
    if(~isempty(findstr(conf.constellation,'R')))
        satVel                  =   [satVel; nav.R.satVel];
        outObsModel.measurement =   [outObsModel.measurement; nav.R.(measurementPRR_type)];
    end
end

% Time conversions for the tropo correction (doy required)
[ gps_sow, gps_week ]          = timescaleToTowWnc( nav.timeRx );
[date, doy, ~]                 = gps2date(gps_week, gps_sow);

% convert to calendar format -> required for solid tide model)

[CalendarTime, ~]   = gps2utc(gps_week, gps_sow, 0);
Y                   = CalendarTime(1); % year
M                   = CalendarTime(2); % month
D                   = CalendarTime(3) + CalendarTime(4)./24 + CalendarTime(5)./(60*24) + CalendarTime(:,6)./(60*60*24);

% Number of observed satellites (after masking)
outObsModel.nbSV               = size(satPos,1);

% Declare storage variables
outObsModel.eL                 = zeros(outObsModel.nbSV,1);                           % for storing elevations
aZ                             = zeros(outObsModel.nbSV,1);                           % for storing satellite's azimuths
dist_0                         = zeros(outObsModel.nbSV,1);                           % for storing the geometric distances
dist_r0                        = zeros(outObsModel.nbSV,1);                           % for storing geometric range rate
ionoCorr                       = zeros(outObsModel.nbSV,1);                           % for storing iono corrections
tropoCorr                      = zeros(outObsModel.nbSV,1);                           % for storing tropo corrections
shapiroCorr                    = zeros(outObsModel.nbSV,1);                           % for storing the shapiro delay corrections
antennaPhaseCentercorr         = zeros(outObsModel.nbSV,1);                           % for storing the antenna phase center corrections
% tgdcorrection                  = zeros(outObsModel.nbSV,1);                           % for storing the Total Group Delay Correction
% RelativisticCLKcorr            = zeros(outObsModel.nbSV,1);                           % for storing the Relativistic Clock Correction
SolidTideCorr                  = zeros(outObsModel.nbSV,1);                           % for storing the Solid Tides Correction

% Dependency on the estimator
outObsModel.G                  = zeros(outObsModel.nbSV * (1 + conf.usePrRate), nav.numStates);	% Geometry matrix

% Observation vector (used for WLS)
outObsModel.y                   = zeros(outObsModel.nbSV * (1 + conf.usePrRate),1);            	% observation vector (y = G * xHat)

% Observation vector - full predicted pseudorange measurement (used for EKF)
outObsModel.predMeas          	= zeros(outObsModel.nbSV * (1 + conf.usePrRate),1);

% VCV matrix of the outObsModel.measurements
outObsModel.R                 	= eye(outObsModel.nbSV * (1 + conf.usePrRate));

% Initialize a satellite counter for Galileo
countGalileo                 	= 0;

countGalileoR                   = 0;

% Number of observed satellites (after masking)
outObsModel.nbSV               	= size(satPos,1);

% Corrections computation
assert(~isnan(estimStates.posRx(1)), 'WARNING: posRx variable has NaN values!')
llh                             = xyz2llh(estimStates.posRx(1:3));
lat                             = llh(1) * R2D; % indegrees
lon                             = llh(2) * R2D;

% Input for MOPS Tropo Model
if lat < 0
    Hemisphere  = 'Southern';
elseif lat >= 0
    Hemisphere  = 'Northern';
end

%% Loop over the observed satellites

for jj = 1:outObsModel.nbSV
    
    % Determine the satellite azimuth and elevation

    [aZ(jj), eL]        = topocent_v6(estimStates.posRx(1:3), satPos(jj,:));
    outObsModel.eL(jj)  = eL;
    
    assert(~isnan(estimStates.posRx(1)), 'WARNING: posRx variable has NaN values!')
    llh                                      = xyz2llh(estimStates.posRx(1:3));
    
    %% Tropospheric correction
    switch conf.tropocorr
        case 0  % UNB3M Model
            [tropoCorr(jj), ~, ~, ~,~]	= UNB3M(llh(1),llh(3),doy,outObsModel.eL(jj)*pi/180);
        case 1  % MOPS Tropo Model
            [tropoCorr(jj)]             = MOPS_tropo_model_UNB3M(lat,llh(3),Hemisphere,date,outObsModel.eL(jj)); % Update tropospheric model Javier Miguez 03-12-2018
    end

    %% Ionospheric correction
    switch conf.ionocorr
        case 0 % Broadcast iono correction
            
            ionoCorr(jj)    = iono_error_correction(lat, lon, aZ(jj),  outObsModel.eL(jj), nav.timeRx, ionoCoeff, [],2);

            
        case 1 % IONEX
            
            time_ws         = [gps_week gps_sow];
            sat_tec         = ionodelay_tec(time_ws, estimStates.posRx(1:3),  satPos(jj,:), nav.ionex);
            ionoCorr(jj)    = (40.3./(1575.42e6 * 1575.42e6)) .* (sat_tec.*10^16);
            
        otherwise
            % No iono correction will be implemented
    end
    
        
    % Handles the particularities of the ionospheric correction when
    % GLONASS is being used
    switch conf.constellation
        case 'E'
            % GLONASS is not present here. % Updated 28-02-2019 F.T. Melman
        case 'G'
            % GLONASS is not present here. % Updated 03-12-2018 J. Miguez
        case 'GE'

            if strcmp(conf.frequency,'E5a') || strcmp(conf.frequency,'L5')
                ionoCorr(jj)                  = ionoCorr(jj)*(1575.42/1176.45)^2;
            end
            % GLONASS is not present here. % Updated 03-12-2018 J. Miguez
        case {'GR',nbObsSvConst(2)==0}
            
            if jj > (nbObsSvConst(1))
                ionoCorr(jj)                  = ionoCorr(jj)*(1575.42/(1602+(nav.R.freq_num(jj-(nbObsSvConst(1)))*0.5625)))^2;
            end
            
        case 'GER'
            if jj > (nbObsSvConst(1)+nbObsSvConst(2))
                ionoCorr(jj)                  = ionoCorr(jj)*(1575.42/(1602+(nav.R.freq_num(jj-(nbObsSvConst(1)+nbObsSvConst(2)))*0.5625)))^2;
            end
            
    end
    
    %% Solid tides correction
    % Moon and Sun coordinates in ECEF
    [rmoon,rsun]        = Moon_Sun_Coordinates(Y,M,D);
    SolidTideCorr(jj)   = solid_tides_v2( estimStates.posRx(1:3), llh(1),rmoon,rsun,satPos(jj,:));
    
    %% Compute the Shapiro delay
    switch conf.PreciseProducts
        case 0 % Broadcast data
            switch conf.constellation
                case 'E'
                    [shapiroCorr(jj),~]                      = relativistic_range_error_correction(estimStates.posRx(1:3)', satPos(jj,:),nav.E.eph);
                case 'G'
                    [shapiroCorr(jj),~]                      = relativistic_range_error_correction(estimStates.posRx(1:3)', satPos(jj,:),nav.G.eph);
                case 'GE'
                    
                    if jj > nbObsSvConstGPS
                        [shapiroCorr(jj),~]                      = relativistic_range_error_correction(estimStates.posRx(1:3)', satPos(jj,:),nav.E.eph);
                    else
                        [shapiroCorr(jj),~]                      = relativistic_range_error_correction(estimStates.posRx(1:3)', satPos(jj,:),nav.G.eph);
                    end
                    
                case 'GER'
                    if jj > nbObsSvConst(1) && jj <= ( nbObsSvConst(1) + nbObsSvConst(2) )
                        [shapiroCorr(jj),~]                      = relativistic_range_error_correction(estimStates.posRx(1:3)', satPos(jj,:),nav.E.eph);
                    elseif jj > ( nbObsSvConst(1) + nbObsSvConst(2) )
                        [shapiroCorr(jj),~]                      = relativistic_range_error_correction(estimStates.posRx(1:3)', satPos(jj,:),nav.R.eph);
                    else
                        [shapiroCorr(jj),~]                      = relativistic_range_error_correction(estimStates.posRx(1:3)', satPos(jj,:),nav.G.eph);
                    end
            end
        case 1 % Precise products
            
            %% Multi-Constellation considerations for the Satellite Antenna Phase Center correction
            switch conf.constellation
                case 'G'
                    satid = ['G' num2str(outObsModel.obsSv(jj),'%02.f')]; % satellite id for precise files
                case 'E'
                    satid = ['E' num2str(outObsModel.obsSv(jj),'%02.f')]; % satellite id for precise files
                case 'GE'
                    if jj > nbObsSvConst(1)
                        satid = ['E' num2str(outObsModel.obsSv(jj),'%02.f')]; % satellite id for precise files
                    else
                        satid = ['G' num2str(outObsModel.obsSv(jj),'%02.f')]; % satellite id for precise files
                    end
                case 'GR'
                    if jj > nbObsSvConst(1)
                        satid = ['R' num2str(outObsModel.obsSv(jj),'%02.f')]; % satellite id for precise files
                    else
                        satid = ['G' num2str(outObsModel.obsSv(jj),'%02.f')]; % satellite id for precise files
                    end
                case 'GER'
                    if jj <= nbObsSvConst(1)
                        satid = ['G' num2str(outObsModel.obsSv(jj),'%02.f')]; % satellite id for precise files
                    elseif jj > nbObsSvConst(1) && jj <= (nbObsSvConst(1) + nbObsSvConst(2))
                        satid = ['E' num2str(outObsModel.obsSv(jj),'%02.f')]; % satellite id for precise files
                    else
                        satid = ['R' num2str(outObsModel.obsSv(jj),'%02.f')]; % satellite id for precise files
                    end
            end

            [shapiroCorr(jj),~] = Shapiro_delay(estimStates.posRx(1:3)', satPos(jj,:),satid);

            
            % Satellite Antenna Phase Center
            
            k = - normrp(satPos(jj,:)); % unitary vector pointing to the center of Earth
            r = estimStates.posRx(1:3) - satPos(jj,:);
            
            % j is the resulting unit vector of the cross-product of the k with
            % the unit vector from the satellite to the Sun.
            
            e = normrp(rsun - satPos(jj,:));
            J = cross(k,e);
            
            % i completes the right-handed system
            i = cross(J,k);
            
            R = [i; J; k]';
            % Satellite coordinates referred to APC
            if ~isempty(nav.ATX) && isfield(nav.ATX,satid)
                APC             = nav.ATX.(satid).L1.APC; % in meters
                
                satCoordGPSAPC  = (satPos(jj,:)' + R*APC)';
                APCangle        = satCoordGPSAPC - satPos(jj,:);

                
                satPos(jj,:)    = satCoordGPSAPC; % Translate coordinates from CoM to CoP.
                % Angle between Satellite coordinates in CoM and CoP (cosine)
                cos_alpha       = diag(APCangle*r')./(norm_custom(APCangle).*norm_custom(r));
                
                antennaPhaseCentercorr(jj) = norm_custom(APCangle) .* cos_alpha;


               
            end
            
            
    end
    
    %% Geometric distance between the approx Rx and observed satellite
    dist_0(jj)                               = norm((satPos(jj,:)-estimStates.posRx(1:3)));
    
    %% Compute the observation vector
    switch conf.posAlgorithm
        
        % WLS
        case 0
            % Compute the observation vector
            outObsModel.y(jj)                        = outObsModel.measurement(jj) - dist_0(jj) + C*dtSat(jj) - shapiroCorr(jj) - ionoCorr(jj) - tropoCorr(jj);
            
            if conf.usePrRate
                outObsModel.y(outObsModel.nbSV + jj) = outObsModel.measurement(outObsModel.nbSV + jj) - dot(satVel(jj,:) - estimStates.velRx(1:3), (satPos(jj,:) - estimStates.posRx(1:3))./ dist_0(jj));
            end
            
            % EKF
        case 1
            % Compute the predicted measurement in scalar form (without the contribution of the receiver clock bias)
            inputKfPredMeasVect.predMeasScalar = dist_0(jj) - C*dtSat(jj) + shapiroCorr(jj) + ionoCorr(jj) + tropoCorr(jj) + ...
                antennaPhaseCentercorr(jj) + SolidTideCorr(jj);

            %Compute the predicted outObsModel.measurements vector
            predMeasScript
            
        otherwise
            error('Invalid configuration for conf.posAlgorithm! Choose 0 for WLS or 1 for EKF!')
            
    end
    %% Form the geometry matrix (G)
    
    outObsModel.G(jj,nav.idxX)                                              = (estimStates.posRx(1)-satPos(jj,1))/dist_0(jj);
    outObsModel.G(jj,nav.idxY)                                              = (estimStates.posRx(2)-satPos(jj,2))/dist_0(jj);
    outObsModel.G(jj,nav.idxZ)                                              = (estimStates.posRx(3)-satPos(jj,3))/dist_0(jj);
    outObsModel.G(jj,nav.idxClkBias)                                        =  1;
    
    if conf.usePrRate
        % d(prangeRate)/d(velocity)
        outObsModel.G(jj + outObsModel.nbSV,nav.idxVx)                      = outObsModel.G(jj,nav.idxX);
        outObsModel.G(jj + outObsModel.nbSV,nav.idxVy)                      = outObsModel.G(jj,nav.idxY);
        outObsModel.G(jj + outObsModel.nbSV,nav.idxVz)                      = outObsModel.G(jj,nav.idxZ);
        outObsModel.G(jj + outObsModel.nbSV,nav.idxClkDrift)                = 1;
        % d(prangeRate)/d(position)
        outObsModel.G(jj + outObsModel.nbSV,nav.idxX)                       = (estimStates.velRx(1)-satVel(jj,1))/dist_0(jj);
        outObsModel.G(jj + outObsModel.nbSV,nav.idxY)                       = (estimStates.velRx(2)-satVel(jj,2))/dist_0(jj);
        outObsModel.G(jj + outObsModel.nbSV,nav.idxZ)                       = (estimStates.velRx(3)-satVel(jj,3))/dist_0(jj);
        outObsModel.G(jj + outObsModel.nbSV,nav.idxClkBias)                 = 0;
        
    end
    
    %% Multi-Constellation considerations for the generation of the geometry matrix
    switch conf.constellation
        
        case {'G','E'}
            
        otherwise
            
            % If GPS+Galileo or GPS+GLONASS is chosen add a new column  in
            % the observation matrix that correspond to the System Time Offset
            if (( strcmp(conf.constellation, 'GE') || strcmp(conf.constellation, 'GR') || nbObsSvConst(2)==0 ) && conf.timeOffset == 1)
                
                if jj >= nbObsSvConst(1)
                    
                    outObsModel.G(jj,nav.numStates)                = 1;
                    
                end
                
                % If GPS+Galileo+GLONASS is chosen then add 2 new columns correspoding to the both System Time Offsets
            elseif (strcmp(conf.constellation, 'GER') && conf.timeOffset == 1)
                
                % Add 1's in the columns of the observation matrix that correspond
                % ot the Galileo To GPS Time Offset
                if (jj > nbObsSvConst(1) && countGalileo < nbObsSvConst(2))
                    
                    % 9th column
                    outObsModel.G(jj,nav.numStates-1)              = 1;
                    countGalileo                                   = countGalileo + 1;
                    
                end
                
                % Add 1's in the columns of the observation matrix that correspond
                % ot the GLONASS To GPS Time Offset
                if jj > (nbObsSvConst(1) + nbObsSvConst(2))
                    
                    % 10th column
                    outObsModel.G(jj,nav.numStates)                = 1;

                end
                
               
            end
    end
    
    %% Form the variance-covariance matrix of the measurement noise (R)
    switch(conf.weightingMethod)
        case 0
            % Fixed weighting method [Subirana, Jaime Sanz, et al. GNSS Data Processing: Fundamentals and Algorithms]
            outObsModel.R(jj,jj)= (conf.sigmaPR)^2;
        case 1
            % Sinusoidal weighting method [Rahemi, N., et al. "Accurate solution of navigation equations in GPS receivers for very high velocities using pseudorange measurements."]
            outObsModel.R(jj,jj) = 1/sin(outObsModel.eL(jj) * pi/180)^2;
        case 2
            % Tangential weighting method [Rahemi, N., et al. "Accurate solution of navigation equations in GPS receivers for very high velocities using pseudorange measurements."]
            outObsModel.R(jj,jj) = 1/tan(outObsModel.eL(jj) * pi/180-0.1)^2;
        case 3
            % Elevation-dependent weighting method [Subirana, Jaime Sanz, et al. GNSS Data Processing: Fundamentals and Algorithms]
            outObsModel.R(jj,jj) = (0.13+0.53*exp(-(outObsModel.eL(jj)*pi/180)/10))^2;
        case 4
            % C/N0 weighting method - Sigma e [Wieser, Andreas, et al. "An extended weight model for GPS phase observations"]

            outObsModel.R(jj,jj) = 1*0.244*10^(-0.1*CN0(jj)); 
%            for Haarlem
%                   outObsModel.R(jj,jj) = 0.000001 + 0.15*10^(-0.1*CN0(jj));

        case 5
            % C/N0+sinusoidal weighting method [Tay, Sarab, et al. "Weighting models for GPS Pseudorange observations for land transportation in urban canyons"]
            outObsModel.R(jj,jj) = 1*(10^(-0.1*CN0(jj)))/sin(outObsModel.eL(jj) * pi/180)^2;
        case 6
            % C/N0+tangential weighting method [Inspired by Satab Tay, et al. paper]
            outObsModel.R(jj,jj) = 1*(10^(-0.1*CN0(jj)))/tan(outObsModel.eL(jj) * pi/180-0.1)^2;
        case 7
            % C/N0+sinusoidal weighting method [Tay, Sarab, et al. "Weighting models for GPS Pseudorange observations for land transportation in urban canyons"]
            q_R     = 1*(10^(-0.1*CN0(jj)))/sin(outObsModel.eL(jj) * pi/180)^2;
            
            % 3ord Difference weighting

            q_3ord                  = 1 + abs(thirdOrddiff(jj));

            q_total                 = q_R * q_3ord;
            outObsModel.R(jj,jj)    = q_total;
        otherwise
            error('The selected weighting method is not available')
    end
    
    % Save weight per SV
    if jj <= nbObsSvConst(1)                                         % GPS
        store.G.weight(outObsModel.obsSv(jj),ii)	= outObsModel.R(jj,jj);
    elseif (jj > nbObsSvConst(1) && countGalileoR < nbObsSvConst(2)) % Galileo
        store.E.weight(outObsModel.obsSv(jj),ii)	= outObsModel.R(jj,jj);
        countGalileoR   = countGalileoR + 1;
    elseif jj > (nbObsSvConst(1) + nbObsSvConst(2))                 % GLONASS
        store.R.weight(outObsModel.obsSv(jj),ii)	= outObsModel.R(jj,jj);
    end
    
    if ~isempty(findstr(conf.constellation,'G')) && ~isempty(findstr(conf.constellation,'E')) && ~isempty(findstr(conf.constellation,'R'))
        if(conf.weightGLO && jj > nbObsSvConst(1)+nbObsSvConst(2) && (nbObsSvConst(1)+nbObsSvConst(2)) > 7)
            % TODO: fix the factor that is multiplying R (depends on the estimator)
            outObsModel.R(jj,jj) = outObsModel.R(jj,jj)*(conf.sigmaPR^2);

%             outObsModel.R(jj,jj) = outObsModel.R(jj,jj)*(q_3ord);

        end
        outObsModel.R(jj,jj) = k*outObsModel.R(jj,jj);
    end
    
    % Camera Usage [WORK IN PROGRESS]
    if conf.cameraUsage == 1
%         if islosVector(jj) == 1 || islosVector(jj) == 0
        if islosVector(jj) == 1
            k   = 1;
        elseif islosVector(jj) == 0
            k   = 2;
        else
            k   = 1/islosVector(jj);
        end
        outObsModel.R(jj,jj) = k*outObsModel.R(jj,jj);          
    end
        
    if conf.usePrRate
        % TODO: find proper weights
        outObsModel.R(jj+outObsModel.nbSV,jj+outObsModel.nbSV) = conf.prRateVarPenalty * outObsModel.R(jj,jj);
    end
    
    
end

% Handles the case when for G+E OR G+E OR OR G+E+R  there are no
% visible Galileo, GLONASS satellites - only for WLS
switch  conf.posAlgorithm
    case 0
        if any(outObsModel.G(:,end))== 0
            outObsModel.G(:,end) = [];
            
        elseif any(outObsModel.G(:,end-1))== 0
            outObsModel.G(:,end-1) = [];
        end
end

% Remove observations associated with NLOS SVs
if conf.cameraUsage == 1
    outObsModel.R(indicesRejected,:)            = [];
    outObsModel.R(:,indicesRejected)            = [];
    outObsModel.G(indicesRejected,:)            = [];
    outObsModel.measurement(indicesRejected)    = [];
    outObsModel.predMeas(indicesRejected)       = [];
    outObsModel.obsSv(indicesRejected)          = [];
    outObsModel.nbSV                            = outObsModel.nbSV - length(find(indicesRejected));
    outObsModel.y(indicesRejected)              = [];
    outObsModel.eL(indicesRejected)             = [];
    nbObsSvConst                                = nbObsSvConst - nbObsSvConstRej;
end


end

