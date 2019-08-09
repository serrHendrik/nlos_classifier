function [aZeLStructure] = aZeLfromNav(conf,nav,refPosVel)
%Function that computes both azimuth and elevation for a number of selected
%epochs (specified in selEpochs)
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
% Date: 23.01.2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Change History
%
% - V0.1: Prototyping
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Print status update
fprintf('Computing Azimuth/Elevation ... ')

% Physical Constants
C           = 299792458;        % Speed of light [m/s]
omegaE      = 7.2921159e-5;     % Rotation of the Earth [rad/s]

% Index location
iRoll       = 1;                % Column for roll in orientation matrix
iPitch      = 2;                % Column for pitch in orientation matrix
iHeading    = 3;                % Column for heading in orientation matrix

% Input Variables
timeScale   = nav.timeScale;    % GPS time [s] of epochs to be processed

%% Create structure for storage of results

% Create Storage for GPS if selected
if(~isempty(strfind(conf.constellation,'G')))
    
    allSvGps                = nav.G.allSv;                              % Vector containing all GPS SVs 
    
    % Regular Azimuth and elevation (wrt to ENU reference frame)
    aZeLStructure.G.Az      = NaN(length(allSvGps),length(timeScale));  % Storage matrix for azimuth [deg]
    aZeLStructure.G.El      = NaN(length(allSvGps),length(timeScale));  % Storage matrix for elevation [deg]
    
    % Azimuth and Elevation corrected for camera orientation
    aZeLStructure.G.AzCm 	= NaN(length(allSvGps),length(timeScale));  % Storage matrix for azimuth [deg]
    aZeLStructure.G.ElCm    = NaN(length(allSvGps),length(timeScale));  % Storage matrix for elevation [deg]
    
    % Add timescale to struct
    aZeLStructure.G.time    = timeScale;                                % Timescale (GPS Time) [s]
    aZeLStructure.G.allSv   = allSvGps;                                 % Vector containing all GPS SVs 
    
end

%% Create Storage for GLONASS if selected
if(~isempty(strfind(conf.constellation,'R')))
    
    allSvGlo                = nav.R.allSv;                              % Vector containing all GLONASS SVs 
    
    % Regular Azimuth and elevation (wrt to ENU reference frame)
    aZeLStructure.R.Az      = NaN(length(allSvGlo),length(timeScale));  % Storage matrix for azimuth [deg]
    aZeLStructure.R.El      = NaN(length(allSvGlo),length(timeScale));  % Storage matrix for elevation [deg]
    
    % Azimuth and Elevation corrected for camera orientation
    aZeLStructure.R.AzCm 	= NaN(length(allSvGlo),length(timeScale));  % Storage matrix for azimuth [deg]
    aZeLStructure.R.ElCm    = NaN(length(allSvGlo),length(timeScale));  % Storage matrix for elevation [deg]
    
    % Add timescale to struct
    aZeLStructure.R.time    = timeScale;                                % Timescale (GPS Time) [s]
    aZeLStructure.R.allSv   = allSvGlo;                                 % Vector containing all GLONASS SVs 
    
end

%% Create Storage for Galileo if selected
if(~isempty(strfind(conf.constellation,'E')))
    
    allSvGal                = nav.E.allSv;                              % Vector containing all Galileo SVs 
    
    % Regular Azimuth and elevation (wrt to ENU reference frame)
    aZeLStructure.E.Az      = NaN(length(allSvGal),length(timeScale));  % Storage matrix for azimuth [deg]
    aZeLStructure.E.El      = NaN(length(allSvGal),length(timeScale));  % Storage matrix for elevation [deg]
    
    % Azimuth and Elevation corrected for camera orientation
    aZeLStructure.E.AzCm 	= NaN(length(allSvGal),length(timeScale));  % Storage matrix for azimuth [deg]
    aZeLStructure.E.ElCm    = NaN(length(allSvGal),length(timeScale));  % Storage matrix for elevation [deg]
    
    % Add timescale to struct
    aZeLStructure.E.time    = timeScale;                                % Timescale (GPS Time) [s]
    aZeLStructure.E.allSv   = allSvGal;                                 % Vector containing all Galileo SVs 
    
end

%% Loop over all epochs
for ii = 1:length(timeScale)
    
    % Variables for current Epoch for all Constellations
    timeRx  = timeScale(ii);    % Time of receiver
    
    % Process GPS SVs
    if(~isempty(strfind(conf.constellation,'G')))
        
        % Input for GPS SV Location Determination        
        matObsGps   = nav.G.matObs;                             % All code observations (if not detected -> NaN)
        ephGps      = nav.G.eph;                                % Ephemerides per SV
        obsSvGPS    = allSvGps(~isnan(matObsGps(:,ii)));        % Observed GPS SVs for current epoch
        prC1Cgps    = matObsGps(~isnan(matObsGps(:,ii)),ii);    % code based pseudoranges
        
        % Create vector to store azimuth/elevation 
        AzCr        = zeros(size(prC1Cgps));                    % Storage of azimuth
        ElCr        = zeros(size(prC1Cgps));                    % Storage of elevation
        Az          = zeros(size(prC1Cgps));                    % Storage of azimuth (corrected for camera orientation)
        El          = zeros(size(prC1Cgps));                    % Storage of elevation (corrected for camera orientation)
        
        % Process every satellite (i) -> indicates ith time this variable
        % is changed
        for jj = 1:length(obsSvGPS)
            
            % Initial guess parameters
            timeTx      = timeRx - ( prC1Cgps(jj) / C );                        % (1) First guess of time of transmission
            satID       = obsSvGPS(jj);                                         % Satellite PRN number
            icol        = find_eph(ephGps, satID, timeTx, []);                  % Column for desired SV in the ephemerides matrix
            dtSatGPS    = sat_clock_error_correction(timeTx, ephGps(:,icol));   % (1) Compute the satellite clock correction
            
            % Corrections
            tgd         = ephGps(28,icol);                                      % Total group daly [s] -> from ephemerides                            
            dtSatGPS    = dtSatGPS - tgd;                                       % (2) Correction satellite clock correction
            timeTx      = timeTx - dtSatGPS;                                    % Corrected time of transmission
            
            % Compute Satellite position
            [satPos, satVel]	= satellite_orbits(timeTx, ephGps(:,icol), satID, []);  % Compute Satellite Position and Velocity
            
            % Corrections
            dtSat_rel   = -2 * ( dot(satPos, satVel) / (C^2) );                         % Satellite relativistic clock correction
            timeTx      = timeTx - dtSat_rel;                                           % (2) Time of transmission
            travelTime  = timeRx - timeTx;                                              % Corrected traveltime [s]
            satPos      = earth_rotation_correction(travelTime, satPos, omegaE)';       % Position corrected for Sagnag effect (rotation correction)
            
            % Correct for orientation of the camera w.r.t. ENU frame
            
            % Euler angles
            phi         = refPosVel.refRot(ii,iHeading);                                % Heading/yaw angle [deg]
            theta       = refPosVel.refRot(ii,iPitch);                                  % Pitch angle [deg]
            psi         = refPosVel.refRot(ii,iRoll);                                   % Roll angle [deg]
            
            % Rotation matrix for roll-pitch-yaw rotation
            % Source: http://planning.cs.uiuc.edu/node102.html
            
            % Rotation around x/E axis -> Roll
            R_psi       = [1,           0,             0;
                           0,   cosd(psi),    -sind(psi);
                           0,   sind(psi),     cosd(psi)];
                       
            % Rotation around y/N axis -> Pitch
            R_theta     = [ cosd(theta),  0,  sind(theta);
                                      0,  1,            0;
                           -sind(theta),  0,  cosd(theta)];
                       
            % Rotation around z/U axis -> Yaw/Heading
            R_phi       = [ cosd(phi), -sind(phi), 0;
                            sind(phi),  cosd(phi), 0;
                                    0,          0, 1];

            % Full rotation matrix (yaw -> pitch -> roll)
            rotMatrix   = R_psi*R_theta*R_phi;
             
%             rotMatrixT   = [cosd(theta)*cosd(psi), sind(phi)*sind(theta)*cosd(psi) - cosd(phi)*sind(psi), cosd(phi)*sind(theta)*cosd(psi) + sind(phi)*sind(psi);
%                            cosd(theta)*sind(psi), sind(phi)*sind(theta)*sind(psi) + cosd(phi)*cosd(psi), cosd(phi)*sind(theta)*sind(psi) - sind(phi)*cosd(psi);
%                            -sind(theta)         , sind(phi)*cosd(theta)                                , cosd(phi)*cosd(theta)                               ];
            
            % Compute azimuth and elevation using adjusted function
            % (correction for rotation of camera frame)
            [AzCr(jj), ElCr(jj)]    = topocent_v6_InclRot(refPosVel.refPos(ii,:), satPos, rotMatrix);
            [Az(jj), El(jj)]        = topocent_v6(refPosVel.refPos(ii,:), satPos);
                   
        end
        
        % Store Final Results (without camera orientation correction)
        aZeLStructure.G.Az(~isnan(matObsGps(:,ii)),ii)      = Az;
        aZeLStructure.G.El(~isnan(matObsGps(:,ii)),ii)  	= El;
        
        % Store Final Results (corrected for camera orientation)
        aZeLStructure.G.AzCm(~isnan(matObsGps(:,ii)),ii)    = AzCr;
        aZeLStructure.G.ElCm(~isnan(matObsGps(:,ii)),ii)    = ElCr;
        
    end
    
    %% Process GLONASS SVs
    if(~isempty(strfind(conf.constellation,'R')))
        
        % Input for GLONASS SV Location Determination        
        matObsGlo   = nav.R.matObs;                             % All code observations (if not detected -> NaN)
        ephGlo      = nav.R.eph;                                % Ephemerides per SV
        obsSvGLO    = allSvGlo(~isnan(matObsGlo(:,ii)));        % Observed GLONASS SVs for current epoch
        prC1Cglo    = matObsGlo(~isnan(matObsGlo(:,ii)),ii);    % code based pseudoranges
        
        % Create vector to store azimuth/elevation 
        AzCr        = zeros(size(prC1Cglo));                    % Storage of azimuth
        ElCr        = zeros(size(prC1Cglo));                    % Storage of elevation
        Az          = zeros(size(prC1Cglo));                    % Storage of azimuth (corrected for camera orientation)
        El          = zeros(size(prC1Cglo));                    % Storage of elevation (corrected for camera orientation)
        
        % Process every satellite (i) -> indicates ith time this variable
        % is changed
        for jj = 1:length(obsSvGLO)
            
            % Initial guess parameters
            timeTx      = timeRx - ( prC1Cglo(jj) / C );                        % (1) First guess of time of transmission
            satID       = obsSvGLO(jj);                                         % Satellite PRN number
            icol        = find_eph(ephGlo, satID, timeTx, []);                  % Column for desired SV in the ephemerides matrix
            dtSatGLO    = sat_clock_error_correction(timeTx, ephGlo(:,icol));   % (1) Compute the satellite clock correction
            
            % Corrections
            tgd         = ephGlo(28,icol);                                      % Total group daly [s] -> from ephemerides                            
            dtSatGLO    = dtSatGLO - tgd;                                       % (2) Correction satellite clock correction
            timeTx      = timeTx - dtSatGLO;                                    % Corrected time of transmission
            
            % Compute Satellite position
            [satPos, satVel]	= satellite_orbits(timeTx, ephGlo(:,icol), satID, []);  % Compute Satellite Position and Velocity
            
            % Corrections
            dtSat_rel   = -2 * ( dot(satPos, satVel) / (C^2) );                         % Satellite relativistic clock correction
            timeTx      = timeTx - dtSat_rel;                                           % (2) Time of transmission
            travelTime  = timeRx - timeTx;                                              % Corrected traveltime [s]
            satPos      = earth_rotation_correction(travelTime, satPos, omegaE)';       % Position corrected for Sagnag effect (rotation correction)
            
            % Correct for orientation of the camera w.r.t. ENU frame
            
            % Euler angles
            phi         = refPosVel.refRot(ii,iHeading);                                % Heading/yaw angle [deg]
            theta       = refPosVel.refRot(ii,iPitch);                                  % Pitch angle [deg]
            psi         = refPosVel.refRot(ii,iRoll);                                   % Roll angle [deg]
            
            % Rotation matrix for roll-pitch-yaw rotation
            % Source: http://planning.cs.uiuc.edu/node102.html
            
            % Rotation around x/E axis -> Roll
            R_psi       = [1,           0,             0;
                           0,   cosd(psi),    -sind(psi);
                           0,   sind(psi),     cosd(psi)];
                       
            % Rotation around y/N axis -> Pitch
            R_theta     = [ cosd(theta),  0,  sind(theta);
                                      0,  1,            0;
                           -sind(theta),  0,  cosd(theta)];
                       
            % Rotation around z/U axis -> Yaw/Heading
            R_phi       = [ cosd(phi), -sind(phi), 0;
                            sind(phi),  cosd(phi), 0;
                                    0,          0, 1];

            % Full rotation matrix (yaw -> pitch -> roll)
            rotMatrix   = R_psi*R_theta*R_phi;
             
%             rotMatrixT   = [cosd(theta)*cosd(psi), sind(phi)*sind(theta)*cosd(psi) - cosd(phi)*sind(psi), cosd(phi)*sind(theta)*cosd(psi) + sind(phi)*sind(psi);
%                            cosd(theta)*sind(psi), sind(phi)*sind(theta)*sind(psi) + cosd(phi)*cosd(psi), cosd(phi)*sind(theta)*sind(psi) - sind(phi)*cosd(psi);
%                            -sind(theta)         , sind(phi)*cosd(theta)                                , cosd(phi)*cosd(theta)                               ];
            
            % Compute azimuth and elevation using adjusted function
            % (correction for rotation of camera frame)
            [AzCr(jj), ElCr(jj)]    = topocent_v6_InclRot(refPosVel.refPos(ii,:), satPos, rotMatrix);
            [Az(jj), El(jj)]        = topocent_v6(refPosVel.refPos(ii,:), satPos);
                   
        end
        
        % Store Final Results (without camera orientation correction)
        aZeLStructure.R.Az(~isnan(matObsGlo(:,ii)),ii)      = Az;
        aZeLStructure.R.El(~isnan(matObsGlo(:,ii)),ii)  	= El;
        
        % Store Final Results (corrected for camera orientation)
        aZeLStructure.R.AzCm(~isnan(matObsGlo(:,ii)),ii)    = AzCr;
        aZeLStructure.R.ElCm(~isnan(matObsGlo(:,ii)),ii)    = ElCr;
        
    end
    
    %% Process Galileo SVs
    if(~isempty(strfind(conf.constellation,'E')))
        
        % Input for Galileo SV Location Determination        
        matObsGal   = nav.E.matObs;                             % All code observations (if not detected -> NaN)
        ephGal      = nav.E.eph;                                % Ephemerides per SV
        obsSvGAL    = allSvGal(~isnan(matObsGal(:,ii)));        % Observed Galileo SVs for current epoch
        prC1Cgal    = matObsGal(~isnan(matObsGal(:,ii)),ii);    % code based pseudoranges
        
        % Create vector to store azimuth/elevation 
        AzCr        = zeros(size(prC1Cgal));                    % Storage of azimuth
        ElCr        = zeros(size(prC1Cgal));                    % Storage of elevation
        Az          = zeros(size(prC1Cgal));                    % Storage of azimuth (corrected for camera orientation)
        El          = zeros(size(prC1Cgal));                    % Storage of elevation (corrected for camera orientation)
        
        % Process every satellite (i) -> indicates ith time this variable
        % is changed
        for jj = 1:length(obsSvGAL)
            
            % Initial guess parameters
            timeTx      = timeRx - ( prC1Cgal(jj) / C );                        % (1) First guess of time of transmission
            satID       = obsSvGAL(jj);                                         % Satellite PRN number
            icol        = find_eph(ephGal, satID, timeTx, []);                  % Column for desired SV in the ephemerides matrix
            dtSatGAL    = sat_clock_error_correction(timeTx, ephGal(:,icol));   % (1) Compute the satellite clock correction
            
            % Corrections
            tgd         = ephGal(28,icol);                                      % Total group daly [s] -> from ephemerides                            
            dtSatGAL    = dtSatGAL - tgd;                                       % (2) Correction satellite clock correction
            timeTx      = timeTx - dtSatGAL;                                    % Corrected time of transmission
            
            % Compute Satellite position
            [satPos, satVel]	= satellite_orbits(timeTx, ephGal(:,icol), satID, []);  % Compute Satellite Position and Velocity
            
            % Corrections
            dtSat_rel   = -2 * ( dot(satPos, satVel) / (C^2) );                         % Satellite relativistic clock correction
            timeTx      = timeTx - dtSat_rel;                                           % (2) Time of transmission
            travelTime  = timeRx - timeTx;                                              % Corrected traveltime [s]
            satPos      = earth_rotation_correction(travelTime, satPos, omegaE)';       % Position corrected for Sagnag effect (rotation correction)
            
            % Correct for orientation of the camera w.r.t. ENU frame
            
            % Euler angles
            phi         = refPosVel.refRot(ii,iHeading);                                % Heading/yaw angle [deg]
            theta       = refPosVel.refRot(ii,iPitch);                                  % Pitch angle [deg]
            psi         = refPosVel.refRot(ii,iRoll);                                   % Roll angle [deg]
            
            % Rotation matrix for roll-pitch-yaw rotation
            % Source: http://planning.cs.uiuc.edu/node102.html
            
            % Rotation around x/E axis -> Roll
            R_psi       = [1,           0,             0;
                           0,   cosd(psi),    -sind(psi);
                           0,   sind(psi),     cosd(psi)];
                       
            % Rotation around y/N axis -> Pitch
            R_theta     = [ cosd(theta),  0,  sind(theta);
                                      0,  1,            0;
                           -sind(theta),  0,  cosd(theta)];
                       
            % Rotation around z/U axis -> Yaw/Heading
            R_phi       = [ cosd(phi), -sind(phi), 0;
                            sind(phi),  cosd(phi), 0;
                                    0,          0, 1];

            % Full rotation matrix (yaw -> pitch -> roll)
            rotMatrix   = R_psi*R_theta*R_phi;
             
%             rotMatrixT   = [cosd(theta)*cosd(psi), sind(phi)*sind(theta)*cosd(psi) - cosd(phi)*sind(psi), cosd(phi)*sind(theta)*cosd(psi) + sind(phi)*sind(psi);
%                            cosd(theta)*sind(psi), sind(phi)*sind(theta)*sind(psi) + cosd(phi)*cosd(psi), cosd(phi)*sind(theta)*sind(psi) - sind(phi)*cosd(psi);
%                            -sind(theta)         , sind(phi)*cosd(theta)                                , cosd(phi)*cosd(theta)                               ];
            
            % Compute azimuth and elevation using adjusted function
            % (correction for rotation of camera frame)
            [AzCr(jj), ElCr(jj)]    = topocent_v6_InclRot(refPosVel.refPos(ii,:), satPos, rotMatrix);
            [Az(jj), El(jj)]        = topocent_v6(refPosVel.refPos(ii,:), satPos);
                   
        end
        
        % Store Final Results (without camera orientation correction)
        aZeLStructure.E.Az(~isnan(matObsGal(:,ii)),ii)      = Az;
        aZeLStructure.E.El(~isnan(matObsGal(:,ii)),ii)  	= El;
        
        % Store Final Results (corrected for camera orientation)
        aZeLStructure.E.AzCm(~isnan(matObsGal(:,ii)),ii)    = AzCr;
        aZeLStructure.E.ElCm(~isnan(matObsGal(:,ii)),ii)    = ElCr;
        
    end
    
end

% Close status update
fprintf('done \n')


end

