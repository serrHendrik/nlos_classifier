%% Load all Needed constants and look up tables
C = 299792458;

%% Freq band identified by rinex303 SV-Constellation identifier (GERC) and obs band identifier
% GPS
BANDS.G1.f = 1575.42e6;   % L1
BANDS.G1.type.C = 'L1CA';
BANDS.G1.type.S = 'L1CM';
BANDS.G1.type.L = 'L1CL';
BANDS.G1.type.X = 'L1CML';
BANDS.G1.type.P = 'L1P';
BANDS.G1.type.W = 'L1Z';
BANDS.G1.type.Y = 'L1Y';
BANDS.G1.type.M = 'L1M';
BANDS.G1.type.N = 'L1cl';
BANDS.G2.f = 1227.60e6;   % L2
BANDS.G2.type.C = 'L2CA';
BANDS.G2.type.D = 'L2P2P1';
BANDS.G2.type.S = 'L2CM';
BANDS.G2.type.L = 'L2CL';
BANDS.G2.type.X = 'L2CML';
BANDS.G2.type.P = 'L2P';
BANDS.G2.type.W = 'L2Z';
BANDS.G2.type.Y = 'L2Y';
BANDS.G2.type.M = 'L2M';
BANDS.G2.type.N = 'L2cl';
BANDS.G5.f = 1176.45e6;   % L5
BANDS.G5.type.I = 'L5I';
BANDS.G5.type.Q = 'L5Q';
BANDS.G5.type.X = 'L5IQ';

% GLONASS
BANDS.R1.f = 1602.00e6;   % G1
BANDS.R1.types.C = 'G1CA';
BANDS.R1.types.P = 'G1P';
BANDS.R2.f = 1246.00e6;   % G2
BANDS.R2.types.C = 'G2CA';
BANDS.R2.types.C = 'G2P';

% GAL
BANDS.E1.f = 1575.42e6;   % E1
BANDS.E1.types.A = 'E1A';
BANDS.E1.types.B = 'E1B';
BANDS.E1.types.C = 'E1C';
BANDS.E1.types.X = 'E1BC';
BANDS.E1.types.Z = 'E1ABC';
BANDS.E5.f = 1176.45e6;   % E5a
BANDS.E5.types.I = 'E5aI';
BANDS.E5.types.Q = 'E5aQ';
BANDS.E5.types.X = 'E5aIQ';
BANDS.E7.f = 1207.14e6;   % E5b
BANDS.E7.types.I = 'E5bI';
BANDS.E7.types.Q = 'E5bQ';
BANDS.E7.types.X = 'E5bIQ';
BANDS.E8.f = 1191.795e6;  % E5 (a+b)
BANDS.E8.types.I = 'E5I';
BANDS.E8.types.Q = 'E5Q';
BANDS.E8.types.X = 'E5IQ';
BANDS.E6.f = 1278.75e6;   % E6
BANDS.E6.types.A = 'E6A';
BANDS.E6.types.B = 'E6B';
BANDS.E6.types.C = 'E6C';
BANDS.E6.types.X = 'E6BC';
BANDS.E6.types.Z = 'E6ABC';
% COMPASS
BANDS.C1.f = 1589.74e6;   % B1
BANDS.C2.f = 1561.098e6;  % B2
BANDS.C2.types.I = 'B2I';
BANDS.C2.types.Q = 'B2Q';
BANDS.C2.types.X = 'B2IQ';
BANDS.C7.f = 1207.14e6;   % B5b
BANDS.C7.types.I = 'B5bI';
BANDS.C7.types.Q = 'B5bQ';
BANDS.C7.types.X = 'B5bIQ';
BANDS.C6.f = 1268.52e6;   % B6
BANDS.C6.types.I = 'B6I';
BANDS.C6.types.Q = 'B6Q';
BANDS.C6.types.X = 'B6IQ';
