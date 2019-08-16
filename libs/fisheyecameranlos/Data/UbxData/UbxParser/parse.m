function [cds, varargout] = parse(buffer, options)
%PARSE  Parses ubx binary buffer
%   CDS = PARSE(BUFFER) parses BUFFER and converts it to CDS.
%
%   CDS = PARSE(BUFFER, OPTIONS) parses BUFFER and converts it to CDS 
%   with OPTIONS, where OPTIONS is a STRUCT.
%
%   [CDS, MSG] = PARSE(...) when called with two output arguments, MSG is a
%   cell array of parsed messages.
%
%   OPTIONS is currently reserved for future expansion.
%
%  See also PARSEUBXFILE.

% Written by Marco Bartolucci <Marco.Bartolucci@esa.int>
% Based on the work by Till Schmitt <till.schmitt@airbus.com>

addpath(genpath('.\parsers'));

narginchk(1,2);

%% load UBX types
ubxTypes

%% Definitions
% constants should be defined here

SYNC_WORD = [hex2dec('b5'), hex2dec('62')]; % at the start of each frame

% class id
NAV = 1;
RXM = 2;
INF = 4;
ACK = 5;
CFG = 6;
UPD = 9;
MON = hex2dec('0a');
AID = hex2dec('0b');
TIM = hex2dec('0d');
ESF = hex2dec('10');
MGA = hex2dec('13');
LOG = hex2dec('21');
SEC = hex2dec('27');
HNR = hex2dec('28');


%% Find SYNC words

r = size(buffer, 1);
if r ~= 1
    buffer = buffer.';
end

frameInd = strfind(buffer, SYNC_WORD);
frameN = length(frameInd);

assert(frameN > 0, 'No SYNC word found!');

msg = cell(1, frameN);

%% Parse frames

wb = waitbar(0, 'Parsing frames...');

for ii = 1:frameN
    waitbar(ii/frameN, wb, 'Parsing frames...');
    
    frameStartInd = frameInd(ii);
    
    msgClassInd = frameStartInd + 2;
    msgIdInd = frameStartInd + 3;
    msgLenInd = frameStartInd + 4;
    payloadStartInd = frameStartInd + 6;
    
    msgClass = buffer(msgClassInd);
    msgId = buffer(msgIdInd);
     
    % check if this is really a new packet or a sync word in the payload
    if ii > 1
        if frameInd(ii-1) + payloadSize + 8 > frameInd(ii)
            frameInd(ii) = -Inf;
            continue;
        end
    end
    
    % This handles truncated ubx files
    try
        payloadSize = typeConv(U2, buffer, msgLenInd-1);    
    catch e
        warning(getReport(e));
        msg{ii} = struct([]);
        continue;
    end
    
    payload = buffer(payloadStartInd:payloadStartInd+payloadSize-1);
    
    % checksum
    checksumBuf = buffer(msgClassInd:msgClassInd+4+payloadSize+1); % including CK_A CK_B
    
    if ~checksum(checksumBuf)
        warning('Skipped Frame: %06d [Checksum failed]\n', ii);
       continue; 
    end
    
    switch msgClass
        case NAV
            msg{ii} = parseNAV(msgId, payload);
        case RXM
            msg{ii} = parseRXM(msgId, payload);
        otherwise % unknow classId
            continue;
    end
    
    if ~isempty(msg{ii})
        msg{ii}.classId = dec2hex(msgClass, 2);
    end
    
end

close(wb)

%% convert to cds
msg = msg(~cellfun('isempty', msg));
cds =  toCds(msg);

if nargout == 2
    varargout{1} = msg;
end

end