function [ts] = getTimescale(messages)
%GETTIMESCALE Gets the timescale from RXM-RAWX messages
%   TS = GETTIMESCALE(MESSAGES) Gets the timescale from RXM-RAWX messages
%   contained MESSAGES
%   
%   MESSAGES is a struct array of RXM-RAWX messages
%
%  See also PARSE, PARSEUBXFILE.

% Written by Marco Bartolucci <Marco.Bartolucci@esa.int>
% Based on the work by Till Schmitt <till.schmitt@airbus.com>

% The struct array should contain the fields rcvTOW and week
assert(isfield(messages(1), 'rcvTow') && isfield(messages(1), 'week'), 'The struct array does not contain valid time information.');

ts = [messages(:).week].*86400*7 + [messages(:).rcvTow];

end

