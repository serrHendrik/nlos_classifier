%% Statistics Plotter
%
% Script that generates a plots (CDF and histograms) that can be used for
% statistical analysis of a certain test scenario.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Author: Floor Melman
% Company: European Space Agency
%
% Date: 12.02.2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Change History
%
% - V0.1: Prototyping
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Elevation/Pb CDF Plot

% Create different line styles
lineStyleVec    = {'-','-.','--',':','-','-.','--',':','-'};
lineStyleMark   = {'o','s','d','x','^','v','<','>','*'};

if conf.getProbMat == 0 || conf.getProbMat == 1
    noBorders   = 7;
    elevList    = linspace(0,90,noBorders);
    legendVec   = [];

    figure()
    hold on
    for i = 1:noBorders-1
        pbCurrElev      = sampleLine.G.islos(aZeLStructure.G.ElCm > elevList(i) & ...
            aZeLStructure.G.ElCm <= elevList(i+1));
        if ~isempty(pbCurrElev)
            [f,x]           = ecdf(pbCurrElev);
            plot(x,f,'LineStyle',lineStyleVec{i},'Marker',lineStyleMark{i})
            legendVec           = [legendVec,strcat('Elevation: ',num2str(elevList(i),'%.0f'),'-',num2str(elevList(i+1),'%.0f'),{' '},'deg')];
        end    
    end
    legend(legendVec,'Location','northwest')
    xlabel('Probability of Visible Sky [-]')
    ylabel('CDF [-]')
    title(strcat('LOS/NLOS Elevation Classification - n_o_b_s:',{' '},num2str(numel(aZeLStructure.G.ElCm),'%.0f')))
    grid on
end

%% Elevation/Pb CDF Plot

% Create different line styles
lineStyleVec    = {'-','-.','--',':','-','-.','--',':','-'};
lineStyleMark   = {'o','s','d','x','^','v','<','>','*'};

if conf.getProbMat == 0 || conf.getProbMat == 1
    noBorders   = 7;
    elevList    = linspace(0,90,noBorders);
    legendVec   = [];

    figure()
    hold on
    for i = 1:noBorders-1
        pbCurrElev      = sampleLine.G.islos(aZeLStructure.G.ElCm > elevList(i) & ...
            aZeLStructure.G.ElCm <= elevList(i+1));
        if ~isempty(pbCurrElev)
            [f,x]           = ecdf(pbCurrElev);
            plot(x,f,'LineStyle',lineStyleVec{i},'Marker',lineStyleMark{i})
            legendVec           = [legendVec,strcat('Elevation: ',num2str(elevList(i),'%.0f'),'-',num2str(elevList(i+1),'%.0f'),{' '},'deg')];
        end    
    end
    legend(legendVec,'Location','northwest')
    xlabel('Probability of Visible Sky [-]')
    ylabel('CDF [-]')
    title(strcat('LOS/NLOS Elevation Classification - n_o_b_s:',{' '},num2str(numel(aZeLStructure.G.ElCm),'%.0f')))
    grid on
end

%% Elevation/Pb Histogram

if conf.getProbMat == 0 || conf.getProbMat == 1
    noBorders   = 7;
    noCols      = floor((noBorders-1)/2);
    noRows      = (noBorders-1)/noCols;
    elevList    = linspace(0,90,noBorders);
    legendVec   = [];

    figure()
    hold on
    for i = 1:noBorders-1        
        pbCurrElev      = sampleLine.G.islos(aZeLStructure.G.ElCm > elevList(i) & ...
            aZeLStructure.G.ElCm <= elevList(i+1));
        subplot(noRows,noCols,i)
        if ~isempty(pbCurrElev)
            histogram(pbCurrElev,'Normalization','Probability')
            title(strcat('Elevation: ',num2str(elevList(i),'%.0f'),'-',num2str(elevList(i+1),'%.0f'),{' '},'deg'));
            ylabel('PDF Normalized Probability [-]')
            xlabel('Probability of sky-detection [-]')
        end   
        
        
    end
end

%% CN0/Pb Histogram

if conf.getProbMat == 0 || conf.getProbMat == 1
    noBorders   = 7;
    noCols      = floor((noBorders-1)/2);
    noRows      = (noBorders-1)/noCols;
    CN0List     = linspace(min(min(nav.G.matCN0)),max(max(nav.G.matCN0)),noBorders);
    legendVec   = [];

    figure()
    hold on
    for i = 1:noBorders-1        
        pbCurrCN0   = sampleLine.G.islos(nav.G.matCN0 > CN0List(i) & ...
            nav.G.matCN0 <= CN0List(i+1));
        subplot(noRows,noCols,i)
        if ~isempty(pbCurrCN0)
            histogram(pbCurrCN0,'Normalization','Probability')
            title(strcat('CN_0: ',num2str(CN0List(i),'%.0f'),'-',num2str(CN0List(i+1),'%.0f'),{' '},'dB-Hz'));
            ylabel('PDF Normalized Probability [-]')
            xlabel('Probability of sky-detection [-]')
        end   
        
        
    end
end