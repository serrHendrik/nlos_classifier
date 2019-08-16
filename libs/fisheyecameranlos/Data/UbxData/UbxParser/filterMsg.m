function [o] = filterMsg(cells, classId, msgId)
%FILTERMSG  Filters parsed UBX messages
%   O = FILTERMSG(CELLS, CLASSID, MSGID) Filters parsed UBX messages
%   contained in the cell array CELLS. Returns a STRUCT array of messages
%   with classId CLASSID and msgId MSGID.
%   
%   CELLS is a cell array of parsed UBX messages
%
%  See also PARSE, PARSEUBXFILE.

% Written by Marco Bartolucci <Marco.Bartolucci@esa.int>
% Based on the work by Till Schmitt <till.schmitt@airbus.com>

filterFunc = @(x) strcmp(x.classId, classId) && strcmp(x.msgId, msgId);

o = cell2mat(cells(cellfun(filterFunc, cells)));

end