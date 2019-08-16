function [ res ] = cdsSelectObservables( gnssObs, obsConfig )
%CDSSELECTOBSERVABLES selects observables according to filter defined by
%obsConfig from gnssObs struct

    periodBegin = [];
    periodEnd = [];
    
    ignoreSvs = [];
    
    selRx = {};
    selSv = {};
    selCh = {};
    selObs = {};
    if ~(nargin < 2 || isempty( obsConfig ))
        settings = fieldnames(obsConfig);
        for i = 1:length(settings)
           setting = settings{i};
           value = obsConfig.(setting);
           switch setting
               case 'receiver'
                   selRx = value;
               case 'constellation'
                   sys = value;
                   for c = sys
                      selSv{end+1} = sprintf('%s\\d\\d', c); 
                   end                  
               case 'channels'
                    selCh = value;     
               case 'firstEpoch'
                   periodBegin = value;
               case 'lastEpoch'
                   periodEnd = value;  
               case 'ignoreSvs'
                   ignoreSvs = value;
               otherwise
                   continue
           end
        end
    end
    filters = { selRx, selSv, selCh, selObs}; % <RX> <SV> <CH> <OBS>
    res = filterObservables( gnssObs, filters, periodBegin, periodEnd );
    
    % apply SV post ignore filter
    if ~isempty(ignoreSvs)
        rxs = fieldnames(res);
        for i = 1:length(rxs)
            rx = rxs{i};
            mask = 0;
            availSvs = fieldnames( res.(rx).svs );
            for j = 1:length( ignoreSvs )
                sv = ignoreSvs{j};
                if any(ismember( availSvs, sv))
                    mask = mask | res.(rx).svs.(sv);
                    res.(rx).svs.(sv) = [];
                end
            end
            if any( mask )
                res.(rx).Obs = res.(rx).Obs(~mask,:);
                res.(rx).labels = res.(rx).labels(~mask);
            end
        end
    end
    
end

