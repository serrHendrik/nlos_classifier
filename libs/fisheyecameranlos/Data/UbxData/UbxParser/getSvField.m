function [o] = getSvField(msgs, fieldIn, fieldOut)
%GETSVFIELD  Gets specific field from filtered UBX messages
%   O = GETSVFIELD(MSGS, FIELDIN) Gets field FIELDIN from filtered UBX
%   messages in MSGS. Returns a struct array containing only FIELDIN. The
%   output data is associated with the proper satellite vehicle number.
%
%   O = GETSVFIELD(MSGS, FIELDIN, FIELDOUT) Gets field FIELDIN from
%   filtered UBX messages in MSGS. Returns a struct array containing only
%   FIELDIN. The field FIELDIN is renamed to FIELDOUT in the output struct. 
%   The output data is associated with the proper satellite vehicle number.   
%
%   MSGS is a struct array of filtered UBX messages (it must contain fields
%   svId and gnssId)
%
%  See also PARSE, PARSEUBXFILE.

% Written by Marco Bartolucci <Marco.Bartolucci@esa.int>
% Based on the work by Till Schmitt <till.schmitt@airbus.com>

narginchk(2, 3);

if nargin == 2
    fieldOut = fieldIn;
end

N = length(msgs);
o = struct();

for ii = 1:N
    gpsSatsI = find(msgs(ii).gnssId == 0);
    galSatsI = find(msgs(ii).gnssId == 2);
    gloSatsI = find(msgs(ii).gnssId == 6);
    
    o(ii).(['gps' fieldOut]) = nan(32, 1);
    o(ii).(['gal' fieldOut]) = nan(36, 1);
    o(ii).(['glo' fieldOut]) = nan(33, 1);
    
    o(ii).(['gps' fieldOut])(msgs(ii).svId(gpsSatsI)) = msgs(ii).(fieldIn)(gpsSatsI);
    o(ii).(['gal' fieldOut])(msgs(ii).svId(galSatsI)) = msgs(ii).(fieldIn)(galSatsI);
    o(ii).(['glo' fieldOut])(msgs(ii).svId(gloSatsI)) = msgs(ii).(fieldIn)(gloSatsI);
    
    % ignore R?
    o(ii).(['glo' fieldOut]) = o(ii).(['glo' fieldOut])(1:32);
    
end
end