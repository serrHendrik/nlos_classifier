function [gpsTime, tow, wn, wnMod] = utc2gpstime(datemat)
%UTC2GPSTIME converts UTC date vectors of the form [YYYY MM DD hh mm ss]
%into GPS time
%   [gpsTime, tow, wn, wnMod] = UTC2GPSTIME(datemat) converts a UTC date
%   vector of the form [YYYY MM DD hh mm ss] into GPS time
%
%   Input parameters:
%       - datemat: date matrix [N x 6] with rows of the form [YYYY MM DD hh mm ss]
%   Output parameters:
%       - gpsTime: GPS time (seconds since 6th January 1980 00:00:00 (UT))
%       - tow: time of week of GPS time (in seconds)
%       - wn: Week Number of the GPS time
%       - wnMod: Week Number of the GPS time with mod 1024 roll over
%
%   Requirements:
%    - Last leap second included: 2016 01 01.
%    - Check ftp://hpiers.obspm.fr/iers/bul/bulc/TimeSteps.history to include new leap seconds

%   Reference:
%    - B. Hofmann-Wellenhof, L. Liechtenegger, E. Wasle. GNSS. Global
%    Navigation Satellite Systems. GPS, GLONASS, Galileo and more. 2008. Springer.
%    - J. Sanz, J.M. Juan, M. Hernandez. GNSS Data Processing. Volume I:
%    Fundamentals and Algorithms 2013. European Space Agency.

%   Version control:
%       - 08/02/2016: Miguel Cordero v1.0 Initial version

%   Internal notes:
%       - To validate the function, results can be compared e.g. with those
%       from https://www.andrews.edu/~tzs/timeconv/timeconvert.php and from
%       http://www.leapsecond.com/java/gpsclock.htm 

%% Constants
week2day = 7;
day2second = 86400;
week2second = 604800;

% Leap seconds dates after GPS zero epoch
leapSecondsDates = [1981 7 1; 1982 7 1; 1983 7 1; 1985 7 1; 1988 1 1;...
    1990 1 1; 1991 1 1; 1992 7 1; 1993 7 1; 1994 7 1; 1996 1 1; 1997 7 1;...
    1999 1 1; 2006 1 1; 2009 1 1; 2012 7 1; 2015 7 1; 2016 1 1; ];

gpsZeroEpoch = [1980 1 6];
gpsWnRollover = 1024;

%% Check input parameters
% Check input size
if size(datemat,2) == 3
    date = datenum(datemat);
    datemat = [datemat zeros(size(datemat,1),3)];
elseif size(datemat,2) == 6
    date = datenum(datemat);
else
    error(['Input argument must be a N x 3 or N x 6 matrix with date '...
        'vectors of the form [YYYY MM DD] or [YYYY MM DD hh mm ss]']);
end

% Check date vector format
if any(datemat(:,2) == 0) || any(datemat(:,3) == 0)
    error('Month and day cannot be 0, they must start with 1');
end

% Check there is any date previous to GPS zero epoch
if any(date < datenum(gpsZeroEpoch))
    error('Input dates must be after 00:00:00 on 6th January 1980 (UTC)');
end

%% Process
% Convert dates to serial dates
leapSecondsDatesNum = datenum(leapSecondsDates).';

% Find leap seconds previous to input dates
dateRep = repmat(date,1,numel(leapSecondsDatesNum));
leapSecondsDatesRep = repmat(leapSecondsDatesNum,numel(date),1);

accumLeapSeconds = sum((dateRep >= leapSecondsDatesRep),2);

% Calculate GPS time
gpsTimeDays = (datenum(datemat) - datenum(gpsZeroEpoch)) +...
    + accumLeapSeconds/day2second;
wn = floor(gpsTimeDays/week2day);
tow = mod(gpsTimeDays/week2day,1)*week2second;
wnMod = mod(wn,gpsWnRollover);

gpsTime = gpsTimeDays*day2second;

%% End of function