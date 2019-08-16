function [ pro ] = filterObservables( obsGnss, filter, period_begin, period_end )
%FILTEROBSERVABLES Filters observables from all RXs specified by filter and star/stop time into new struct
% [<rx>].       --> for each RX (OBS.GNSS.<rx>)
%   .Obs        --> Matrix with observables [m x n] m observables x n epochs 
%   .labels     --> Name Identifier of m observables
%   .timescale  --> n epochs as timescale
% 
% PARAMETERS
% - obsGnss (struct): with RX fields (see OBS.GNSS)
% - filter (cell array of cell arrays): containing cell arrays with filters to apply in the levels of obsGnss 
%     - levels are: RX, CH, SV, OBS
% - period_begin (epoch): selected timespan start time if provided
% - period_end (epoch): selcted timespan end time of provided
%
% DETAIL
% All RXs will have the same start and stop time. Yet the data rate and observables may
% vary.
% One must assure that start and stop times are valid for all RXs (common times), if supplied.
% If t_start and t_stop are not supplied no timesync will be applied (each
% RX will have its initial full timescale).

    if nargin < 3 || isempty(period_begin)
        period_begin = [];
    end
    if nargin < 4 || isempty(period_end)
        period_end = [];
    end

    pro = {};

    RXs = filter{1};
    for runIdx = 1:length(RXs)
        rx = RXs{ runIdx };
        % Filter OBS
        thisRxFilter = filter;
        thisRxFilter{1} = {rx};
        [O, O_labels] = cds2matrix( obsGnss, thisRxFilter );
        if isempty( O_labels )
           continue 
        end
        % Filter Timespan
        [O, t] = filterTimespan( O, obsGnss.(rx).timescale, period_begin, period_end );
        pro.(rx).timescale = t;
        % remove obsolete non-tracking SVs
        trackingSVs_i = sum(~isnan(O), 2) > 0; 
        pro.(rx).Obs = O(trackingSVs_i,:);
        pro.(rx).labels = O_labels( trackingSVs_i );
        % identify SIS observable types and store information
        labelParts = split( pro.(rx).labels, '.');
        obsIds = labelParts(:,:,5);
        exclusivObsIds = unique(obsIds);
        for j = 1:length(exclusivObsIds)
           obsType = exclusivObsIds{j};
           pro.(rx).types.(obsType) = ismember( obsIds, obsType );
        end
        
        svIds = labelParts(:,:,3);
        exclusivSvIds = unique( svIds );
        for j = 1:length(exclusivSvIds)
           svType = exclusivSvIds{j};
           pro.(rx).svs.(svType) = ismember( svIds, svType );
        end
        
    end

end

