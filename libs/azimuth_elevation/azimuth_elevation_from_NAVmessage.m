function [aZ,eL] = azimuth_elevation_from_NAVmessage(RINEXnav_filename,constellation_type,satID,pseudorange,timeRx)

C = 299792458;


Omegae_dot = 7.2921159e-5;             % angular velocity of the Earth rotation [rad/s]
[eph, iono, corrSysTime]                =   load_RINEX_nav(RINEXnav_filename,constellation_type, 0);


% First guess of time of transmission

timeTx  = timeRx - ( pseudorange / C ) ;

% Determine the corresponding column for the desired SV in the
% ephemeris matrix
icol    = find_eph(eph, satID, timeTx,[]);

% Correct for the Total Group Delay (TGD)
tgdcorrection = eph(28,icol);


% Compute the satellite clock correction
[dtSat]  = sat_clock_error_correction(timeTx, eph(:,icol));

dtSat    = dtSat - tgdcorrection;

% Correct the time of transmission
timeTx          = timeTx - dtSat;

% Compute again the satellite clock bias and the coordinates / velocities
[dtSat]  = sat_clock_error_correction(timeTx, eph(:,icol));
dtSat    = dtSat - tgdcorrection;

[satCoord, satVel] = satellite_orbits(timeTx, eph(:,icol), satID, []);

% Compute the satellite relativistic clock correction
dtSat_rel   = -2 * ( dot(satCoord, satVel) / (C^2) );


% Account for the relativistic effect on the satellite clock
% bias and the time of transmission
dtSat    = dtSat + dtSat_rel;
timeTx          = timeTx - dtSat_rel;

% Recompute the satellite coordinates / velocities with the new
% time of transmission
%     [satCoord, satVel] = satellite_orbits(timeTx, Eph(:,icol), satID, []);


% Compute the travel time
travelTime      = timeRx - timeTx;

% Correct for the Sagnac effect (rotation correction)
satCoord = earth_rotation_correction(travelTime, satCoord, Omegae_dot)';

[aZ, eL]        = topocent_v6(posRx, satCoord);
end

