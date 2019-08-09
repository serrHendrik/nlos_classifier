function [ timescale ] = timescaleFromDatenum( dNum, sys )
%TIMESCALEFROMDATENUM Summary of this function goes here
%   Detailed explanation goes here

    if nargin < 2 || isempty(sys)
        sys = 'GPS';
    end
    validSys = {'GPS'};
    assert( any(ismember(validSys, sys)), ...
            'Timesystem %s not yet implemented. Choose from: %s', ...
            sys, sprintf('%s,', validSys{:}) );
    
    gpsInit = 723186; % 6th Jan 1980: datenum(1980,1,6);
    timescale = (dNum - gpsInit) * 86400; 
        
end

