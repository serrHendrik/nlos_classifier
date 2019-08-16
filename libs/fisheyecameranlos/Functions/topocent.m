function [Az, El, D] = topocent(pos_aprox,dx)
%TOPOCENT  Transformation of vector dx into topocentric coordinate
%          system with origin at X.
%          Both parameters are 3 by 1 vectors.
%          Output: D    vector length in units like the input
%                  Az   azimuth from north positive clockwise, degrees
%                  El   elevation angle, degrees

%Kai Borre 11-24-96
%Copyright (c) by Kai Borre
%$Revision: 1.0 $  $Date: 1997/09/26  $

% Modified by Roger Estatuet in order to make it compatible with HybUAB (02/03/2017)
Az = [];
El = [];
D  = [];

for n = 1:(size(dx,1))
    
    dist = dx(n,:)' - pos_aprox;
    

dtr = pi/180;
[phi,lambda,h] = togeod(6378137,298.257223563,pos_aprox(1),pos_aprox(2),pos_aprox(3));
cl = cos(lambda*dtr); sl = sin(lambda*dtr);
cb = cos(phi*dtr); sb = sin(phi*dtr);
F = [-sl -sb*cl cb*cl;
      cl -sb*sl cb*sl;
       0    cb   sb];
local_vector = F'*dist;
E = local_vector(1);
N = local_vector(2);
U = local_vector(3);
hor_dis = sqrt(E^2+N^2);
if hor_dis < 1.e-20
   Az(n) = 0;
   El(n) = 90;
else
   Az(n) = atan2(E,N)/dtr;
   El(n) = atan2(U,hor_dis)/dtr;
end
if Az(n) < 0
   Az(n) = Az(n)+360;
end
D = sqrt(dist(1)^2+dist(2)^2+dist(3)^2);
%%%%%%%%% end topocent.m %%%%%%%%%

end

Az = Az';
El = El';
