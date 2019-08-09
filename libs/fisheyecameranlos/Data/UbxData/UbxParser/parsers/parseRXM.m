function [msg] = parseRXM(msgId, payload)
%PARSERXM  Parses RXM messages
%   MSG = PARSERXM(MSGID, PAYLOAD) parses RXM message in PAYLOAD
%
%  See also PARSE, PARSEUBXFILE.

% Written by Marco Bartolucci <Marco.Bartolucci@esa.int>
% Based on the work by Till Schmitt <till.schmitt@airbus.com>

%% Definitions
RXM_IMES = hex2dec('61'); % Indoor Messaging System Information
RXM_MEASX = hex2dec('14'); % Satellite Measurements for RRLP
RXM_PMREQ = hex2dec('41'); % Requests a Power Management task
RXM_RAWX = hex2dec('15'); % Multi-GNSS Raw Measurement Data
RXM_RLM = hex2dec('59'); % Output Galileo SAR Short/Long-RLM report
RXM_RTCM = hex2dec('32')'; % Output RTCM input status
RXM_SFRBX = hex2dec('13'); % Output Broadcast Navigation Data Subframe
RXM_SVSI = hex2dec('20'); % SV Status Info
try
    if msgId == RXM_RAWX
        msg = parseRXM_RAWX(payload);
        msg.msgId = dec2hex(msgId, 2);
    else
        msg = struct([]);
    end
catch e
    warning(getReport(e));
    msg = struct([]);
end

end