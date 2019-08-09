%% UBX types
% each type converter is defined as a function with 2 outputs:
% - The first output is the type size in bytes
% - The second output is the converted value

% Written by Marco Bartolucci <Marco.Bartolucci@esa.int>
% Based on the work by Till Schmitt <till.schmitt@airbus.com>

U1 = @(byte) deal(1, uint8(byte));
I1 = @(byte) deal(1, typecast(uint8(byte), 'int8'));
U2 = @(byte) deal(2, typecast(uint8(byte), 'uint16'));
I2 = @(byte) deal(2, typecast(uint8(byte), 'int16'));
U4 = @(byte) deal(4, typecast(uint8(byte), 'uint32'));
I4 = @(byte) deal(4, typecast(uint8(byte), 'int32'));
R4 = @(byte) deal(4, typecast(uint8(byte), 'single'));
R8 = @(byte) deal(8, typecast(uint8(byte), 'double'));
X1 = U1;
X4 = U4;