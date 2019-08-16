%% Doxygen DOC
%> <DL>
%> <DT>HEADER:</DT> <DD> <STRONG> [H,OBSERVATIONS] = read_rnx( fileobs ) </STRONG></DD>
%> 
%> <DT>DESCRIPTION:</DT> <DD>This function reads header and observations from Rinex v3 files and stores them in matrices. </DD>
%>
%> <DT>INPUT</DT> :
%>                  <DD> </DD><BR>
%>                  <DD> fileobs   = (1,n) \%s Rinex file full path </DD><BR>
%>
%> <DT>OUTPUT</DT> :
%>         <DD> </DD><BR>
%>         <DD> H = struct with header information </DD><BR>
%>         <DD> H.RINEX_VERSION_TYPE = \%cell (1,3) Rinex version ( f. ex : {'3.00' 'O'  'M'} ) </DD><BR>
%>         <DD> H.RINEX_VERSION_TYPE.{1} = \%s (1,4) Rinex file version </DD><BR>
%>         <DD> H.RINEX_VERSION_TYPE.{2} = \%s (1,1) File Type </DD><BR>
%>         <DD> H.RINEX_VERSION_TYPE.{3} = \%s (1,1) Observed Satellite system </DD><BR>
%>         <DD> H.PGM_RUNBY_DATE = \%cell (1,5) Program, run by, date ( f. ex : {'S2R' 'ROOT'  '20070530'  '010840'  'UTC'} ) </DD><BR>
%>         <DD> H.PGM_RUNBY_DATE.{1} = \%s (1,n) Program creating file </DD><BR>
%>         <DD> H.PGM_RUNBY_DATE.{2} = \%s (1,n) Agency creating file </DD><BR>
%>         <DD> H.PGM_RUNBY_DATE.{3} = \%s (1,8) DATE of creation </DD><BR>
%>         <DD> H.PGM_RUNBY_DATE.{4} = \%s (1,6) Time of creation </DD><BR>
%>         <DD> H.PGM_RUNBY_DATE.{5} = \%s (1,n) Time zone </DD><BR>
%>         <DD> H.MARKER = \%cell (1,3) Marker ( f. ex: {''  '' 'NONE'} ) </DD><BR>
%>         <DD> H.MARKER.{1} = \%s (1,n) Marker name </DD><BR>
%>         <DD> H.MARKER.{2} = \%s (1,n) Marker number </DD><BR>
%>         <DD> H.MARKER.{3} = \%s (1,n) Marker type </DD><BR>
%>         <DD> H.OBSERVER_AGENCY = \%cell (1,2) Observer Agency ( f. ex: {'DSF_GSTBv2'  'ESA'} ) </DD><BR>
%>         <DD> H.OBSERVER_AGENCY.{1} = \%s (1,n) Observer </DD><BR>
%>         <DD> H.OBSERVER_AGENCY.{2} = \%s (1,n) Agency </DD><BR>
%>         <DD> H.RECEIVER = \%cell (1,3) Receiver ( f. ex: {'' 'GETR'  ''} ) </DD><BR>
%>         <DD> H.RECEIVER.{1} = \%s (1,n) Receiver number </DD><BR>
%>         <DD> H.RECEIVER.{2} = \%s (1,n) Receiver type </DD><BR>
%>         <DD> H.RECEIVER.{3} = \%s (1,n) Receiver version </DD><BR>
%>         <DD> H.ANTENNA        = struct with antenna data</DD><BR>
%>         <DD> H.ANTENNA.NUMBER = \%s (1,n) antenna number</DD><BR>
%>         <DD> H.ANTENNA.TYPE   = \%s (1,n) antenna type</DD><BR>
%>         <DD> H.ANTENNA.D_HEN  = \%f (3,1) Antenna Height, Horizontal Eccentricity of ARP [m] </DD><BR>
%>         <DD> H.ANTENNA.D_XYZ  = \%f (3,1) Position of antenna ref. point for antenna on vehicle </DD><BR>
%>         <DD> H.ANTENNA.PHASE_CENTER_POS  = \%cell (3,1) Phase Center </DD><BR>
%>         <DD> H.ANTENNA.PHASE_CENTER_POS.{j,1}  = \%s (n,1) Satellite System </DD><BR>
%>         <DD> H.ANTENNA.PHASE_CENTER_POS.{j,2}  = \%s (n,1) Observable code </DD><BR>
%>         <DD> H.ANTENNA.PHASE_CENTER_POS.{j,3}  = \%f (n,1) Average phase centre pos [m] </DD><BR>
%>         <DD> H.ANTENNA.BSIGHT  = \%f (3,1) direction of the vertical antenna axis towards sat (unit vector) </DD><BR>
%>         <DD> H.ANTENNA.AZI0  = \%f (1,1) Azimut of the zero direction  (degrees from North)  </DD><BR>
%>         <DD> H.ANTENNA.XYZ0  = \%f (3,1) Zero-direction of the antenna (unit vector) </DD><BR>
%>         <DD> H.APPROX_POS       = \%f (3,1) Geocentric approximate marker position [m] ITRS recommended </DD><BR>
%>         <DD> H.CENTER_MASS = \%f (1,3) Current centre of mass of vehicle [m]</DD><BR>
%>         <DD> H.SIG_STRENGTH_UNIT   = \%f (1,1) Unit of the signal strength [DBHZ] </DD><BR>
%>         <DD> H.INTERVAL = \%f (1,1) Observation interval [sec] (e.g. '30', '1') </DD><BR>
%>         <DD> H.TIME_FIRST_OBS = %cell (1,2) Time of first observation</DD><BR>
%>         <DD> H.TIME_FIRST_OBS.(1) = \%f (6,1) Time of first observation [yyyy mm dd hh mm ss]</DD><BR>
%>         <DD> H.TIME_FIRST_OBS.(2) = \%s (1,3) System Time e.g. 'GPS'</DD><BR>
%>         <DD> H.TIME_LAST_OBS = \%cell (1,2) Time of last observation </DD><BR>
%>         <DD> H.TIME_LAST_OBS.(1) = \%f (6,1) Time of last observation [yyyy mm dd hh mm ss]</DD><BR>
%>         <DD> H.TIME_LAST_OBS.(2) = \%s (1,3) System Time e.g. 'GPS'</DD><BR>
%>         <DD> H.OBSERVATION_INF   = struct with observations info</DD><BR>
%>         <DD> H.OBSERVATION_INF.OBS_TYPES = \%cell (1,3) observations types</DD><BR>
%>         <DD> H.OBSERVATION_INF.OBS_TYPES.(j,1) = \%s (1,1) Positioning System [ G (= GPS) R (= GLONASS) E (= Galileo) S (= SBAS)]</DD><BR>
%>         <DD> H.OBSERVATION_INF.OBS_TYPES.(j,2) = \%f (1,1) Number of observations types</DD><BR>
%>         <DD> H.OBSERVATION_INF.OBS_TYPES.(j,3) = \%cell (n,1) Observations types e.g. 'L1C', 'L2P', 'L5', etc </DD><BR>
%>         <DD> H.OBSERVATION_INF.DCBs = \%cell (1,3) Differential code bias corrections </DD><BR>
%>         <DD> H.OBSERVATION_INF.DCBs.(j,1) = \%s (1,1) Positioning System [ G (= GPS) R (= GLONASS) E (= Galileo) S (= SBAS)]</DD><BR>
%>         <DD> H.OBSERVATION_INF.DCBs.(j,2) = \%s (n,1) Program used to apply the corrections </DD><BR>
%>         <DD> H.OBSERVATION_INF.DCBs.(j,3) = \%s (n,1) Source of corrections ( URL ) </DD><BR>
%>         <DD> H.OBSERVATION_INF.PCVs = \%cell (1,3) Phase centre variation corrections </DD><BR>
%>         <DD> H.OBSERVATION_INF.PCVs.(j,1) = \%s (1,1) Positioning System [ G (= GPS) R (= GLONASS) E (= Galileo) S (= SBAS)]</DD><BR>
%>         <DD> H.OBSERVATION_INF.PCVs.(j,2) = \%s (n,1) Program used to apply the corrections </DD><BR>
%>         <DD> H.OBSERVATION_INF.PCVs.(j,3) = \%s (n,1) Source of corrections ( URL ) </DD><BR>
%>         <DD> H.OBSERVATION_INF.SCALE_FACTOR = \%cell (1,4) Factor to divide stored OBSERVATION_INF with </DD><BR>
%>         <DD> H.OBSERVATION_INF.SCALE_FACTOR.(j,1) = \%s (1,1) Positioning System [ G (= GPS) R (= GLONASS) E (= Galileo) S (= SBAS)]</DD><BR>
%>         <DD> H.OBSERVATION_INF.SCALE_FACTOR.(j,2) = \%s (n,1) Factor </DD><BR>
%>         <DD> H.OBSERVATION_INF.SCALE_FACTOR.(j,3) = \%s (n,1) Number of observation types involved</DD><BR>
%>         <DD> H.OBSERVATION_INF.SCALE_FACTOR.(j,4) = \%s (n,1) List of obs types </DD><BR>
%>         <DD> H.OBSERVATION_INF.PRN_NUM_OBS = \%cell (1,3) Factor to divide stored OBSERVATION_INF with </DD><BR>
%>         <DD> H.OBSERVATION_INF.SCALE_FACTOR.(j,1) = \%s (1,1) Positioning System [ G (= GPS) R (= GLONASS) E (= Galileo) S (= SBAS)]</DD><BR>
%>         <DD> H.OBSERVATION_INF.SCALE_FACTOR.(j,2) = \%s (n,1) Satellite ID ( p. ex : 'G01' ) </DD><BR>
%>         <DD> H.OBSERVATION_INF.SCALE_FACTOR.(j,3) = \%s (n,1) Number of observations for each obs type</DD><BR>
%>         <DD> H.RCV_CLK_OFF =  \%f (1,1) Receiver clock offset applied: 1=yes 0=no; default: 0 </DD><BR>
%>         <DD> H.LEAP_SECONDS =  \%f (1,1) Leap seconds since 6-Jan-1980 as transmitted by GPS almanac</DD><BR>
%>         <DD> H.NUM_OBS_SAT =  \%f (1,1) Number of sat, for which observations are stored </DD><BR>
%>         <DD> OBSERVATIONS        = struct with observations data</DD><BR>
%>         <DD> OBSERVATIONS.(satid) = \%f (n,OBS_TYPES) matrix with the observations taken from rinex</DD><BR>
%>         <DD> CYCLESLIPS        = struct with observations data</DD><BR>
%>         <DD> CYCLESLIPS.(satid) = \%f (n,OBS_TYPES) matrix with detected and repaired cycle slips taken from rinex</DD><BR>
%> </DL>
%>
%> ISSUE 0.0 14.11.2008 \r\n
%>           26.06.2012 DPAF V2 \r\n
%>
%> Programmed by Beatriz.Moreno.Monge@esa.int TEC-ETN\r\n
%> Programmed by   Francisco.Gonzalez@esa.int TEC-ETN\r\n
%> Programmed by     Gaetano.Galluzzo@esa.int  TGVF Project

function [H,OBSERVATIONS] = read_rnx(fileobs)

% This function reads header and observations from Rinex v3 files and stores them in matrices.
% 
% INPUT : fileobs   = (1,n) %s Rinex file full path
% 
% OUTPUT: H         = {m} Header information [struct]
% HEADER INFORMATION
% -------------------------------------------------------------------------------------------------
% H = 
% 
%     RINEX_VERSION_TYPE: {1} Rinex file version  
%                         {2} File Type  
%                         {3} Observed Satellite system  ( f. ex : {'3.00' 'O'  'M'} )
%     PGM_RUNBY_DATE: 
%                         {1} Program creating file 
%                         {2} Agency creating file
%                         {3} DATE of creation
%                         {4} time of creation
%                         {5} Time zone                  ( f. ex : {'S2R' 'ROOT'  '20070530'  '010840'  'UTC'} )
%     MARKER: 
%                         {1} % Marker name
%                         {2} % Marker number
%                         {3} % Marker type              ( f. ex: {''  '' 'NONE'} )
%     OBSERVER_AGENCY: 
%                         {1} % Observer
%                         {2} % Agency                   ( f. ex: {'DSF_GSTBv2'  'ESA'} )
%     RECEIVER: 
%                         {1} Rec Number
%                         {2} Rec Type
%                         {3} Rec version                ( f. ex: {'' 'GETR'  ''} )
%     ANTENNA:                                           
%                         .NUMBER : Number of antenna
%                         .TYPE   : Type of antenna
%                         .D_HEN  : Antenna Height, Horizontal Eccentricity of ARP [m]
%                         .D_XYZ  : Position of antenna ref. point for antenna on vehicle
%                         .PHASE_CENTER_POS:                    
%                                        {j,1} Satellite System
%                                        {j,2} Observable code
%                                        {j,3} Average phase centre pos [m]
%                         .BSIGHT : direction of the vertical antenna axis towards sat (unit vector)
%                         .AZI0   : Azimut of the zero direction  (degrees from North) 
%                         .XYZ0   : Zero-direction of the antenna (unit vector)
% 
%     APPROX_POS:         Geocentric approximate marker position [m] ITRS recommended
%     CENTER_MASS:        Current centre of mass of vehicle [m]
%     SIG_STRENGTH_UNIT:  Unit of the signal strength'DBHZ'
%     INTERVAL:           Observation interval [s]
%     TIME_FIRST_OBS:     {1} Time of first observation record [yyyy mm dd hh mm ss]
%                         {2} Time system ( : GPS GLO GAL ) 
%     TIME_LAST_OBS:      {1} Time of last observation record [yyyy mm dd hh mm ss]
%                         {2} Time system ( same value as in first obs ) 
%     OBSERVATION_INF: 
%                         .OBS_TYPES:
%                                      {j,1} SatSys [ G (= GPS) R (= GLONASS) E (= Galileo) S (= SBAS)]
%                                      {j,2} # obs types
%                                      {j,3} obs types
%                         .DCBs: Differential code bias corrections
%                                      {j,1} SatSys 
%                                      {j,2} Program used to apply the corrections 
%                                      {j,3} Source of corrections ( URL )
%                         .PCVs: Phase centre variation corrections
%                                      {j,1} SatSys 
%                                      {j,2} Program used to apply the corrections 
%                                      {j,3} Source of corrections ( URL )
%                         .SCALE_FACTOR: Factor to divide stored OBSERVATION_INF with
%                                      {j,1} SatSys 
%                                      {j,2} Factor 
%                                      {j,3} number of observation types involved
%                                      {j,4} list of obs types
%                         .PRN_NUM_OBS: Number of observations for each obs type
%                                      {j,1} SatSys 
%                                      {j,2} Satellite ID ( p. ex : 'G01' ) 
%                                      {j,3} number of observations for each obs type
%     RCV_CLK_OFF: Receiver clock offset applied: 1=yes 0=no; default: 0
%     LEAP_SECONDS: Number of Leap Seconds since 6-Jan-1980 as transmitted by GPS almanac
%     NUM_OBS_SAT: Number of sat, for which observations are stored 
%     COMMENTS:
%                           '                                                            '
%                           '     " NOTE : DO NOT USE TAB IN RINEX HEADER ! "            '
%                           '
% -------------------------------------------------------------------------------------------------
% OBSERVATIONS AND CYCLESLIPS
% 
% OBSERVATIONS 
%             .SatID:   matrix with the observations taken from rinex
% 
% CYCLESLIPS
%           .SatID:   matrix with detected and repaired cycle slips taken from rinex
%
%-------------------------------------------------------------------------------------------------
%
% DEPENDENCIES :  none
%
% e.g. fileobs = 'gien150_short.txt';
%
% ISSUE 0.0 14.11.2008
% Programmed by Beatriz.Moreno.Monge@esa.int TEC-ETN
% Programmed by   Francisco.Gonzalez@esa.int TEC-ETN
% ISSUE DPAF V2 26.06.2012
% Programmed by Gaetano.Galluzzo@esa.int  TGVF Project


disp( sprintf( '%s   > Reading Rinex file ...' , datestr(now) ) );

format long

file = fopen(fileobs);

%% rnx_Header_labels
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

%% INITIALIZATION OF AUXILIAR VARIABLES

pos_counter       = 0;
scale_counter     = 0;
num_obs_counter   = 0;
obs_types_counter = 0;

obs_inf_counter.G = 0;
obs_inf_counter.R = 0;
obs_inf_counter.E = 0;
obs_inf_counter.S = 0;

dcbs_counter      = 0;
pcvs_counter      = 0;
comment_counter   = 0;

%% 1. READ HEADER
while 1
   
    A=fgetl(file);
    
    % check end of Header
    if (strfind(A,EoH ) > 0) break, end
    
    % get rinex version and file creation inf
    if (strfind(A,Rv  )     > 0)
        H.RINEX_VERSION_TYPE{1} = A(6:9);   % Rinex file version [ 3.00 ]
        H.RINEX_VERSION_TYPE{2} = A(21);    % File type [ O for observation data ]
        H.RINEX_VERSION_TYPE{3} = A(41);    % Observed Satellite system
        continue
    end
    if (strfind(A,RUNBY) > 0)
        H.PGM_RUNBY_DATE{1} = sscanf(A(1:20) ,'%s',1); % Program creating file 
        H.PGM_RUNBY_DATE{2} = sscanf(A(21:40),'%s',1); % Agency creating file
        H.PGM_RUNBY_DATE{3} = sscanf(A(41:48),'%s',1); % DATE of creation
        H.PGM_RUNBY_DATE{4} = sscanf(A(50:55),'%s',1); % time of creation
        H.PGM_RUNBY_DATE{5} = sscanf(A(56:60),'%s',1); % Time zone
        continue
    end 
    
    % get MARKER information
    if (strfind(A,M_name)   > 0), H.MARKER{1} = sscanf(A(1:60),'%s'); continue, end % Marker name
    if (strfind(A,M_num )   > 0), H.MARKER{2} = sscanf(A(1:20),'%s'); continue, end % Marker number [ * optional record ]
    if (strfind(A,M_type)   > 0), H.MARKER{3} = sscanf(A(1:20),'%s'); continue, end % Marker type
    
    % get observer inf
    if (strfind(A,OBSERVER)   > 0)
        H.OBSERVER_AGENCY{1} = strrep(strtrim(A(1:20)),' ','_'); % Observer
        H.OBSERVER_AGENCY{2} = sscanf(A(21:40),'%s');            % Agency
        continue
    end
    
    % extract information about RECEIVER
    if (strfind(A,Rec ) > 0)
        H.RECEIVER{1} = sscanf(A(1:20) ,'%s'); % Rec Number
        H.RECEIVER{2} = sscanf(A(21:40),'%s'); % Rec Type
        H.RECEIVER{3} = sscanf(A(41:60),'%s'); % Rec version
        continue
    end
    
    % extract information about ANTENNA
    if (strfind(A,AntID)> 0)
        H.ANTENNA.NUMBER  = sscanf(A(1:20) ,'%s'); % Ant Number
        H.ANTENNA.TYPE    = A(21:40); % Ant Type
        continue
    end
    if (strfind(A,AntH) > 0),   H.ANTENNA.D_HEN   = sscanf(A,'%14f',3)  ; continue, end % (Antenna Height, Horizontal Eccentricity of ARP)[m] 
    % [ * optional records ] -----
    if (strfind(A,AntDX)> 0),   H.ANTENNA.D_XYZ   = sscanf(A,'%14f',3)  ; continue, end % [m] 
    if (strfind(A,AntPCpos)> 0)                                           
        SatSys = A(1);                                                                 % Satellite System : G R E S
        pos_counter = pos_counter + 1;
        H.ANTENNA.PHASE_CENTER_POS{ pos_counter,1 } = SatSys;                          % Satellite System 
        H.ANTENNA.PHASE_CENTER_POS{ pos_counter,2 } = sscanf(A(2:5) ,'%s',1);          % Observation code
        H.ANTENNA.PHASE_CENTER_POS{ pos_counter,3 } = sscanf(A(6:60),'%9f%14f%14f',3); % Average phase centre pos % [m]
        continue
    end
    if (strfind(A,AntBS) > 0),   H.ANTENNA.BSIGHT   = sscanf(A,'%14f',3)  ; continue, end % unit vector    
    if (strfind(A,AntAz) > 0),   H.ANTENNA.AZI0     = sscanf(A,'%14f',1)  ; continue, end % degrees from North 
    if (strfind(A,AntXYZ)> 0),   H.ANTENNA.XYZ0     = sscanf(A,'%14f',3)  ; continue, end % unit vector 
    % ----------------------------
    
    % get centre of mass
    % [ * optional record ]
    if (strfind(A,CenMass)> 0),  H.CENTER_MASS = sscanf(A,'%14f',3); continue, end % [m]  
       
    % get a priori coordinates of the station
    % [ * optional for moving platforms ]
    if (strfind(A,Appos) > 0),   H.APPROX_POS  = sscanf(A,'%14f',3); continue, end % [m] ITRS recommended
    
    % get observables information        
    if ~isempty(strfind(A,Obs_types_3))
        SatSys = A(1);                                              % Satellite Systems : G R E S
        
        obs_types_counter    = obs_types_counter +1;              
        H.OBSERVATION_INF.OBS_TYPES {obs_types_counter,1} = SatSys;
        H.OBSERVATION_INF.OBS_TYPES {obs_types_counter,2} = str2double(A(5:6));% # obs types
        nobst                = str2double(A(5:6));
        obs_typ              = A(7:60);
        
      % If more than 13 observation types, use continuation line(s)   
        while (nobst > 13)              
            A = fgetl(file);                         
            obs_typ = strcat(obs_typ,A(7:60));
            nobst = nobst - 13;
        end
        cell_aux = textscan(obs_typ,'%s');  
        H.OBSERVATION_INF.OBS_TYPES {obs_types_counter,3} = cell_aux{1}; % obs types
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
    
    % get clock offsets applied
    % [ * optional record ]
    if (strfind(A,RCV_CLK_OFF) > 0), H.RCV_CLK_OFF = sscanf(A(1:60),'%d',1); continue, end 
    
    % get Differential Code Bias Corrections applied
    % [ * optional record ]
    if (strfind(A,DCBs ) > 0) 
        SatSys = A(1);                                             % Satellite Systems : G R E S
        dcbs_counter = dcbs_counter +1;
        H.OBSERVATION_INF.DCBs{dcbs_counter,1} = SatSys;
        H.OBSERVATION_INF.DCBs{dcbs_counter,2} = sscanf(A(2:20) ,'%s',1); % Software used
        H.OBSERVATION_INF.DCBs{dcbs_counter,3} = sscanf(A(21:60),'%s',1); % URL
        continue
    end
    
    % get Phase Centre Variation corrections applied
    % [ * optional record ]
    if (strfind(A,PCVs ) > 0) 
        SatSys = A(1);                                             % Satellite Systems : G R E S
        pcvs_counter = pcvs_counter+1;
        H.OBSERVATION_INF.PCVs{pcvs_counter,1} = SatSys;
        H.OBSERVATION_INF.PCVs{pcvs_counter,2} = sscanf(A(2:20) ,'%s',1); % Software used
        H.OBSERVATION_INF.PCVs{pcvs_counter,3} = sscanf(A(20:60),'%s',1); % URL
        continue
    end
    
    % get Scale Factor
    % [ * optional record ]
    if (strfind(A,SCALE_FACTOR) > 0) 
        SatSys = A(1);                                                                            % Satellite Systems : G R E S
        scale_counter = scale_counter + 1;
        
        H.OBSERVATION_INF.SCALE_FACTOR{scale_counter,1 } = SatSys; % Sat sys
        H.OBSERVATION_INF.SCALE_FACTOR{scale_counter,2 } = sscanf(A(2:6 ),'%d',1); % Scale Factor
        H.OBSERVATION_INF.SCALE_FACTOR{scale_counter,3 } = sscanf(A(7:10),'%d',1);% num of obs types
        
        num_obs_typ_inv = sscanf(A(7:10),'%d',1);
        list_obs_typ    = A(11:60);
        
        while num_obs_typ_inv > 12
            A = fgetl(file);
            list_obs_typ    = strcat(list_obs_typ, A(11:60));
            num_obs_typ_inv = num_obs_typ_inv -12;
        end
        % obs types
        scale_aux = textscan(list_obs_typ,'%s'); 
        H.OBSERVATION_INF.SCALE_FACTOR{scale_counter,4 } = scale_aux{1};
        continue
    end
    
    % get number of Leap Seconds since 6-Jan-1980 
    % [ * optional record ]
    if (strfind(A,LEAP_SECONDS) > 0), H.LEAP_SECONDS = sscanf(A(1:60),'%d',1); continue, end
    
    % get number of sat for which obs are stored in the file
    % [ * optional record ]
    if (strfind(A,NUM_SAT     ) > 0), H.NUM_OBS_SAT  = sscanf(A(1:60),'%d',1); continue, end 
    
    % get PRN and number of obs for each obs type
    % [ * optional record ]
    if (strfind(A,PRN_NUM_OBS ) > 0) 
        SatSys = A(4);
        
        num_obs_counter = num_obs_counter + 1;
        
        H.OBSERVATION_INF.PRN_NUM_OBS {num_obs_counter,1 } = SatSys;
        
        row = strfind(strcat(H.OBSERVATION_INF.OBS_TYPES{:,1}),SatSys);
        num_obs_typ = H.OBSERVATION_INF.OBS_TYPES {row,2};       % number of obs types
        
        H.OBSERVATION_INF.PRN_NUM_OBS {num_obs_counter,2 } = A(4:6); % sat PRN
        num_obs = A(7:60);
        while num_obs_typ > 9
            A = fgetl(file);
            num_obs = strcat(num_obs,A(7:60));
            num_obs_typ = num_obs_typ - 9;
        end
        % number of observations for each type
        H.OBSERVATION_INF.PRN_NUM_OBS {num_obs_counter,3 } = sscanf(num_obs, '%f'); 
        
        continue
    end
    
    % get signal strength unit
    % [ * optional record ]
    if (strfind(A,SSU  ) > 0), H.SIG_STRENGTH_UNIT = sscanf(A(1:20),'%s',1); continue, end 
        
    % get COMMENTS
    % [ * optional records ]
    if (strfind(A,COM  ) > 0), 
        comment_counter = comment_counter +1;
        H.COMMENTS{ comment_counter } = A(1:60);
        continue
    end
    
end


%% 1.1 CHECK IF COMPULSORY FIELDS ARE MISSING

message_id = '\n Header field not found > %s';

% RINEX_VERSION_TYPE
if ~isfield(H,'RINEX_VERSION_TYPE'), error(message_id,Rv);
else 
%    if strcmp(H.RINEX_VERSION_TYPE{1} , '    '),     warning(message_id,'RINEX VERSION'); 
%    elseif ~strcmp(H.RINEX_VERSION_TYPE{1} , '3.00'), error('Only able to process Rinex v 3.00 files'); end
%    if H.RINEX_VERSION_TYPE{2} ~= 'O'   ,     error('Only able to process OBSERVATION DATA files'); end
%    if H.RINEX_VERSION_TYPE{3} == ' '   ,     warning(message_id,'SATELLITE SYSTEM'); end
end


% PGM_RUNBY_DATE
if ~isfield(H,'PGM_RUNBY_DATE'), warning(message_id,RUNBY); end

% MARKER NAME  &  TYPE
if ~isfield(H,'MARKER'), 		warning(message_id,M_name,M_type);
else
   if isempty(H.MARKER{1}), 	warning(message_id,M_name); end
   if length (H.MARKER) <3, 	warning(message_id,M_type); end
end

% OBSERVER_AGENCY
if ~isfield(H,'OBSERVER_AGENCY'), warning(message_id,OBSERVER); end

% RECEIVER
if ~isfield(H,'RECEIVER'), warning(message_id,Rec); end

% ANTENNA
if ~isfield(H,'ANTENNA'), warning('ANTENNA INFORMATION NOT FOUND'); 
else
   if   ~isfield(H.ANTENNA,'NUMBER') && ~isfield(H.ANTENNA,'TYPE'), warning(message_id,AntID); end
   if   ~isfield(H.ANTENNA,'D_HEN' ),  warning(message_id,AntH); end
end

% APPROX_POSITION
if ~isfield(H,'APPROX_POS'), warning('Header field not found > %s (Optional for moving platforms)',Appos); end

% SYS / # / OBS TYPES
if ~isfield(H,'OBSERVATION_INF'), error(message_id,Obs_types_3); end

% TIME_FIRST_OBS
if ~isfield(H,'TIME_FIRST_OBS')
   
   switch H.RINEX_VERSION_TYPE{3}
   case 'G'
      H.TIME_FIRST_OBS{2} = 'GPS'; % for pure GPS files
   case 'R'
      H.TIME_FIRST_OBS{2} = 'GLO'; % for pure GLONASS files
   case 'E'
      H.TIME_FIRST_OBS{2} = 'GAL'; % for pure GALILEO files
   otherwise
      error('System Time not found. Impossible to assign default System Time');
   end
   warning(message_id,ToF);
   warning('System Time assign by default > %s',H.TIME_FIRST_OBS{2});
end







%% 2. READ OBSERVATIONS

% initialize auxiliar variables
fst_epo     = zeros(6,1);
scond_epo   = zeros(6,1);
t           = 0;
SatList     = [];
numsat      = 0;   
to          = datenum(1980,1,6);
tgps        = [];
if isfield(H,'INTERVAL'), ObsEpoc_step= H.INTERVAL; else ObsEpoc_step= 0; end

% Read Records
while 1
    
   % Read EPOCH record
   A = fgetl(file);
   % check End of file
   if ~ischar(A), disp('END OF Rinex FILE found'); break, end 
   if (A ~= '>'), error('Epoch Record expected.\nLine: %s',A); end
   
   [B, count, errmsg, nextindex] = sscanf(A,'> %d %d %d %d %d %f  %d%d      %f',9);
   if ~isempty(errmsg), disp('ERROR in Read Rinex Observations: %s',errmsg); return, end
   
   switch count,
       case {8,9},
           epoch = B(1:6);      % [yyyy mm dd hh min ss]'
           epoch_flag = B(7);   % 0: OK   1: power failure   >1: special event
           num_lines  = B(8);   % number of following lines
           % [ * optional record ]
           if count == 9, rec_clk_off = B(9); end  
           
           % To check consistency with header information ( TIME_FIRST_OBS & INTERVAL )
           if ~(datenum(fst_epo') == datenum(zeros(6,1)')) && ...
                   (datenum(scond_epo') == datenum(zeros(6,1)')),  
                scond_epo = epoch; 
                ObsEpoc_step = round((datenum(scond_epo') - datenum(fst_epo'))*86400*10)/10; % [s]
           end
           if datenum(fst_epo') == datenum(zeros(6,1)'), fst_epo = epoch; end
           
           % compute gps time
           tgps(end+1) = (datenum(epoch(1),epoch(2),epoch(3)) - to)*86400 + epoch(4)*60*60 + epoch(5)*60 + epoch(6);
           
           % increase an epoch ( t = row number in OBSERVATIONS )
           if ObsEpoc_step ~= 0 && t>0, t = t + round((tgps(end) - tgps(end-1))/ObsEpoc_step); else t = t + 1; end%
           
       case 2,
           epoch_flag = B(1); 
           num_lines  = B(2);
       otherwise
           error('ERROR in Read Rinex Observations: Matching failure in format.');
   end
    
%   
%    Read OBSERVATION records depending on epoch_flag     %
%    
%    Possible Epoch Flags:
%         0: OK
%         1: power failure
%         2: start moving antenna
%         3: new site occupation (end of kinem. data) (at least MARKER NAME follows)
%         4: header information follows
%         5: external event (epoch is significant, same time frame as obs time tags)
%         6: cycleslip records follow to optionally report detected and repaired cycle slips
% 
   
   switch epoch_flag
       case {0, 1}, 
           
           % This record is repeated for each satellite ( = num_lines )
           for j = 1: num_lines
               A = fgetl(file);
               
               % check possible errors through the observation record
               if ~ischar(A), error('End of File found. \nSatellite Observations expected in epoch %s',datestr(epoch')); end
               
               % check first character is not a System satellite 
               if isempty(strfind('GRESJC',A(1))), error('More Satellite Observations expected in epoch %s',datestr(epoch')); end
               
               SatSys = A(1);
               satid  = strrep(A(1:3),' ','0');
               
               % number of obs types
               row   = strfind(strcat(H.OBSERVATION_INF.OBS_TYPES{:,1}),SatSys);
               N_typ = H.OBSERVATION_INF.OBS_TYPES {row,2};
               
               
               % To check consistency with header information ( NUM_OBS_SAT & PRN_NUM_OBS )
               % First epoch in which a satellite is observed
               if isempty(strfind(strcmp(SatList,satid) == 1,1)), 
                   numsat = numsat +1; 
                   SatList { numsat } = satid;  
               end
               
               
               % GET OBSERVATIONS locating empty fields
               
               i = 1;                                                 % i = column number in OBSERVATIONS
               B = A(4:end);
               B_end = length(B);
               B(end + 1: N_typ * 16) = blanks((N_typ * 16) - B_end); % fill in with blanks
               
%                format1 = []; 
%                for k = 1: N_typ, format1 = strcat(format1,'%14f%1d%1d'); end
%                [data, count, errmsg, nextindex] = sscanf(B, format1);
                   
%                OBSERVATIONS.(satid){t,:}   = data;
               for k = 1: 16: N_typ * 16
                   
                   obs = str2double(B(k:k+13));
                   lli = str2double(B(k+14));                           %Loss of Lock Indicator (see p. A14 in rinex 3.03 manual)
                   ssi = str2double(B(k+15));                           %Signal Strength Indicator (should be deprecated -> look at SN0)
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
           
       case {2, 3, 4, 5}
           
           for j= 1: num_lines
               %skip lines
               A = fgetl(file);
               
           end
           
       case 6,
           for j= 1: num_lines
               
               A = fgetl(file);
%                SatSys = A(1);
%                satid = strrep(A(1:3),' ','0');
%                               
% %                CYCLESLIPS.(satid){t,1} = tgps;
%                
%                % GET OBSERVATIONS locating empty fields
%                
%                % number of obs types
%                N_typ = H.OBSERVATION_INF.(SatSys).num_obs_typ;
%                
%                i = 1;                                                 % i = column number in CYCLESLIPS
%                B = A(4:end);
%                B_end = length(B);
%                B(end + 1: N_typ * 16) = blanks((N_typ * 16) - B_end); % fill in with blanks
%                
%                for k = 1: 16: N_typ * 16
%                    
%                    obs = str2double(B(k:k+13));
%                    if isempty(obs) || (obs == 0.0), obs = NaN; end    % missing obs
%                    CYCLESLIPS.(satid){t,i}   = obs;
%                    i =i + 1;
                   
           end
           
       otherwise
           error('Epoch Flag out of {0, .. 6} in epoch: %s',num2str(epoch));
   end

end




% to check consistency with header inf
ObsEpoc_num = t;


%% 2.1 FILL IN EMPTY FIELDS IN OBSERVATION VARIABLES AND TRANSFORM CELLS TO MATRIX

for n_sat = 1: numsat
    
    satid  = SatList { n_sat };
    SatSys = satid(1);
    % number of obs types
    row   = strfind(strcat(H.OBSERVATION_INF.OBS_TYPES{:,1}),SatSys);
    N_typ = H.OBSERVATION_INF.OBS_TYPES {row,2};
        
    % find non-empty fields in variable
    pos 		= find	( cellfun( 'isempty',OBSERVATIONS.(satid) ) == 0 );
    % create an auxiliar matrix of NaN. Imp: same dimensions as OBSERVATIONS.(satid)
    OBS 		= zeros	( size(OBSERVATIONS.(satid)) )*NaN;
    % load data in matrix
    OBS(pos)	= cell2mat	( OBSERVATIONS.(satid) );

    OBSERVATIONS.(satid) = cat(1, OBS, zeros( [ObsEpoc_num - size(OBSERVATIONS.(satid),1), size(OBSERVATIONS.(satid),2) ] )*NaN );
     
end



%% 2.2 CHECK CONSISTENCY BETWEEN OBSERVATIONS AND HEADER INFORMATION
%               AND COMPLETE EMPTY FIELDS

% TIME_FIRST_OBS
if isempty(H.TIME_FIRST_OBS{1}),   H.TIME_FIRST_OBS{1} = fst_epo; 
elseif datenum(H.TIME_FIRST_OBS{1}') ~= datenum(fst_epo'), 
   warning('TIME of FIRST OBSERVATION in file not consistent with header information');
   H.TIME_FIRST_OBS{1} = fst_epo;
end

% TIME_LAST_OBS
if ~isfield(H,'TIME_LAST_OBS')
   H.TIME_LAST_OBS{1} = fst_epo + datevec( ((ObsEpoc_num-1) * ObsEpoc_step)/86400 )'; % (datevec in days)
   H.TIME_LAST_OBS{2} = H.TIME_FIRST_OBS{2};
elseif    datenum( H.TIME_LAST_OBS{1}' ) ~= datenum( fst_epo' + datevec( ((ObsEpoc_num-1) * ObsEpoc_step)/86400 ) )
      warning('TIME of LAST OBSERVATION in file not consistent with header information');
      H.TIME_LAST_OBS{1} = fst_epo + datevec( ((ObsEpoc_num-1) * ObsEpoc_step)/86400 )';
      H.TIME_LAST_OBS{2} = H.TIME_FIRST_OBS{2};
   
end

% INTERVAL
if ~isfield(H,'INTERVAL'), H.INTERVAL = ObsEpoc_step; 
elseif H.INTERVAL ~= ObsEpoc_step
    warning('INTERVAL between observations in file not consistent with header information');
    H.INTERVAL = ObsEpoc_step;
end

% H.NUM_OBS_SAT
if ~isfield(H,'NUM_OBS_SAT'), H.NUM_OBS_SAT = numsat;
elseif H.NUM_OBS_SAT ~= numsat, warning('NUMBER of OBSERVED SATELLITES not consistent with header information'); end

% H.OBSERVATION_INF.PRN_NUM_OBS
if ~isfield(H.OBSERVATION_INF,'PRN_NUM_OBS')
    for k = 1: length(SatList)
        H.OBSERVATION_INF.PRN_NUM_OBS{k,1} = SatList{k}(1); % SatSys
        H.OBSERVATION_INF.PRN_NUM_OBS{k,2} = SatList{k};    % Satellite PRN
    end
end

% H.ANTENNA.TYPE
if strcmp( H.ANTENNA.TYPE(17:20), blanks(4) ), H.ANTENNA.TYPE(17:20) = 'NONE'; end 

% CLOSE FILE
fclose(file);
% CLEAR VARIABLES


