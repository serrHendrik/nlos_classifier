function [msg] = parseRXM_RAWX(payload)
%PARSERXM_RAWX  Parses RXM_RAWX messages
%   MSG = PARSE(MSGID, PAYLOAD) parses RXM_RAWX message in PAYLOAD
%
%  See also PARSEUBXFILE.

% Written by Marco Bartolucci <Marco.Bartolucci@esa.int>
% Based on the work by Till Schmitt <till.schmitt@airbus.com>

%% load UBX types
ubxTypes

%% Parse message

msg = struct();

msg.rcvTow = typeConv(R8, payload, 0);
msg.week = typeConv(U2, payload, 8);
msg.leapS = typeConv(I1, payload, 10);
msg.numMeas = typeConv(U1, payload, 11);
msg.recStat_raw = typeConv(X1, payload, 12);
msg.recStat_leapSec = bitand(1, msg.recStat_raw);
msg.recStat_clkReset = bitand(1, bitshift(msg.recStat_raw, -1));
msg.version = typeConv(U1, payload, 13);

msg.prMes = nan(1, msg.numMeas);
msg.cpMes = nan(1, msg.numMeas);
msg.doMes = nan(1, msg.numMeas);
msg.gnssId = nan(1, msg.numMeas);
msg.svId = nan(1, msg.numMeas);
msg.freqId = nan(1, msg.numMeas);
msg.locktime = nan(1, msg.numMeas);
msg.cno = nan(1, msg.numMeas);
msg.prStdev = nan(1, msg.numMeas);
msg.cpStdev = nan(1, msg.numMeas);
msg.doStdev = nan(1, msg.numMeas);
msg.trkStat_raw = nan(1, msg.numMeas);
msg.trkStat_prValid = nan(1, msg.numMeas);
msg.trkStat_cpValid = nan(1, msg.numMeas);
msg.trkStat_halfCyc = nan(1, msg.numMeas);
msg.trkStat_subHalfCyc = nan(1, msg.numMeas);

for ii = 1:msg.numMeas
    msg.prMes(ii) = typeConv(R8, payload, 16 + 32 * (ii-1));
    msg.cpMes(ii) = typeConv(R8, payload, 24 + 32 * (ii-1));
    msg.doMes(ii) = typeConv(R4, payload, 32 + 32 * (ii-1));
    msg.gnssId(ii) = typeConv(U1, payload, 36 + 32 * (ii-1));
    msg.svId(ii) = typeConv(U1, payload, 37 + 32 * (ii-1));
    msg.freqId(ii) = typeConv(U1, payload, 39 + 32 * (ii-1));
    msg.locktime(ii) = typeConv(U2, payload, 40 + 32 * (ii-1));
    msg.cno(ii) = typeConv(U1, payload, 42 + 32 * (ii-1));
    msg.prStdev(ii) = 0.01 * 2 ^ bitand(bin2dec('1111'), typeConv(X1, payload, 43 + 32 * (ii-1)));
    
    cpStdev = bitand(bin2dec('1111'), typeConv(X1, payload, 44 + 32 * (ii-1)));
    if cpStdev == hex2dec('0f') % the value is invalid
        msg.cpStdev(ii) = -1;
    else
        msg.cpStdev(ii) = 0.004 * cpStdev;
    end
    
    msg.doStdev(ii) = 0.002 * 2 ^ bitand(bin2dec('1111'), typeConv(X1, payload, 45 + 32 * (ii-1)));
    
    msg.trkStat_raw(ii) = typeConv(X1, payload, 46 + 32 * (ii-1));
    msg.trkStat_prValid(ii) = bitand(1, msg.trkStat_raw(ii));
    msg.trkStat_cpValid(ii) = bitand(1, bitshift(msg.trkStat_raw(ii), -1));
    msg.trkStat_halfCyc(ii) = bitand(1, bitshift(msg.trkStat_raw(ii), -2));
    msg.trkStat_subHalfCyc(ii) = bitand(1, bitshift(msg.trkStat_raw(ii), -3));
    
end

end

