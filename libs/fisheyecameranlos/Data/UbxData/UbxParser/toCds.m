function [cds] = toCds(cells, start, stop)
%TOCDS  Converts parsed data to CDS
%   CDS = TOCDS(CELLS) converts the parsed data in CELLS to CDS
%
%   CDS = TOCDS(CELLS, START) converts the parsed data in CELLS to CDS,
%   starting at the START-th epoch
%
%   CDS = TOCDS(CELLS, START, STOP) converts the parsed data in CELLS to
%   CDS starting at the START-th epoch and stopping at the STOP-th epoch
%
%   CELLS is a cell array with parsed data
%
%  See also PARSE, PARSEUBXFILE, .

% Written by Marco Bartolucci <Marco.Bartolucci@esa.int>
% Based on the work by Till Schmitt <till.schmitt@airbus.com>

narginchk(1,3);

cds = struct();

rxmrawx = filterMsg(cells, '02', '15');
navsat = filterMsg(cells, '01', '35');

G = split(sprintf('G%02d\n', 1:32));
G=G(~cellfun('isempty', G));

E = split(sprintf('E%02d\n', 1:36));
E=E(~cellfun('isempty', E));

R = split(sprintf('R%02d\n', 1:32)); % ignoring R?
R=R(~cellfun('isempty', R));

cds.timescale = getTimescale(rxmrawx);

if nargin < 2
    start=1;
end
if nargin < 3
    stop=numel(cds.timescale);
end

cds.timescale = cds.timescale(start:stop);

pr = getSvField(rxmrawx, 'prMes');
gpsC1C = [pr(start:stop).gpsprMes];
galC1C = [pr(start:stop).galprMes];
gloC1C = [pr(start:stop).gloprMes];

cno = getSvField(rxmrawx, 'cno');
gpsS1C = [cno(start:stop).gpscno];
galS1C = [cno(start:stop).galcno]; 
gloS1C = [cno(start:stop).glocno];

do = getSvField(rxmrawx, 'doMes');
gpsD1C = [do(start:stop).gpsdoMes];
galD1C = [do(start:stop).galdoMes]; 
gloD1C = [do(start:stop).glodoMes];

cp = getSvField(rxmrawx, 'cpMes');
gpsL1C = [cp(start:stop).gpscpMes];
galL1C = [cp(start:stop).galcpMes]; 
gloL1C = [cp(start:stop).glocpMes];

lt = getSvField(rxmrawx, 'locktime');
gpsLt = [lt(start:stop).gpslocktime];
galLt = [lt(start:stop).gallocktime];
gloLt = [lt(start:stop).glolocktime];

prStdev = getSvField(rxmrawx, 'prStdev');
gpsPrStdev = [prStdev(start:stop).gpsprStdev];
galPrStdev = [prStdev(start:stop).galprStdev];
gloPrStdev = [prStdev(start:stop).gloprStdev];

cpStdev = getSvField(rxmrawx, 'cpStdev');
gpsCpStdev = [cpStdev(start:stop).gpscpStdev];
galCpStdev = [cpStdev(start:stop).galcpStdev];
gloCpStdev = [cpStdev(start:stop).glocpStdev];

doStdev = getSvField(rxmrawx, 'doStdev');
gpsDoStdev = [doStdev(start:stop).gpsdoStdev];
galDoStdev = [doStdev(start:stop).galdoStdev];
gloDoStdev = [doStdev(start:stop).glodoStdev];

prValid = getSvField(rxmrawx, 'trkStat_prValid', 'prValid');
gpsPrValid = [prValid(start:stop).gpsprValid];
galPrValid = [prValid(start:stop).galprValid];
gloPrValid = [prValid(start:stop).gloprValid];

cpValid = getSvField(rxmrawx, 'trkStat_cpValid', 'cpValid');
gpsCpValid = [cpValid(start:stop).gpscpValid];
galCpValid = [cpValid(start:stop).galcpValid];
gloCpValid = [cpValid(start:stop).glocpValid];

halfCyc = getSvField(rxmrawx, 'trkStat_halfCyc', 'halfCyc');
gpsHalfCyc = [halfCyc(start:stop).gpshalfCyc];
galHalfCyc = [halfCyc(start:stop).galhalfCyc];
gloHalfCyc = [halfCyc(start:stop).glohalfCyc];

subHalfCyc = getSvField(rxmrawx, 'trkStat_subHalfCyc', 'subHalfCyc');
gpsSubHalfCyc = [subHalfCyc(start:stop).gpssubHalfCyc];
galSubHalfCyc = [subHalfCyc(start:stop).galsubHalfCyc];
gloSubHalfCyc = [subHalfCyc(start:stop).glosubHalfCyc];

elev = getSvField(navsat, 'elev');
gpsElev = [elev(start:stop).gpselev];
galElev = [elev(start:stop).galelev];
gloElev = [elev(start:stop).gloelev];

azim = getSvField(navsat, 'azim');
gpsAzim = [azim(start:stop).gpsazim];
galAzim = [azim(start:stop).galazim];
gloAzim = [azim(start:stop).gloazim];

prRes = getSvField(navsat, 'prRes');
gpsPrRes = [prRes(start:stop).gpsprRes];
galPrRes = [prRes(start:stop).galprRes];
gloPrRes = [prRes(start:stop).gloprRes];

qualityInd = getSvField(navsat, 'flags_qualityInd', 'qualityInd');
gpsQualityInd = [qualityInd(start:stop).gpsqualityInd];
galQualityInd = [qualityInd(start:stop).galqualityInd];
gloQualityInd = [qualityInd(start:stop).gloqualityInd];

svUsed = getSvField(navsat, 'flags_svUsed', 'svUsed');
gpsSvUsed = [svUsed(start:stop).gpssvUsed];
galSvUsed = [svUsed(start:stop).galsvUsed];
gloSvUsed = [svUsed(start:stop).glosvUsed];

health = getSvField(navsat, 'flags_health', 'health');
gpsHealth = [health(start:stop).gpshealth];
galHealth = [health(start:stop).galhealth];
gloHealth = [health(start:stop).glohealth];

diffCorr = getSvField(navsat, 'flags_diffCorr', 'diffCorr');
gpsDiffCorr = [diffCorr(start:stop).gpsdiffCorr];
galDiffCorr = [diffCorr(start:stop).galdiffCorr];
gloDiffCorr = [diffCorr(start:stop).glodiffCorr];

smoothed = getSvField(navsat, 'flags_smoothed', 'smoothed');
gpsSmoothed = [smoothed(start:stop).gpssmoothed];
galSmoothed = [smoothed(start:stop).galsmoothed];
gloSmoothed = [smoothed(start:stop).glosmoothed];

orbitSource = getSvField(navsat, 'flags_orbitSource', 'orbitSource');
gpsOrbitSource = [orbitSource(start:stop).gpsorbitSource];
galOrbitSource = [orbitSource(start:stop).galorbitSource];
gloOrbitSource = [orbitSource(start:stop).gloorbitSource];

ephAvail = getSvField(navsat, 'flags_ephAvail', 'ephAvail');
gpsEphAvail = [ephAvail(start:stop).gpsephAvail];
galEphAvail = [ephAvail(start:stop).galephAvail];
gloEphAvail = [ephAvail(start:stop).gloephAvail];

almAvail = getSvField(navsat, 'flags_almAvail', 'almAvail');
gpsAlmAvail = [almAvail(start:stop).gpsalmAvail];
galAlmAvail = [almAvail(start:stop).galalmAvail];
gloAlmAvail = [almAvail(start:stop).gloalmAvail];

anoAvail = getSvField(navsat, 'flags_anoAvail', 'anoAvail');
gpsAnoAvail = [anoAvail(start:stop).gpsanoAvail];
galAnoAvail = [anoAvail(start:stop).galanoAvail];
gloAnoAvail = [anoAvail(start:stop).gloanoAvail];

anoAvail = getSvField(navsat, 'flags_aopAvail', 'aopAvail');
gpsAopAvail = [anoAvail(start:stop).gpsaopAvail];
galAopAvail = [anoAvail(start:stop).galaopAvail];
gloAopAvail = [anoAvail(start:stop).gloaopAvail];

sbasCorrUsed = getSvField(navsat, 'flags_sbasCorrUsed', 'sbasCorrUsed');
gpsSbasCorrUsed = [sbasCorrUsed(start:stop).gpssbasCorrUsed];
galSbasCorrUsed = [sbasCorrUsed(start:stop).galsbasCorrUsed];
gloSbasCorrUsed = [sbasCorrUsed(start:stop).glosbasCorrUsed];

rtcmCorrUsed = getSvField(navsat, 'flags_rtcmCorrUsed', 'rtcmCorrUsed');
gpsRtcmCorrUsed = [rtcmCorrUsed(start:stop).gpsrtcmCorrUsed];
galRtcmCorrUsed = [rtcmCorrUsed(start:stop).galrtcmCorrUsed];
gloRtcmCorrUsed = [rtcmCorrUsed(start:stop).glortcmCorrUsed];

prCorrUsed = getSvField(navsat, 'flags_prCorrUsed', 'prCorrUsed');
gpsPrCorrUsed = [prCorrUsed(start:stop).gpsprCorrUsed];
galPrCorrUsed = [prCorrUsed(start:stop).galprCorrUsed];
gloPrCorrUsed = [prCorrUsed(start:stop).gloprCorrUsed];

crCorrUsed = getSvField(navsat, 'flags_crCorrUsed', 'crCorrUsed');
gpsCrCorrUsed = [crCorrUsed(start:stop).gpscrCorrUsed];
galCrCorrUsed = [crCorrUsed(start:stop).galcrCorrUsed];
gloCrCorrUsed = [crCorrUsed(start:stop).glocrCorrUsed];

doCorrUsed = getSvField(navsat, 'flags_doCorrUsed', 'doCorrUsed');
gpsDoCorrUsed = [doCorrUsed(start:stop).gpsdoCorrUsed];
galDoCorrUsed = [doCorrUsed(start:stop).galdoCorrUsed];
gloDoCorrUsed = [doCorrUsed(start:stop).glodoCorrUsed];


for ii = 1:numel(G)
    cds.(G{ii}).CH.L1C = gpsL1C(ii,:);
    cds.(G{ii}).CH.S1C = gpsS1C(ii,:);
    cds.(G{ii}).CH.D1C = gpsD1C(ii,:);
    cds.(G{ii}).CH.C1C = gpsC1C(ii,:);
    
    cds.(G{ii}).CH.L1CSSI = nan(size(cds.timescale));
    cds.(G{ii}).CH.C1CSSI = nan(size(cds.timescale));
    cds.(G{ii}).CH.L1LLI = nan(size(cds.timescale));
    cds.(G{ii}).CH.D1CSSI = nan(size(cds.timescale));
    
    cds.(G{ii}).RXFLAGS.locktime = gpsLt(ii,:);
    cds.(G{ii}).RXFLAGS.prStdev = gpsPrStdev(ii,:);
    cds.(G{ii}).RXFLAGS.cpStdev = gpsCpStdev(ii,:);
    cds.(G{ii}).RXFLAGS.doStdev = gpsDoStdev(ii,:);
    
    cds.(G{ii}).RXFLAGS.prValid = gpsPrValid(ii,:);
    cds.(G{ii}).RXFLAGS.cpValid = gpsCpValid(ii,:);
    cds.(G{ii}).RXFLAGS.halfCyc = gpsHalfCyc(ii,:);
    cds.(G{ii}).RXFLAGS.subHalfCyc = gpsSubHalfCyc(ii,:);
    
    cds.(G{ii}).RXFLAGS.elev = gpsElev(ii,:);
    cds.(G{ii}).RXFLAGS.azim = gpsAzim(ii,:);
    cds.(G{ii}).RXFLAGS.prRes = gpsPrRes(ii,:);
    
    cds.(G{ii}).RXFLAGS.qualityInd = gpsQualityInd(ii,:);
    cds.(G{ii}).RXFLAGS.svUsed = gpsSvUsed(ii,:);
    cds.(G{ii}).RXFLAGS.health = gpsHealth(ii,:);
    cds.(G{ii}).RXFLAGS.diffCorr = gpsDiffCorr(ii,:);
    cds.(G{ii}).RXFLAGS.smoothed = gpsSmoothed(ii,:);
    cds.(G{ii}).RXFLAGS.orbitSource = gpsOrbitSource(ii,:);
    cds.(G{ii}).RXFLAGS.ephAvail = gpsEphAvail(ii,:);
    cds.(G{ii}).RXFLAGS.almAvail = gpsAlmAvail(ii,:);
    cds.(G{ii}).RXFLAGS.anoAvail = gpsAnoAvail(ii,:);
    cds.(G{ii}).RXFLAGS.aopAvail = gpsAopAvail(ii,:);
    cds.(G{ii}).RXFLAGS.sbasCorrUsed = gpsSbasCorrUsed(ii,:);
    cds.(G{ii}).RXFLAGS.rtcmCorrUsed = gpsRtcmCorrUsed(ii,:);
    cds.(G{ii}).RXFLAGS.prCorrUsed = gpsPrCorrUsed(ii,:);
    cds.(G{ii}).RXFLAGS.crCorrUsed = gpsCrCorrUsed(ii,:);
    cds.(G{ii}).RXFLAGS.doCorrUsed = gpsDoCorrUsed(ii,:);
end

for ii = 1:numel(E)
    cds.(E{ii}).CH.L1C = galL1C(ii,:);
    cds.(E{ii}).CH.S1C = galS1C(ii,:);
    cds.(E{ii}).CH.D1C = galD1C(ii,:);
    cds.(E{ii}).CH.C1C = galC1C(ii,:);
    
    cds.(E{ii}).CH.L1CSSI = nan(size(cds.timescale));
    cds.(E{ii}).CH.C1CSSI = nan(size(cds.timescale));
    cds.(E{ii}).CH.L1LLI = nan(size(cds.timescale));
    cds.(E{ii}).CH.D1CSSI = nan(size(cds.timescale));
    
    cds.(E{ii}).RXFLAGS.locktime = galLt(ii,:);
    cds.(E{ii}).RXFLAGS.prStdev = galPrStdev(ii,:);
    cds.(E{ii}).RXFLAGS.cpStdev = galCpStdev(ii,:);
    cds.(E{ii}).RXFLAGS.doStdev = galDoStdev(ii,:);
    
    cds.(E{ii}).RXFLAGS.prValid = galPrValid(ii,:);
    cds.(E{ii}).RXFLAGS.cpValid = galCpValid(ii,:);
    cds.(E{ii}).RXFLAGS.halfCyc = galHalfCyc(ii,:);
    cds.(E{ii}).RXFLAGS.subHalfCyc = galSubHalfCyc(ii,:);
    
    cds.(E{ii}).RXFLAGS.elev = galElev(ii,:);  
    cds.(E{ii}).RXFLAGS.azim = galAzim(ii,:); 
    cds.(E{ii}).RXFLAGS.prRes = galPrRes(ii,:);
    
    cds.(E{ii}).RXFLAGS.qualityInd = galQualityInd(ii,:);
    cds.(E{ii}).RXFLAGS.svUsed = galSvUsed(ii,:);
    cds.(E{ii}).RXFLAGS.health = galHealth(ii,:);
    cds.(E{ii}).RXFLAGS.diffCorr = galDiffCorr(ii,:);
    cds.(E{ii}).RXFLAGS.smoothed = galSmoothed(ii,:);
    cds.(E{ii}).RXFLAGS.orbitSource = galOrbitSource(ii,:);
    cds.(E{ii}).RXFLAGS.ephAvail = galEphAvail(ii,:);
    cds.(E{ii}).RXFLAGS.almAvail = galAlmAvail(ii,:);
    cds.(E{ii}).RXFLAGS.anoAvail = galAnoAvail(ii,:);
    cds.(E{ii}).RXFLAGS.aopAvail = galAopAvail(ii,:);
    cds.(E{ii}).RXFLAGS.sbasCorrUsed = galSbasCorrUsed(ii,:);
    cds.(E{ii}).RXFLAGS.rtcmCorrUsed = galRtcmCorrUsed(ii,:);
    cds.(E{ii}).RXFLAGS.prCorrUsed = galPrCorrUsed(ii,:);
    cds.(E{ii}).RXFLAGS.crCorrUsed = galCrCorrUsed(ii,:);
    cds.(E{ii}).RXFLAGS.doCorrUsed = galDoCorrUsed(ii,:);
end

for ii = 1:numel(G)
    cds.(R{ii}).CH.L1C = gloL1C(ii,:);
    cds.(R{ii}).CH.S1C = gloS1C(ii,:);
    cds.(R{ii}).CH.D1C = gloD1C(ii,:);
    cds.(R{ii}).CH.C1C = gloC1C(ii,:);
    
    cds.(R{ii}).CH.L1CSSI = nan(size(cds.timescale));
    cds.(R{ii}).CH.C1CSSI = nan(size(cds.timescale));
    cds.(R{ii}).CH.L1LLI = nan(size(cds.timescale));
    cds.(R{ii}).CH.D1CSSI = nan(size(cds.timescale));
    
    cds.(R{ii}).RXFLAGS.locktime = gloLt(ii,:);
    cds.(R{ii}).RXFLAGS.prStdev = gloPrStdev(ii,:);
    cds.(R{ii}).RXFLAGS.cpStdev = gloCpStdev(ii,:);
    cds.(R{ii}).RXFLAGS.doStdev = gloDoStdev(ii,:);
    
    cds.(R{ii}).RXFLAGS.prValid = gloPrValid(ii,:);
    cds.(R{ii}).RXFLAGS.cpValid = gloCpValid(ii,:);
    cds.(R{ii}).RXFLAGS.halfCyc = gloHalfCyc(ii,:);
    cds.(R{ii}).RXFLAGS.subHalfCyc = gloSubHalfCyc(ii,:);
    
    cds.(R{ii}).RXFLAGS.elev = gloElev(ii,:);
    cds.(R{ii}).RXFLAGS.azim = gloAzim(ii,:);
    cds.(R{ii}).RXFLAGS.prRes = gloPrRes(ii,:);
    
    cds.(R{ii}).RXFLAGS.qualityInd = gloQualityInd(ii,:);
    cds.(R{ii}).RXFLAGS.svUsed = gloSvUsed(ii,:);
    cds.(R{ii}).RXFLAGS.health = gloHealth(ii,:);
    cds.(R{ii}).RXFLAGS.diffCorr = gloDiffCorr(ii,:);
    cds.(R{ii}).RXFLAGS.smoothed = gloSmoothed(ii,:);
    cds.(R{ii}).RXFLAGS.orbitSource = gloOrbitSource(ii,:);
    cds.(R{ii}).RXFLAGS.ephAvail = gloEphAvail(ii,:);
    cds.(R{ii}).RXFLAGS.almAvail = gloAlmAvail(ii,:);
    cds.(R{ii}).RXFLAGS.anoAvail = gloAnoAvail(ii,:);
    cds.(R{ii}).RXFLAGS.aopAvail = gloAopAvail(ii,:);
    cds.(R{ii}).RXFLAGS.sbasCorrUsed = gloSbasCorrUsed(ii,:);
    cds.(R{ii}).RXFLAGS.rtcmCorrUsed = gloRtcmCorrUsed(ii,:);
    cds.(R{ii}).RXFLAGS.prCorrUsed = gloPrCorrUsed(ii,:);
    cds.(R{ii}).RXFLAGS.crCorrUsed = gloCrCorrUsed(ii,:);
    cds.(R{ii}).RXFLAGS.doCorrUsed = gloDoCorrUsed(ii,:);

end

end