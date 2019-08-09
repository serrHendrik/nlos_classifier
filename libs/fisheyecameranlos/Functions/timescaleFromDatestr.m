function [ tscale, dNum ] = timescaleFromDatestr( datestr )
%TIMESCALEFROMDATESTR recognizes date patterns and transforms it to datestr
% 
% Parameters:
%   datestr: variable datestr which must contain the following pattern in
%   that order (seperator independent):
%       YYYY MM DD hh mm ss

    
    datePattern = '(?<year>\d\d\d\d)[^\d]?(?<month>\d{1,2})[^\d]?(?<day>\d{1,2})[^\d]?(?<hour>\d{1,2})[^\d]?(?<minute>\d{1,2})[^\d]?(?<second>\d{1,2})?$';

    dateStruct = regexp( datestr, datePattern, 'names');
    
    if isempty(dateStruct)
       error( 'Input date string "%s"\ndoes not conform with pattern "YYYY MM DD hh mm ss"', datestr ); 
    end

    if isempty(dateStruct.second)
        dateStruct.second = 0;
    end
    
    dNum = datenum( str2double(dateStruct.year), ...
                    str2double(dateStruct.month), ...
                    str2double(dateStruct.day), ...
                    str2double(dateStruct.hour), ...
                    str2double(dateStruct.minute), ...
                    str2double(dateStruct.second) );
    
    tscale = timescaleFromDatenum( dNum );
    
end

