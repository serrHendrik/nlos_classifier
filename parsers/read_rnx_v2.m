%% Doxygen DOC
%> <DL>
%> <DT>HEADER:</DT> <DD> <STRONG> [H, OBSERVATIONS] = read_rnx_v2( fileobs ) </STRONG></DD>
%> 
%> <DT>DESCRIPTION:</DT> <DD>This function reads header and observations from Rinex v2 files and stores them in matrices. </DD>
%>
%> <DT>INPUT</DT> :
%>                  <DD> </DD><BR>
%>                  <DD> fileobs   = (1,n) \%s Rinex file full path </DD><BR>
%>
%> <DT>OUTPUT</DT> :
%>         <DD> </DD><BR>
%>         <DD> H = struct with header information </DD><BR>
%>         <DD> H.RINEX_VERSION_TYPE = \%cell (1,1) Rinex version e.g. '2.XX' or '3.XX'</DD><BR>
%>         <DD> H.ANTENNA        = struct with antenna data</DD><BR>
%>         <DD> H.ANTENNA.NUMBER = \%s (1,n) antenna number</DD><BR>
%>         <DD> H.ANTENNA.TYPE   = \%s (1,n) antenna type</DD><BR>
%>         <DD> H.ANTENNA.D_HEN  = \%f (3,1) DELTA H/E/N [m]</DD><BR>
%>         <DD> H.APPROX_POS       = \%f (3,1) APPROX POSITION XYZ [m] </DD><BR>
%>         <DD> H.OBSERVATION_INF   = struct with observations info</DD><BR>
%>         <DD> H.OBSERVATION_INF.OBS_TYPES = \%cell (1,3) observations types</DD><BR>
%>         <DD> H.OBSERVATION_INF.OBS_TYPES.(1) = \%s (1,1) Positioning System e.g. 'G', 'E'</DD><BR>
%>         <DD> H.OBSERVATION_INF.OBS_TYPES.(2) = \%f (1,1) Number of observations types</DD><BR>
%>         <DD> H.OBSERVATION_INF.OBS_TYPES.(3) = \%cell (n,1) observations types e.g. 'L1C', 'L2P', 'L5', etc </DD><BR>
%>         <DD> H.INTERVAL = \%f (1,1) Observation interval [sec] (e.g. '30', '1') </DD><BR>
%>         <DD> H.TIME_FIRST_OBS = %cell (1,2) Time of first observation</DD><BR>
%>         <DD> H.TIME_FIRST_OBS.(1) = \%f (6,1) Time of first observation [yyyy;mm;dd;hh;mm;ss]</DD><BR>
%>         <DD> H.TIME_FIRST_OBS.(2) = \%s (1,3) System Time e.g. 'GPS'</DD><BR>
%>         <DD> H.LEAP_SECONDS =  \%f (1,1) Leap seconds </DD><BR>
%>         <DD> H.TIME_LAST_OBS = \%cell (1,2) Time of last observation </DD><BR>
%>         <DD> H.TIME_LAST_OBS.(1) = \%f (6,1) Time of last observation [yyyy;mm;dd;hh;mm;ss]</DD><BR>
%>         <DD> H.TIME_LAST_OBS.(2) = \%s (1,3) System Time e.g. 'GPS'</DD><BR>
%>         <DD> OBSERVATIONS        = struct with observations data</DD><BR>
%>         <DD> OBSERVATIONS.(satid) = \%f (n,OBS_TYPES) observations data</DD><BR>
%> </DL>
%>
%> ISSUE 0.0 21.01.2009 \r\n
%>
%> Programmed by Beatriz.Moreno.Monge@esa.int TEC-ETN\r\n
%>

function [H, OBSERVATIONS] = read_rnx_v2(fileobs)

% This function reads header and observations from Rinex v2 files and stores them in matrices.
% 
% INPUT : fileobs   = (1,n) %s Rinex file full path
% 
% OUTPUT: H                            = {m} Header information [struct]
%          .RINEX_VERSION_TYPE         = (1,n) %s Rinex version
%          .ANTENNA.NUMBER             = (1,n) %s Antenna number
%          .ANTENNA.TYPE               = (1,n) %s Antenna type
%          .ANTENNA.D_HEN              = (3,1) %f Antenna DELTA H/E/N [m]
%          .APPROX_POS                 = (3,1) %f Approximate position XYZ [m]
%          .OBSERVATION_INF.OBS_TYPES  = (3,1) %s System, # Types, Cell with Types
%          .INTERVAL                   = (1,1) %f Observation interval [sec] (e.g. '30', '1')  
%          .TIME_FIRST_OBS             = (1,2) cell %f Time of first observation & %s Time System
%          .TIME_LAST_OBS              = (1,2) cell %f Time of last observation & %s Time System
%          .LEAP_SECONDS               = (1,1) %d Leap second
%
%
%         OBSERVATIONS                 = {m} Data [struct]
%                     .(satid)         = (n,OBS_TYPES) %f Observations data
%
% DEPENDENCIES : none
%        
% ISSUE 0.0 21.01.2009 DRAFT version under development
%
% Programmed by Beatriz.Moreno.Monge@esa.int TEC-ETN

disp( sprintf( '%s   > Reading Rinex file ...' , datestr(now) ) );

format long

%% rnx_Header_labels % read header constant values
Rv          = 'RINEX VERSION / TYPE';
RUNBY       = 'PGM / RUN BY / DATE';

M_name      = 'MARKER NAME';
M_num       = 'MARKER NUMBER';              % * optional record
M_type      = 'MARKER TYPE';

OBSERVER    = 'OBSERVER / AGENCY';
Rec         = 'REC # / TYPE / VERS';

Appos       = 'APPROX POSITION XYZ';

AntID       = 'ANT # / TYPE';
AntH        = 'ANTENNA: DELTA H/E/N';
AntDX       = 'ANTENNA: DELTA X/Y/Z';       % * optional record
AntPCpos    = 'ANTENNA: PHASECENTER';       % * optional record
AntBS       = 'ANTENNA: B.SIGHT XYZ';       % * optional record
AntAz       = 'ANTENNA: ZERODIR AZI';       % * optional record
AntXYZ      = 'ANTENNA: ZERODIR XYZ';       % * optional record

CenMass     = 'CENTER OF MASS: XYZ';        % * optional record

Obs_types_3 = 'SYS / # / OBS TYPES';        

SSU         = 'SIGNAL STRENGTH UNIT';       % * optional record

Int         = 'INTERVAL';                   % * optional record

ToF         = 'TIME OF FIRST OBS';
ToL         = 'TIME OF LAST OBS';           % * optional record

RCV_CLK_OFF = 'RCV CLOCK OFFS APPL';        % * optional record
DCBs        = 'SYS / DCBS APPLIED';         % * optional record
PCVs        = 'SYS / PCVS APPLIED';         % * optional record

SCALE_FACTOR= 'SYS / SCALE FACTOR';         % * optional record

LEAP_SECONDS= 'LEAP SECONDS';               % * optional record

NUM_SAT     = '# OF SATELLITES';            % * optional record
PRN_NUM_OBS = 'PRN / # OF OBS';             % * optional record

EoH         = 'END OF HEADER';
COM         = 'COMMENT';                    % * optional record

% Different labels in versions 2   2.10 2.11 
Obs_types_2 = '# / TYPES OF OBSERV';        
WlenF       = 'WAVELENGTH FACT L1/2';       % * optional record

%% initialize
ObsEpoc.num     = 0;
ObsEpoc.fst     = [];
ObsEpoc.step    = [];
obs_types_counter = 0;

fid = fopen(fileobs,'r');

%% 1. READ HEADER
while 1
   
    A=fgetl(fid);
    
    % rinex version
    if (strfind(A,Rv)> 0), version = sscanf(A(1:10) ,'%f'); end
    
    % check end of Header
    if (strfind(A,'END OF HEADER') > 0) break, end

    % get a priori coordinates of the station
    % [ * optional for moving platforms ]
    if (strfind(A,Appos) > 0),   H.APPROX_POS  = sscanf(A,'%14f',3); continue, end % [m] ITRS recommended
 
    % ANTENNA INF
    % extract information about ANTENNA
    if (strfind(A,AntID)> 0)
        H.ANTENNA.NUMBER  = sscanf(A(1:20) ,'%s'); % Ant Number
        H.ANTENNA.TYPE    = A(21:40);%sscanf(A(21:40),'%s'); % Ant Type
        continue
    end
    if (strfind(A,AntH) > 0),   H.ANTENNA.D_HEN   = sscanf(A,'%14f',3)  ; continue, end % (Antenna Height, Horizontal Eccentricity of ARP)[m]
    
    % RECEIVER
    if (strfind(A,Rec)> 0)
        H.RECEIVER.NUMBER  = sscanf(A(1:20) ,'%s'); % Ant Number
        H.RECEIVER.TYPE    = A(21:40);%sscanf(A(21:40),'%s'); % Ant Type
        H.RECEIVER.VERSION = A(41:60);
        continue
    end
    
    % get information about observables
    if ~isempty(strfind(A,Obs_types_2))
        SatSys = A(1);                                              % Satellite Systems : G R 
        if strcmp(SatSys,' '), SatSys = 'G'; end
        
        obs_types_counter    = obs_types_counter +1;              
        H.OBSERVATION_INF.OBS_TYPES {obs_types_counter,1} = SatSys;
        H.OBSERVATION_INF.OBS_TYPES {obs_types_counter,2} = str2double(A(5:6));% # obs types
        nobst                = str2double(A(5:6));
        obs_typ              = A(7:60);
        
      % If more than 9 observation types, use continuation line(s)   
        while (nobst > 9)              
            A = fgetl(fid);                         
            obs_typ = strcat(obs_typ,A(7:60));
            nobst = nobst - 9;
        end
        cell_aux = textscan(obs_typ,'%s');  
        H.OBSERVATION_INF.OBS_TYPES {obs_types_counter,3} = cell_aux{1}; % obs types
        
        % adapt to rinex 3.00 observables names
        for k=1: H.OBSERVATION_INF.OBS_TYPES{1,2}
            switch H.OBSERVATION_INF.OBS_TYPES{1,3}{k},
                case 'L1',
                    H.OBSERVATION_INF.OBS_TYPES{1,3}{k} = 'L1C';
                case 'L2',
                    H.OBSERVATION_INF.OBS_TYPES{1,3}{k} = 'L2P';
                case 'C1',
                    H.OBSERVATION_INF.OBS_TYPES{1,3}{k} = 'C1C';
                case 'P2',
                    H.OBSERVATION_INF.OBS_TYPES{1,3}{k} = 'C2P';
                case 'P1',
                    H.OBSERVATION_INF.OBS_TYPES{1,3}{k} = 'C1P';
                case 'L5',
                    H.OBSERVATION_INF.OBS_TYPES{1,3}{k} = 'L5Q';
                case 'C5',
                    H.OBSERVATION_INF.OBS_TYPES{1,3}{k} = 'C5Q';
                case 'L7',
                    H.OBSERVATION_INF.OBS_TYPES{1,3}{k} = 'L7Q';
                case 'C7',
                    H.OBSERVATION_INF.OBS_TYPES{1,3}{k} = 'C7Q';
                case 'L8',
                    H.OBSERVATION_INF.OBS_TYPES{1,3}{k} = 'L8Q';
                case 'C8',
                    H.OBSERVATION_INF.OBS_TYPES{1,3}{k} = 'C8Q';
            end
        end
        continue
           
    end

  % get time of first observation & Time System
    if (strfind(A,ToF  ) > 0)
        H.TIME_FIRST_OBS{1} = sscanf(A(1:45) ,'%f',6); % epoch
        H.TIME_FIRST_OBS{2} = sscanf(A(46:60),'%s',1); % Time system GPS GAL
        continue
    end
    % get time of last observation & Time System
    % [ * optional record ]
    if (strfind(A,ToL  ) > 0),                          
        H.TIME_LAST_OBS{1} = sscanf(A(1:45) ,'%f',6); 
        H.TIME_LAST_OBS{2} = sscanf(A(46:60),'%s',1); 
        continue
    end
    
     % get observation interval
     % [ * optional record ]
    if (strfind(A,Int  ) > 0), H.INTERVAL = sscanf(A(1:10),'%f',1); continue, end 
    
    % get number of Leap Seconds since 6-Jan-1980 
    % [ * optional record ]
    if (strfind(A,LEAP_SECONDS) > 0), H.LEAP_SECONDS = sscanf(A(1:60),'%d',1); continue, end

end


%  2. READ OBSERVATIONS

t = 0;
        
while ~feof(fid)
   % read next line
   A=fgetl(fid);
   
try
   % Check epoch flag
   eflag = str2double(A(29));
   if eflag == 4, % header info follows
       COMMlines = str2double(A(31:32));
       for ind_commlines = 1: COMMlines+1, A=fgetl(fid); end
%        while ~isempty(strfind(A,'COMMENT')), A=fgetl(fid); end
   end
   
   % get observation epoch and work out gps time
   epoch = sscanf(A(2:26),'%f'); % [yy mm dd hh min ss]
   if epoch(1)<90, epoch(1)= 2000+epoch(1);
   else epoch(1)= 1900 + epoch(1);
   end
   epoch(6) = round(epoch(6));
   
   epochsec = floor((datenum(epoch(1),epoch(2),epoch(3))*86400 + epoch(4)*60*60 + epoch(5)*60 + epoch(6)));
   
   % increase number of observations
   ObsEpoc.num = ObsEpoc.num +1;
   t = t + 1;
   
   
   % CHECK IF OBSERVATION EPOCHS ARE MISSING
   if isempty(ObsEpoc.fst), 
       
       ObsEpoc.fst = epoch;
       firstsec = floor((datenum(ObsEpoc.fst(1),ObsEpoc.fst(2),ObsEpoc.fst(3))*86400 + ObsEpoc.fst(4)*60*60 + ObsEpoc.fst(5)*60 + ObsEpoc.fst(6)));
       currepo = epochsec; % current epoch in seconds
       
   elseif isempty(ObsEpoc.step) 
       
       if isfield(H,'INTERVAL')
           ObsEpoc.step = H.INTERVAL ;
       else
           ObsEpoc.step = epochsec - firstsec; 
       end
        
       currepo = firstsec + ObsEpoc.step * (ObsEpoc.num - 1); % seconds
       
   else              
       
       currepo = firstsec + ObsEpoc.step * (ObsEpoc.num - 1); 
       
   end

    % if observations are missing increase the index
   if currepo ~= epochsec % epochs are missing
       
       numepo = (epochsec-currepo) / ObsEpoc.step;
       % increase number of observations
       ObsEpoc.num = ObsEpoc.num + numepo;
       t = t + numepo;
       
   end

   % # observed satellites in CURRENT epoch
   num_sat  = str2double(A(31:32)); 
   clear ObsSat
   % observed satellites && Receiver Clock Offset [optional record]
   if length(A) > 70
       ObsSat = sscanf(A(33:69),'%c'); 
       OBSERVATIONS.RecCLKOFF(t,1) = str2double(A(70:end));
   else
       ObsSat = A(33:end);
   end
   nsat_aux = num_sat -12;
   while nsat_aux > 0   % if more than 12 satellites use continuation lines
       A=fgetl(fid);    % read next line
       ObsSat = [ObsSat,  sscanf(A(33:end),'%c')];
       nsat_aux = nsat_aux - 12;
   end

   % write observations in matrix
   N_typ = H.OBSERVATION_INF.OBS_TYPES {1,2};
   for j = 1: num_sat
       
       satid = ObsSat(j*3-2:3*j);
       if strcmp(satid(1),' '), satid(1) = 'G'; end
       satid = strrep(satid,' ','0');

       % read observations
       B = '';      
       n_typ_aux = N_typ;
       while  n_typ_aux > 0, 
           line1 = fgetl(fid);
           line1(end + 1: 5 * 16) = blanks((5 * 16) - length(line1));
           B     = [B, line1];        
           n_typ_aux = n_typ_aux - 5;
           
       end
       B_end = length(B); % fill in with blanks if neccessary
       B(end + 1: N_typ * 16) = blanks((N_typ * 16) - B_end);
       
       i = 1; % i = column number in OBSERVATIONS
       for k = 1: 16: N_typ * 16
           obs = str2double(B(k:k+13));
           lli = str2double(B(k+14));
           ssi = str2double(B(k+15));
           if isempty(obs) || (obs == 0.0), obs = NaN; end % missing obs
           if (lli == 0), lli = NaN; end % missing obs
           if (ssi == 0), ssi = NaN; end % missing obs

 %                 Obs.G01.L1 = [ ...; ... ]
           OBSERVATIONS.(satid){t,i}   = obs;
           OBSERVATIONS.(satid){t,i+1} = lli;
           OBSERVATIONS.(satid){t,i+2} = ssi;
           i =i + 3;

       end
   end
catch
    disp(' error reading rinex v2 file ');
end
end

% 3. TRANSFORM OBSERVATIONS FROM CELL TO MATRIX
SatList = fields(OBSERVATIONS);
SatList = SatList( ~strcmp(SatList,'RecCLKOFF') );

for n_sat = 1: length( SatList )
    
    satid  = SatList{ n_sat };
   
    % find non-empty fields in variable
    pos 		= find	( cellfun( 'isempty',OBSERVATIONS.(satid) ) == 0 );
    % create an auxiliar matrix of NaN. Imp: same dimensions as OBSERVATIONS.(satid)
    OBS 		= zeros	( size(OBSERVATIONS.(satid)) )*NaN;
    % load data in matrix
    OBS(pos)	= cell2mat	( OBSERVATIONS.(satid) );

    OBSERVATIONS.(satid) = cat(1, OBS, zeros( [ObsEpoc.num - size(OBSERVATIONS.(satid),1), size(OBSERVATIONS.(satid),2) ] )*NaN );
     
end

% 4. CHECK AND COMPLETE INFO
if isempty(H.TIME_FIRST_OBS{1}),   
    H.TIME_FIRST_OBS{1} = ObsEpoc.fst; 
elseif datenum(H.TIME_FIRST_OBS{1}') ~= datenum( ObsEpoc.fst' )
    warning('TIME of FIRST OBSERVATION in file not consistent with header information');
    H.TIME_FIRST_OBS{1} = ObsEpoc.fst;
end
if ~isfield(H,'TIME_LAST_OBS'),    
    H.TIME_LAST_OBS{1} = epoch'; %ObsEpoc.fst + datevec( ((ObsEpoc.num-1) * ObsEpoc.step)/86400 )'; 
    H.TIME_LAST_OBS{2} = H.TIME_FIRST_OBS{2};
elseif datenum( H.TIME_LAST_OBS{1}' ) ~= datenum( ObsEpoc.fst' + datevec( ((ObsEpoc.num-1) * ObsEpoc.step)/86400 ) )
    warning('TIME of LAST OBSERVATION in file not consistent with header information');
    H.TIME_LAST_OBS{1} = ObsEpoc.fst + datevec( ((ObsEpoc.num-1) * ObsEpoc.step)/86400 )';
    H.TIME_LAST_OBS{2} = H.TIME_FIRST_OBS{2};
end
if ~isfield(H,'INTERVAL'), H.INTERVAL = ObsEpoc.step; end
if strcmp( H.ANTENNA.TYPE(17:20), blanks(4) ), H.ANTENNA.TYPE(17:20) = 'NONE'; end 
fclose(fid);