function [ tow, wnc ] = timescaleToTowWnc( timescale )
%TIMESCALETOTOWWNC GPS seconds since 1980-06-01 to tow wnc (GPS)
%   Detailed explanation goes here
    weekSeconds = 7*24*60*60;
    wnc = floor(timescale / weekSeconds ) ;
    tow = timescale - (wnc * weekSeconds);
end

