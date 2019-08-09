function [msg] = parseNAV(msgId, payload)
%PARSENAV  Parses NAV messages
%   MSG = PARSE(MSGID, PAYLOAD) parses NAV message in PAYLOAD
%
%  See also PARSE, PARSEUBXFILE.

% Written by Marco Bartolucci <Marco.Bartolucci@esa.int>
% Based on the work by Till Schmitt <till.schmitt@airbus.com>

%% Definitions

NAV_CLOCK = hex2dec('22'); % Clock Solution
NAV_DGPS = hex2dec('31'); % DGPS Data Used for NAV
NAV_DOP = 4; % Dilution of precision
NAV_EOE = hex2dec('61'); % End Of Epoch
NAV_GEOFENCE = hex2dec('39'); % Geofencing status
NAV_HPPOSECEF = hex2dec('13'); % High Precision Position Solution in ECEF
NAV_HPPOSLLH = hex2dec('14');  % High Precision Geodetic Position Solution
NAV_ODO = 9; % Odometer Solution
NAV_ORB = hex2dec('34'); % GNSS Orbit Database Info
NAV_POSECEF = 1; % Position Solution in ECEF
NAV_POSLLH = 2; % Geodetic Position Solution
NAV_PVT = 7; % Navigation Position Velocity Time Solution
NAV_RELPOSNED = hex2dec('3C'); % Relative Positioning Information in NED frame
NAV_RESETODO = hex2dec('10'); % Reset odometer
NAV_SAT = hex2dec('35'); % Satellite Information
NAV_SBAS = hex2dec('32'); % SBAS Status Data
NAV_SOL = 6; % Navigation Solution Information
NAV_STATUS = 3; % Receiver Navigation Status
NAV_SVINFO = hex2dec('30'); % Space Vehicle Information
NAV_SVIN = hex2dec('3B'); % Survey-in data
NAV_TIMEBDS = hex2dec('24'); % BDS Time Solution
NAV_TIMEGAL = hex2dec('25'); % Galileo Time Solution
NAV_TIMEGLO = hex2dec('23'); % GLO Time Solution
NAV_TIMEGPS = hex2dec('20'); % GPS Time Solution
NAV_TIMELS = hex2dec('26'); % Leap second event information
NAV_TIMEUTC = hex2dec('21'); % UTC Time Solution
NAV_VELECEF = hex2dec('11'); % Velocity Solution in ECEF
NAV_VELNED = hex2dec('12'); %Velocity Solution in NED

%% Call the right parser
try
    switch msgId
        case NAV_SAT
            msg = parseNAV_SAT(payload);
            msg.msgId = dec2hex(msgId, 2);
        otherwise
            msg = struct([]);
    end
catch e
    warning(getReport(e));
    msg = struct([]);
end

end