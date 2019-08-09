function [M] = typeConv(ubxType, buffer, offset)
%TYPECONV  Converts UBX types to MATLAB types
%   M = TYPECONV(UBXTYPE, BUFFER, OFFSET=0) converts the data at
%   BUFFER+OFFSET to MATLAB types, where:
%
%   UBXTYPE is a UBX datatype
%   BUFFER is a byte array
%   OFFSET is the offset from the start of BUFFER in bytes
%
%  See also PARSE, PARSEUBXFILE, .

% Written by Marco Bartolucci <Marco.Bartolucci@esa.int>
% Based on the work by Till Schmitt <till.schmitt@airbus.com>

narginchk(2,3);

if nargin == 2
    offset = 0;
end

assert(isa(ubxType, 'function_handle'), 'This is not a valid UBX datatype.');

typeSize=sizeof(ubxType);
assert(length(buffer) >= offset + typeSize, 'Input buffer too short.');

[~,M] = ubxType(buffer(1+offset:1+typeSize+offset-1));
M = double(M);
end