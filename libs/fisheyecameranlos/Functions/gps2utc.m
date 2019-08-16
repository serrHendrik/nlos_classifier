function [UTC_time, leap_sec] = gps2utc(GPS_week, GPS_sec, offset)

% [UTC_time, leap_sec] = gps2utc(GPS_week, GPS_sec, offset); 
%         or as an optional input format
% [UTC_time, leap_sec] = gps2utc(GPS_time); 
%
% Converts a GPS time into an equivalent UTC time (matrices). 
%
% Input:  
%   GPS_week - GPS week (nx1)
%               valid GPS_week values are 1-3640 (years 1980-2050)
%   GPS_sec  - seconds into the week measured from Sat/Sun midnight (nx1)
%               valid GPS_sec values are 0-604799
%   offset   - leap seconds for the GPS times (optional) (1x1 or nx1)
%               valid offset values are 0-500
% Output: 
%   UTC_time - matrix of the form [year month day hour minute second]
%               with 4-digit year (1980), nx6 matrix
%   leap_sec - leap seconds applied to UTC relative to GPS (optional)
%
% Note: Any invalid inputs times will result in the UTC equilivant time
%       being filled with inf (infinity) and a warning will be issued.  If
%       all of the GPS time input is invalid, the function will terminate
%       with an error.
%
% Optional Input Note: GPS_time = [GPS_week GPS_sec] as an nx2 matrix.
%                 offset is automatically computed when using the optional 
%                 input of GPS time in a single matrix.
%
% See also UTC2GPS, GPS2LEAP

% Written by: Maria Evans/Jimmy LaMance 10/16/96
% Copyright (c) 1996 by Orion Dynamics and Control, Inc.

% functions called: UTC2LEAP

%%%%% BEGIN VARIABLE CHECKING CODE %%%%%
% declare the global debug variable
global DEBUG_MODE

% default sanity checking values
GPS_week_max = 3640;    % maximum value of GPS weeks
GPS_week_min = 0;       % minimum value of GPS weeks
GPS_sec_max = 604800;   % maximum value of GPS seconds
GPS_sec_min = 0;        % minimum value of GPS seconds 
offset_max = 500;       % maximum value of leap second offset
offset_min = 0;         % minimum value of leap second offset

% allocate the memory for the output UTC_time_all matrix
UTC_time_all = ones(size(GPS_week,1),6) * inf;

if nargin == 1     % using the optional input
  if size(GPS_week,2) ~= 2
    fprintf('The size of the GPS_time input to GPS2UTC must be \n');
    fprintf('nx2 when using the optional 1 input parameter.\n');
    fprintf('The size of GPS_time was %d x %d.\n',size(GPS_week))
    if DEBUG_MODE
      fprintf('Error message from GPS2UTC: \n');
      fprintf('The GPS_time input to GPS2UTC must be nx2.\n');
      return
    else
      error('The GPS_time input to GPS2UTC must be nx2.') 
    end % if DEBUG_MODE
  else
    GPS_sec = GPS_week(:,2);
    GPS_week = GPS_week(:,1);
  end % if size(GPS_week,2) ~= 2
end % if nargin == 1     % using the optional input  
 
% check the dimensions on the input arguments
if size(GPS_week,2) ~= 1
  fprintf('\nThe size of GPS_week was %d x %d.\n',size(GPS_week))
  if DEBUG_MODE
    fprintf('Error message from GPS2UTC: \n');
    fprintf('The size of the GPS_week input to GPS2UTC must be nx1.\n');
    return
  else
    error('The size of the GPS_week input to GPS2UTC must be nx1.') 
  end % if DEBUG_MODE
end % if size(GPS_week,2) ~= 1  

if size(GPS_sec,2) ~= 1
  fprintf('\nThe size of GPS_sec was %d x %d.\n',size(GPS_sec))
  if DEBUG_MODE
    fprintf('Error message from GPS2UTC: \n');
    fprintf('The size of the GPS_sec input to GPS2UTC must be nx1.\n');
    return 
  else
    error('The size of the GPS_sec input to GPS2UTC must be nx1.')
  end % if DEBUG_MODE
end % if size(GPS_sec,2) ~= 1  

if size(GPS_sec,1) ~= size(GPS_week,1)
  fprintf('The size of the GPS_week and GPS_sec input to GPS2UTC must \n');
  fprintf('match in the n dimension and be nx1.\n');
  fprintf('\nThe size of GPS_week and GPS_sec were %d x %d and %d x %d.\n',...
           size(GPS_week),size(GPS_sec))
  if DEBUG_MODE
    fprintf('Error message from GPS2UTC: \n');
    fprintf('The GPS_week and GPS_sec variables to GPS2UTC do not match.\n');
    return 
  else
    error('The GPS_week and GPS_sec variables to GPS2UTC do not match.')
  end % if DEBUG_MODE
end % size(GPS_sec,1) ~= size(GPS_week,1)  

% find the number of input arguments provided
num_args = nargin;   

if num_args == 3         % offset is given and must match dimensions
  if size(offset,1) ~= size(GPS_week,1) & length(offset) ~= 1
    fprintf('The size of offset input to GPS2UTC must be compatible \n');
    fprintf('with GPS_week (either a 1x1 or nx1), where n = %d.\n',...
             size(GPS_week,1));
    fprintf('The size of offset was %d x %d.\n',size(offset));
    if DEBUG_MODE
      fprintf('Error message from GPS2UTC: \n');
      fprintf('The offset variable to GPS2UTC is not compatible.\n');
      return 
    else
      error('The offset variable to GPS2UTC is not compatible.')
    end % if DEBUG_MODE
  end % if size(offset,1) ~= size(GPS_week,1) & size(offset,1) ~= 1 
  
  I = find(offset < offset_min | offset > offset_max);
  if any(I)
    fprintf('\nWarning from GPS2UTC.  Invalid values for parameter offset.\n')
    fprintf('\nSee help on GPS2UTC for details.\n')
  end % if any(I)
  clear I
  
end % if num_args == 3

% check the validity of the input
I_bad_week = find(GPS_week < GPS_week_min | GPS_week > GPS_week_max);

if any(I_bad_week)   % any bad GPS_weeks
  if length(I_bad_week) == length(GPS_week)    % all bad
    if DEBUG_MODE
      fprintf('Error message from GPS2UTC: \n');
      fprintf('All GPS_week inputs to GPS2UTC are invalid\n');
      return 
    else
      error('All GPS_week inputs to GPS2UTC are invalid')
    end % if DEBUG_MODE
  else
    fprintf('Warning from GPS2UTC:  \n');
    fprintf('Some invalid values for parameter GPS_week.\n')
    fprintf('See help on GPS2UTC for details.\n')
  end % if length(I_bad_week) == length(GPS_week)
end % if any(I_bad_week)   % any bad GPS_weeks

I_bad_sec = find(GPS_sec < GPS_sec_min | GPS_sec > GPS_sec_max);
if any(I_bad_sec)   % any bad GPS_sec
  if length(I_bad_sec) == length(GPS_sec)    % all bad
    if DEBUG_MODE
      fprintf('Error message from GPS2UTC: \n');
      fprintf('All GPS_sec inputs to GPS2UTC are invalid.\n');
      return 
    else
      error('All GPS_sec inputs to GPS2UTC are invalid.')
    end % if DEBUG_MODE
  else
    fprintf('Warning from GPS2UTC.  \n');
    fprintf('Some invalid values for parameter GPS_sec.')
    fprintf('See help on GPS2UTC for details.\n')
  end % if length(I_bad_sec) == length(GPS_sec)    % all bad
end % if any(I)   % any bad GPS_sec

% sort out the bad times so they don't corrupt the rest of the computations
if (any(I_bad_sec) | any(I_bad_week))
  I_good = find((GPS_week >= GPS_week_min & GPS_week <= GPS_week_max) & ... 
                (GPS_sec  >= GPS_sec_min  & GPS_sec  <= GPS_sec_max)); 
  I_bad = [I_bad_week I_bad_sec];
  
  GPS_week_all = GPS_week;     % store the original data in the *all matrix
  GPS_sec_all = GPS_sec;
  
  GPS_week = GPS_week(I_good);   % cull out the bad
  GPS_sec = GPS_sec(I_good);
  
  if nargin == 3      % offset variable provided
    if size(offset,1) ~= 1         % it's not a single offset time given
      offset = offset(I_good);     % cull out the bad
    end % if size(offset) ~= 1
  end % if nargin == 3 

end % if (any(I_bad_sec) | any(I_bad_week))               

%%%%% END VARIABLE CHECKING CODE %%%%%

%%%%% BEGIN ALGORITHM CODE %%%%%

% allocate the momory for the UTC_time working matrix
UTC_time = ones(size(GPS_week,1),6) * inf;

% compute gpsday and gps seconds since start of GPS time 
gpsday = GPS_week * 7 + GPS_sec ./ 86400;
gpssec = GPS_week * 7 * 86400 + GPS_sec;

% get the integer number of days
total_days = floor(gpsday);

% temp is the number of completed years since the last leap year (0-3)
% the calculation begins by computing the number of full days since
% the beginning of the last leap year.  This is accomplished through
% the rem statement.  Since GPS time started at
% 00:00 on 6 January 1980, five days must be added to the total number
% of days to ensure that the calculation begins at the beginning of a
% leap year.  By subtracting one from this result, the extra day in
% the first year is effectively removed, and the calculation can
% simply be computed by determining the number of times 365 divides
% into the number of days since the last leap year.  On the first day
% of a leap year, the result of this calculation is -1
% so the second statement is used to trap this case.

temp = floor((rem((total_days+5),1461)-1) ./ 365);
I_temp=find(temp < 0);
if any(I_temp), 
  temp(I_temp) = zeros(size(temp(I_temp))); 
end % if

% compute the year
UTC_time(:,1) = 1980 + 4 * floor((total_days + 5) ./ 1461) + temp;

% data matrix with the number of days per month for searching 
% for the month and day
% days in full months for leap year
leapdays =   [0 31 60 91 121 152 182 213 244 274 305 335 366];  
% days in full months for standard year
noleapdays = [0 31 59 90 120 151 181 212 243 273 304 334 365];                                                      

% Leap year flag
% determine which input years are leap years
leap_year = ~rem((UTC_time(:,1)-1980),4);     
I_leap = find(leap_year == 1);                % find leap years
I_no_leap = find(leap_year == 0);             % find standard years

% establish the number of days into the current year
% leap year
if any(I_leap)
  day_of_year(I_leap) = rem((total_days(I_leap) + 5),1461) + 1;                        
end % if any(I_leap)

% standard year
if any(I_no_leap)
  day_of_year(I_no_leap) = ...
      rem(rem((total_days(I_no_leap) + 5),1461) - 366, 365) + 1;  
end % if any(I_no_leap)

% generate the month, loop over the months 1-12 and separate out leap years
for iii = 1:12
  if any(I_leap)
    I_day = find(day_of_year(I_leap) > leapdays(iii));
    UTC_time(I_leap(I_day),2) = ones(size(I_day')) * iii;
    clear I_day
  end % if any(I_leap) 
  
  if any(I_no_leap)
    I_day = find(day_of_year(I_no_leap) > noleapdays(iii));
    UTC_time(I_no_leap(I_day),2) = ones(size(I_day')) * iii;
    clear I_day
  end % if any(I_no_leap)
end % for

% use the month and the matrix with days per month to compute the day 
if any(I_leap)
  UTC_time(I_leap,3) = day_of_year(I_leap)' - leapdays(UTC_time(I_leap,2))';
end % if any(I_leap)

if any(I_no_leap)
  UTC_time(I_no_leap,3) = day_of_year(I_no_leap)' - ...
                          noleapdays(UTC_time(I_no_leap,2))';
end % if any(I_no_leap)

% compute the hours
fracday = rem(GPS_sec, 86400);              % in seconds!

UTC_time(:,4) = fix(fracday ./ 86400 .* 24);

% compute the minutes 
UTC_time(:,5) = fix((fracday - UTC_time(:,4) .* 3600) ./ 60 );

% compute the seconds
UTC_time(:,6) = fracday - UTC_time(:,4) .* 3600 - UTC_time(:,5) .* 60;

% Compensate for leap seconds
% check the input agrument list for offset (leap seconds)
if num_args < 3         % offset is not given and must be computed
  % Call utc2leap to compute the leap second offset for each time
  leap_sec = utc2leap(UTC_time);
else
  leap_sec = offset;
end % if num_args < 3

UTC_time(:,6) = UTC_time(:,6) - leap_sec;

% Check to see if leap_sec offset causes a negative number of seconds
I_shift = find(UTC_time(:,6) < 0);
UTC_time(I_shift,5) = UTC_time(I_shift,5) - 1;
UTC_time(I_shift,6) = UTC_time(I_shift,6) + 60;

% Check to see if the leap second offset causes a negative number of minutes
I_shift = find(UTC_time(:,5) < 0);
UTC_time(I_shift,4) = UTC_time(I_shift,4) - 1;
UTC_time(I_shift,5) = UTC_time(I_shift,5) + 60;

% Check to see if the leap second offset causes a negative number of hours
I_shift = find(UTC_time(:,4) < 0);
UTC_time(I_shift,3) = UTC_time(I_shift,3) - 1;
UTC_time(I_shift,4) = UTC_time(I_shift,4) + 24;

% Check to see if this causes a 0 day value
I_shift = find(UTC_time(:,3) <= 0);
UTC_time(I_shift,2) = UTC_time(I_shift,2) - 1;
I_yr_shift = find(UTC_time(:,2) <= 0);
UTC_time(I_yr_shift,1) = UTC_time(I_yr_shift,1) - 1;
UTC_time(I_yr_shift,2) = UTC_time(I_yr_shift,2) + 12;

% Leap year flag
 % determine which input years are leap years
leap_year = ~rem((UTC_time(I_shift,1)-1980),4);    
I_leap = find(leap_year == 1);                % find leap years
I_no_leap = find(leap_year == 0);             % find standard years

if any(I_leap),
  UTC_time(I_shift(I_leap),3) = leapdays(UTC_time(I_shift(I_leap),2) + 1)' ...
                               -leapdays(UTC_time(I_shift(I_leap),2))';
end;
if any(I_no_leap),
  UTC_time(I_shift(I_no_leap),3) = ...
         noleapdays(UTC_time(I_shift(I_no_leap),2) + 1)' ...
         -noleapdays(UTC_time(I_shift(I_no_leap),2))';
end;

% reestablish the original data matrix sizes if any bad 
% observations were found
if (any(I_bad_sec) | any(I_bad_week))
  leap_sec_all(I_good) = leap_sec;
  leap_sec_all(I_bad) = ones(size(I_bad)) * inf;
  clear leap_sec
  leap_sec = leap_sec_all;
  UTC_time_all(I_good,:) = UTC_time;
  UTC_time_all(I_bad,:) = UTC_time_all(I_bad,:);
  clear UTC_time
  UTC_time = UTC_time_all;
end % if (any(I_bad_sec) | any(I_bad_week))  

%%%%% END ALGORITHM CODE %%%%%

% end of GPS2UTC
