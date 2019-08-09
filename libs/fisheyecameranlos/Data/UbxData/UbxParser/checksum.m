function [ok] = checksum(buffer)
%CHECKSUM  UBX frame checksum
%   OK = CHECKSUM(BUFFER) Returns true if BUFFER is a valid UBX frame;
%   false if BUFFER is not a valid UBX frame.
%   
%   BUFFER is an array of bytes. It must contain the bytes CK_A and CK_B
%
%  See also PARSE, PARSEUBXFILE.

% Written by Marco Bartolucci <Marco.Bartolucci@esa.int>
% Based on the work by Till Schmitt <till.schmitt@airbus.com>

    sum1 = uint32(0);
    sum2 = uint32(0);
    
    N = length(buffer) - 2;
    for i = 1:N
       sum1 = sum1 + uint32(buffer(i));
       sum2 = sum1 + sum2;
    end   
    
    CK_A = uint8( mod(sum1,256) );
    CK_B = uint8( mod(sum2,256) );
    
    ok = (CK_A - buffer(end-1) + CK_B - buffer(end)) == 0;
end