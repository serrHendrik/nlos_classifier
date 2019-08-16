function [cds, varargout] = parseUbxFile(fileName, options)
%PARSEUBXFILE Parses ubx binary file
%   CDS = PARSEUBXFILE(FILENAME) parses FILENAME and converts it to CDS.
%
%   CDS = PARSEUBXFILE(FILENAME, OPTIONS) parses FILENAME and converts it 
%   to CDS with OPTIONS, where OPTIONS is a STRUCT.
%
%   [CDS, MSG] = PARSEUBXFILE(...) when called with two output arguments, 
%   MSG is a cell array of parsed messages.
%
%   OPTIONS is currently reserved for future expansion.
%
%  See also PARSE.

% Written by Marco Bartolucci <Marco.Bartolucci@esa.int>
% Based on the work by Till Schmitt <till.schmitt@airbus.com>

narginchk(1,2);

%% Read File
fid = fopen(fileName , 'r');
assert(fid > 0, 'Could not open file %s.', fileName);

% TODO: handle huge files
buffer = fread(fid, 'uint8=>uint8'); 
fclose(fid);

if nargin == 2
    if nargout == 2
        [cds, varargout{1}] = parse(buffer, options);
    else
        cds = parse(buffer, options);
    end
elseif nargin == 1
    if nargout == 2
        [cds, varargout{1}] = parse(buffer);
    else
        cds = parse(buffer);
    end
end

end

