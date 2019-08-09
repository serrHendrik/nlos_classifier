function [ M_res, timespan_res ] = filterTimespan( M, timescale, t1, t2 )
%FILTERTIMESPAN return column sliced matrix on timescale [t1, t2]
%   Detailed explanation goes here

    if nargin < 3 || isempty(t1)
        t1 = timescale(1);
    end
    if nargin < 4 || isempty(t2)
        t2 = timescale(end);
    end

    timescale_N = length(timescale);
    [~, M_N] = size(M);
    assert( M_N == timescale_N, 'Matrix M and timescale must have the same column-dimension' )

    m1 = timescale >= t1 ;
    m2 = timescale <= t2 ;
    mTimespan = m1 & m2;
    assert ( any( mTimespan ), 'One or more elements are not within timescale.' )
    
    M_res = M(:, mTimespan );
    timespan_res = timescale( mTimespan );
end

