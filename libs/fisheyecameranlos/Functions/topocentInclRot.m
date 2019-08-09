function [Az, El] = topocentInclRot(XR, XS, RM)

% SYNTAX:
%   [Az, El, D] = topocent(XR, XS);
%
% INPUT:
%   XR = receiver coordinates (X,Y,Z)
%   XS = satellite coordinates (X,Y,Z)
%
% OUTPUT:
%   D = rover-satellite distance
%   Az = satellite azimuth
%   El = satellite elevation
%
% DESCRIPTION:
%   Computation of satellite distance, azimuth and elevation with respect to
%   the receiver.

%--- * --. --- --. .--. ... * ---------------------------------------------
%               ___ ___ ___
%     __ _ ___ / __| _ | __
%    / _` / _ \ (_ |  _|__ \
%    \__, \___/\___|_| |___/
%    |___/                    v 0.5.2 beta 1
%
%--------------------------------------------------------------------------
%  Copyright (C) Kai Borre
%  Written by:       Kai Borre
%  Contributors:     Kai Borre 09-26-97
%                    Mirko Reguzzoni, Eugenio Realini, 2009
%  A list of all the historical goGPS contributors is in CREDITS.nfo
%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
% 01100111 01101111 01000111 01010000 01010011
%--------------------------------------------------------------------------

%conversion from geocentric cartesian to geodetic coordinates
[phi, lam] = cart2geod(XR(1), XR(2), XR(3));

%new origin of the reference system
X0(:,1) = XR(1) * ones(size(XS,1),1);
X0(:,2) = XR(2) * ones(size(XS,1),1);
X0(:,3) = XR(3) * ones(size(XS,1),1);

%computation of topocentric coordinates
cl = cos(lam); sl = sin(lam);
cb = cos(phi); sb = sin(phi);
F = [-sl -sb*cl cb*cl;
      cl -sb*sl cb*sl;
       0    cb   sb];
local_vector = F' * (XS-X0)';

% Rotate Satellite Position w.r.t. camera frame
rotVec  = RM*local_vector;

E_rot   = rotVec(1);
N_rot   = rotVec(2);
U_rot   = rotVec(3);

hor_dis = sqrt(E_rot^2 + N_rot^2);

if hor_dis < 1.e-20
   %azimuth computation
   Az = 0;
   %elevation computation
   El = 90;
else
   %azimuth computation
   Az = atan2(E_rot,N_rot)/pi*180;
   %elevation computation
   El = atan2(U_rot,hor_dis)/pi*180;
end

i = find(Az < 0);
Az(i) = Az(i)+360;

end