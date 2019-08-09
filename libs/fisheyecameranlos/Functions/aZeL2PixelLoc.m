function [sampleLine] = aZeL2PixelLoc(conf,aZeLStructure,az_calib,el_calib,pbMap)
%aZeL2PixelLoc Converts an azimuth and elevation of a SV to the sample and
%line location in a video frame
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
% Date: 24.01.2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Change History
%
% - V0.1: Prototyping 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Retrieve sample and line pixels from calibration matrix
[noLine, ~] = size(az_calib);

% Print status update
fprintf('Searching pixels per satellite ... ')

%% Process GPS Satellites
if(~isempty(strfind(conf.constellation,'G')))
    
    fprintf('GPS ... ')
    
    % Retrieve Azimuth/Elevation from structure
    AzGPS   = aZeLStructure.G.AzCm; % Azimuth [deg]
    ElGPS   = aZeLStructure.G.ElCm; % Elevation [deg]
    
    % Create structure to store Sample/Line for GPS
    sampleLine.G.sample	= NaN(length(aZeLStructure.G.allSv),length(aZeLStructure.G.time));
    sampleLine.G.line   = NaN(length(aZeLStructure.G.allSv),length(aZeLStructure.G.time));
    sampleLine.G.islos  = NaN(length(aZeLStructure.G.allSv),length(aZeLStructure.G.time));
    
    % Loop over number of epochs
    for ii = 1:length(aZeLStructure.G.time)
    
        % Check which SVs are observed
        iObserved   = find(~isnan(AzGPS(:,ii)));
        
        % Create vector to store sample/line
        sample      = zeros(size(iObserved));
        line        = zeros(size(iObserved));
        islos       = zeros(size(iObserved));
        
        % Loop over number of SVs
        for jj = 1:length(iObserved)
            
            % Determine flipped Azimuth if required
            AzGPSFlipped = AzGPS(iObserved(jj),ii);
            if conf.camForwardDir == 0
                if AzGPSFlipped >= 0 && AzGPSFlipped < 180
                    AzGPSFlipped    = 180 - AzGPSFlipped;
                elseif AzGPSFlipped >= 180 && AzGPSFlipped < 360
                    AzGPSFlipped    = 540 - AzGPSFlipped;
                end           
            end
        
            % Determine indices with similar rounded elevation
            indElev     = find(round(el_calib) == round(ElGPS(iObserved(jj),ii)));
            indAzim     = find(round(az_calib) == round(AzGPSFlipped));
            
            % Find Sample and Line Coordinates
            AzElComm    = intersect(indAzim,indElev);                           % Common Azimuth and Elevation Indices
            azimError   = abs(az_calib(AzElComm) - AzGPSFlipped);               % Residual in azimuth between calib and SV Azimuth
            elevError   = abs(el_calib(AzElComm) - ElGPS(iObserved(jj),ii));    % Residual in elevation between calib and SV Azimuth
            [~,iiFinal] = min(sqrt(sum([azimError, elevError].^2,2)));          % Find index of calib matrix resulting in smallest error
            iFinal      = AzElComm(iiFinal);                                    % Matrix coordinate of camera for best fit
            
            % For high elevation there is not always an intersection with
            % azimuth
            if isempty(AzElComm) && ElGPS(iObserved(jj),ii) >= 80
                [~,iiFinal]	= min(abs(az_calib(indElev) - AzGPSFlipped));
                iFinal      = indElev(iiFinal);
                AzElComm    = iFinal;
            end
            
            % If no Common indices are found SV is not in view of the
            % camera
            if isempty(AzElComm)
                
                % Retrieve sample and line coordinates (NaN as not in field
                % of view of camera)
                sample(jj)  = NaN;  % Find sample coordinate of SV [pixel]
                line(jj)    = NaN;  % Find line coordinate of SV [pixel]         
            
            else
                
                % Retrieve sample and line coordinates
                if(mod(iFinal,noLine) == 0)
                    line(jj)    = noLine;                           % Find line coordinate of SV [pixel]
                    sample(jj)  = (iFinal - noLine)/noLine + 1;     % Find sample coordinate of SV [pixel]
                else
                    sample(jj)  = floor(iFinal/noLine) + 1;         % Find line coordinate of SV [pixel]
                    line(jj)    = iFinal - (sample(jj)-1)*noLine;   % Find sample coordinate of SV [pixel]
                end
                
                % Only retrieve probability if pbMap is available
                if conf.getProbMat == 0 || conf.getProbMat == 1
                    islos(jj)   = pbMap(line(jj),sample(jj),ii);    % Find probability of sky detection for current SV
                end
                    
            end
            
        end
        
        % Store Final Results
        sampleLine.G.sample(iObserved,ii)   = sample;
        sampleLine.G.line(iObserved,ii)     = line;
        
        % Store Probability of sky detection
        sampleLine.G.islos(iObserved,ii)    = islos;
        
    end
    
    fprintf(' done ... ')
    
end

%% Process GLONASS Satellites
if(~isempty(strfind(conf.constellation,'R')))
    
    fprintf('GLONASS ... ')
    
    % Retrieve Azimuth/Elevation from structure
    AzGLO   = aZeLStructure.R.AzCm; % Azimuth [deg]
    ElGLO   = aZeLStructure.R.ElCm; % Elevation [deg]
    
    % Create structure to store Sample/Line for GLONASS
    sampleLine.R.sample	= NaN(length(aZeLStructure.R.allSv),length(aZeLStructure.R.time));
    sampleLine.R.line   = NaN(length(aZeLStructure.R.allSv),length(aZeLStructure.R.time));
    sampleLine.R.islos  = NaN(length(aZeLStructure.R.allSv),length(aZeLStructure.R.time));
    
    % Loop over number of epochs
    for ii = 1:length(aZeLStructure.R.time)
    
        % Check which SVs are observed
        iObserved   = find(~isnan(AzGLO(:,ii)));
        
        % Create vector to store sample/line
        sample      = zeros(size(iObserved));
        line        = zeros(size(iObserved));
        islos       = zeros(size(iObserved));
        
        % Loop over number of SVs
        for jj = 1:length(iObserved)
            
            % Determine flipped Azimuth if required
            AzGLOFlipped = AzGLO(iObserved(jj),ii);
            if conf.camForwardDir == 0
                if AzGLOFlipped >= 0 && AzGLOFlipped < 180
                    AzGLOFlipped    = 180 - AzGLOFlipped;
                elseif AzGLOFlipped >= 180 && AzGLOFlipped < 360
                    AzGLOFlipped    = 540 - AzGLOFlipped;
                end            
            end
        
            % Determine indices with similar rounded elevation
            indElev     = find(round(el_calib) == round(ElGLO(iObserved(jj),ii)));
            indAzim     = find(round(az_calib) == round(AzGLOFlipped));
            
            % Find Sample and Line Coordinates
            AzElComm    = intersect(indAzim,indElev);                           % Common Azimuth and Elevation Indices
            azimError   = abs(az_calib(AzElComm) - AzGLOFlipped);               % Residual in azimuth between calib and SV Azimuth
            elevError   = abs(el_calib(AzElComm) - ElGLO(iObserved(jj),ii));    % Residual in elevation between calib and SV Azimuth
            [~,iiFinal] = min(sqrt(sum([azimError, elevError].^2,2)));          % Find index of calib matrix resulting in smallest error
            iFinal      = AzElComm(iiFinal);                                    % Matrix coordinate of camera for best fit
            
            % For high elevation there is not always an intersection with
            % azimuth
            if isempty(AzElComm) && ElGLO(iObserved(jj),ii) >= 80
                [~,iiFinal]	= min(abs(az_calib(indElev) - AzGLOFlipped));
                iFinal      = indElev(iiFinal);
                AzElComm    = iFinal;
            end
            
            % If no Common indices are found SV is not in view of the
            % camera
            if isempty(AzElComm)
                
                % Retrieve sample and line coordinates (NaN as not in field
                % of view of camera)
                sample(jj)  = NaN;  % Find sample coordinate of SV [pixel]
                line(jj)    = NaN;  % Find line coordinate of SV [pixel]         
            
            else
                
                % Retrieve sample and line coordinates
                if(mod(iFinal,noLine) == 0)
                    line(jj)    = noLine;                           % Find line coordinate of SV [pixel]
                    sample(jj)  = (iFinal - noLine)/noLine + 1;     % Find sample coordinate of SV [pixel]
                else
                    sample(jj)  = floor(iFinal/noLine) + 1;         % Find line coordinate of SV [pixel]
                    line(jj)    = iFinal - (sample(jj)-1)*noLine;   % Find sample coordinate of SV [pixel]
                end
                
                % Only retrieve probability if pbMap is available
                if conf.getProbMat == 0 || conf.getProbMat == 1
                    islos(jj)   = pbMap(line(jj),sample(jj),ii);    % Find probability of sky detection for current SV
                end
                    
            end
            
        end
        
        % Store Final Results
        sampleLine.R.sample(iObserved,ii)   = sample;
        sampleLine.R.line(iObserved,ii)     = line;
        
        % Store Probability of sky detection
        sampleLine.R.islos(iObserved,ii)    = islos;
        
    end
    
    fprintf('done ... ')
    
end

%% Process Galileo Satellites
if(~isempty(strfind(conf.constellation,'E')))
    
    fprintf('Galileo ... ')
    
    % Retrieve Azimuth/Elevation from structure
    AzGAL   = aZeLStructure.E.AzCm; % Azimuth [deg]
    ElGAL   = aZeLStructure.E.ElCm; % Elevation [deg]
    
    % Create structure to store Sample/Line for Galileo
    sampleLine.E.sample	= NaN(length(aZeLStructure.E.allSv),length(aZeLStructure.E.time));
    sampleLine.E.line   = NaN(length(aZeLStructure.E.allSv),length(aZeLStructure.E.time));
    sampleLine.E.islos  = NaN(length(aZeLStructure.E.allSv),length(aZeLStructure.E.time));
    
    % Loop over number of epochs
    for ii = 1:length(aZeLStructure.E.time)
    
        % Check which SVs are observed
        iObserved   = find(~isnan(AzGAL(:,ii)));
        
        % Create vector to store sample/line
        sample      = zeros(size(iObserved));
        line        = zeros(size(iObserved));
        islos       = zeros(size(iObserved));
        
        % Loop over number of SVs
        for jj = 1:length(iObserved)
            
            % Determine flipped Azimuth if required
            AzGALFlipped = AzGAL(iObserved(jj),ii);
            if conf.camForwardDir == 0
                if AzGALFlipped >= 0 && AzGALFlipped < 180
                    AzGALFlipped    = 180 - AzGALFlipped;
                elseif AzGALFlipped >= 180 && AzGALFlipped < 360
                    AzGALFlipped    = 540 - AzGALFlipped;
                end
            end
        
            % Determine indices with similar rounded elevation
            indElev     = find(round(el_calib) == round(ElGAL(iObserved(jj),ii)));
            indAzim     = find(round(az_calib) == round(AzGALFlipped));
            
            % Find Sample and Line Coordinates
            AzElComm    = intersect(indAzim,indElev);                           % Common Azimuth and Elevation Indices
            azimError   = abs(az_calib(AzElComm) - AzGALFlipped);               % Residual in azimuth between calib and SV Azimuth
            elevError   = abs(el_calib(AzElComm) - ElGAL(iObserved(jj),ii));    % Residual in elevation between calib and SV Azimuth
            [~,iiFinal] = min(sqrt(sum([azimError, elevError].^2,2)));          % Find index of calib matrix resulting in smallest error
            iFinal      = AzElComm(iiFinal);                                    % Matrix coordinate of camera for best fit
            
            % For high elevation there is not always an intersection with
            % azimuth
            if isempty(AzElComm) && ElGAL(iObserved(jj),ii) >= 80
                [~,iiFinal]	= min(abs(az_calib(indElev) - AzGALFlipped));
                iFinal      = indElev(iiFinal);
                AzElComm    = iFinal;
            end
            
            % If no Common indices are found SV is not in view of the
            % camera
            if isempty(AzElComm)
                
                % Retrieve sample and line coordinates (NaN as not in field
                % of view of camera)
                sample(jj)  = NaN;  % Find sample coordinate of SV [pixel]
                line(jj)    = NaN;  % Find line coordinate of SV [pixel]         
            
            else
                
                % Retrieve sample and line coordinates
                if(mod(iFinal,noLine) == 0)
                    line(jj)    = noLine;                           % Find line coordinate of SV [pixel]
                    sample(jj)  = (iFinal - noLine)/noLine + 1;     % Find sample coordinate of SV [pixel]
                else
                    sample(jj)  = floor(iFinal/noLine) + 1;         % Find line coordinate of SV [pixel]
                    line(jj)    = iFinal - (sample(jj)-1)*noLine;   % Find sample coordinate of SV [pixel]
                end
                
                % Only retrieve probability if pbMap is available
                if conf.getProbMat == 0 || conf.getProbMat == 1
                    islos(jj)   = pbMap(line(jj),sample(jj),ii);    % Find probability of sky detection for current SV
                end
                    
            end
            
        end
        
        % Store Final Results
        sampleLine.E.sample(iObserved,ii)   = sample;
        sampleLine.E.line(iObserved,ii)     = line;
        
        % Store Probability of sky detection
        sampleLine.E.islos(iObserved,ii)    = islos;
        
    end
    
    fprintf(' done ... ')
    
end

fprintf(' completed \n')

end

