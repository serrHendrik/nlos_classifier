function [size] = sizeof(ubxType)
%SIZEOF  Returns the size of a UBX datatype in bytes
%   SIZE = SIZEOF(UBXTYPE) Returns the size of UBXTYPE in bytes
%   
%   where UBXTYPE is a UBX datatype function
%
%  See also PARSE, PARSEUBXFILE.

% Written by Marco Bartolucci <Marco.Bartolucci@esa.int>
% Based on the work by Till Schmitt <till.schmitt@airbus.com>

narginchk(1,1);

assert(isa(ubxType, 'function_handle'), 'This is not a valid UBX datatype.');

[size, ~] = ubxType(zeros(1,8));
size = double(size);
end