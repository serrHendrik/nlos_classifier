function [msg] = parseNAV_SAT(payload)
%PARSENAV_SAT  Parses NAV_SAT messages 0x35
%   MSG = PARSENAV_SAT(PAYLOAD) parses NAV_SAT message in PAYLOAD
%
%  See also PARSEUBXFILE.

% Written by Marco Bartolucci <Marco.Bartolucci@esa.int>
% Based on the work by Till Schmitt <till.schmitt@airbus.com>

%% load UBX types
ubxTypes

%% Parse message

msg = struct();

msg.iTOW = typeConv(U4, payload, 0);
msg.version = typeConv(U1, payload, 4);
msg.numSvs = typeConv(U1, payload, 5);

assert(length(payload) == 8 + 12 * msg.numSvs, 'Invalid frame length.');

msg.gnssId = nan(1, msg.numSvs);
msg.svId = nan(1, msg.numSvs);
msg.cno = nan(1, msg.numSvs);
msg.elev = nan(1, msg.numSvs);
msg.azim = nan(1, msg.numSvs);
msg.prRes = nan(1, msg.numSvs);

msg.flags_raw = nan(1, msg.numSvs);
msg.flags_qualityInd = nan(1, msg.numSvs);
msg.flags_svUsed = nan(1, msg.numSvs);
msg.flags_health = nan(1, msg.numSvs);
msg.flags_diffCorr = nan(1, msg.numSvs);
msg.flags_smoothed = nan(1, msg.numSvs);
msg.flags_orbitSource = nan(1, msg.numSvs);
msg.flags_aphAvail = nan(1, msg.numSvs);
msg.flags_almAvail = nan(1, msg.numSvs);
msg.flags_anoAvail = nan(1, msg.numSvs);
msg.flags_aopAvail = nan(1, msg.numSvs);
msg.flags_sbasCorrUsed = nan(1, msg.numSvs);
msg.flags_rtcmCorrUsed = nan(1, msg.numSvs);
msg.flags_prCorrUsed = nan(1, msg.numSvs);
msg.flags_crCorrUsed = nan(1, msg.numSvs);
msg.flags_doCorrUsed = nan(1, msg.numSvs);

for ii = 1:msg.numSvs
    msg.gnssId(ii) = typeConv(U1, payload, 8 + 12 * (ii-1));
    msg.svId(ii) = typeConv(U1, payload, 9 + 12 * (ii-1));
    msg.cno(ii) = typeConv(U1, payload,  10 + 12 * (ii-1));
    msg.elev(ii) = typeConv(I1, payload, 11 + 12 * (ii-1));
    msg.azim(ii) = typeConv(I2, payload, 12 + 12 * (ii-1));
    msg.prRes(ii) = 0.1 * typeConv(I2, payload, 14 + 12 * (ii-1));
    msg.flags_raw(ii) = typeConv(X4, payload, 16 + 12 * (ii-1));
    
    msg.flags_qualityInd(ii) = bitand(bin2dec('111'), msg.flags_raw(ii));
    msg.flags_svUsed(ii) = bitand(1, bitshift(msg.flags_raw(ii), -3));
    msg.flags_health(ii) = bitand(bin2dec('11'), bitshift(msg.flags_raw(ii), -4));
    msg.flags_diffCorr(ii) = bitand(1, bitshift(msg.flags_raw(ii), -6));
    msg.flags_smoothed(ii) = bitand(1, bitshift(msg.flags_raw(ii), -7));
    msg.flags_orbitSource(ii) = bitand(bin2dec('111'), bitshift(msg.flags_raw(ii), -8));
    msg.flags_ephAvail(ii) = bitand(1, bitshift(msg.flags_raw(ii), -11));
    msg.flags_almAvail(ii) = bitand(1, bitshift(msg.flags_raw(ii), -12));
    msg.flags_anoAvail(ii) = bitand(1, bitshift(msg.flags_raw(ii), -13));
    msg.flags_aopAvail(ii) = bitand(1, bitshift(msg.flags_raw(ii), -14));
    msg.flags_sbasCorrUsed(ii) = bitand(1, bitshift(msg.flags_raw(ii), -16));
    msg.flags_rtcmCorrUsed(ii) = bitand(1, bitshift(msg.flags_raw(ii), -17));
    msg.flags_prCorrUsed(ii) = bitand(1, bitshift(msg.flags_raw(ii), -20));
    msg.flags_crCorrUsed(ii) = bitand(1, bitshift(msg.flags_raw(ii), -21));
    msg.flags_doCorrUsed(ii) = bitand(1, bitshift(msg.flags_raw(ii), -22));
end

end

