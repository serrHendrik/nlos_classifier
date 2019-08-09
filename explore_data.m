
%%
%Rinex file structure
%{
Sources:
https://nastava.sf.bg.ac.rs/mod/page/view.php?id=14220
http://navigation-office.esa.int/attachments_12649498_1_Reichel_5thGalSciCol_2015.pdf
Manual Rinex 3.03 (Appendix)!

QUESTIONS:
* Possible to extract correlation functions from this data?

See raw data file:
After the header, data is divided into sections, grouping measurements taken 
at the same time together. Multiple measurements may exist for the same epoch 
due to visibility to multiple GPS satellites. 
The lines indicating the date include this information:

Year Month Day Hour Min Sec Epoch_Flag_Record Num_Visible_Sats

Epoch_Flag_Record: 0 is ok -> no event

##################
VARIABLES: see source!
(https://nastava.sf.bg.ac.rs/mod/page/view.php?id=14220)

+--------------------+------------------------------------------+------------+
 |# / TYPES OF OBSERV | - Number of different observation types  |     I6,    |
 |                    |   stored in the file                     |            |
 |                    | - Observation types                      |            |
 |                    |   - Observation code                     | 9(4X,A1,   |
 |                    |   - Frequency code                       |         A1)|
 |                    |   If more than 9 observation types:      |            |
 |                    |     Use continuation line(s) (including  |6X,9(4X,2A1)|
 |                    |     the header label in cols. 61-80!)    |            |
 |                    |                                          |            |
 |                    | The following observation types are      |            |
 |                    | defined in RINEX Version 2.11:           |            |
 |                    |                                          |            |
 |                    | Observation code (use uppercase only):   |            |
 |                    |   C: Pseudorange  GPS: C/A, L2C          |            |
 |                    |                   Glonass: C/A           |            |
 |                    |                   Galileo: All           |            |
 |                    |   P: Pseudorange  GPS and Glonass: P code|            |
 |                    |   L: Carrier phase                       |            |
 |                    |   D: Doppler frequency                   |            |
 |                    |   S: Raw signal strengths or SNR values  |            |
 |                    |      as given by the receiver for the    |            |
 |                    |      respective phase observations       |            |
 |                    |                                          |            |
 |                    | Frequency code                           |            |
 |                    |      GPS    Glonass   Galileo    SBAS    |            |
 |                    |   1:  L1       G1     E2-L1-E1    L1     |            |
 |                    |   2:  L2       G2        --       --     |            |
 |                    |   5:  L5       --        E5a      L5     |            |
 |                    |   6:  --       --        E6       --     |            |
 |                    |   7:  --       --        E5b      --     |            |
 |                    |   8:  --       --       E5a+b     --     |            |
 |                    |                                          |            |
 |                    | Observations collected under Antispoofing|            |
 |                    | are converted to "L2" or "P2" and flagged|            |
 |                    | with bit 2 of loss of lock indicator     |            |
 |                    | (see Table A2).                          |            |
 |                    |                                          |            |
 |                    | Units : Phase       : full cycles        |            |
 |                    |         Pseudorange : meters             |            |
 |                    |         Doppler     : Hz                 |            |
 |                    |         SNR etc     : receiver-dependent |            |
 |                    |                                          |            |
 |                    | The sequence of the types in this record |            |
 |                    | has to correspond to the sequence of the |            |
 |                    | observations in the observation records  |            |


C__ -> Pseudorange in meters
L__ -> Carrier PHASE in full cycles
D__ -> Doppler freq in Hz
S__ -> SNR

_2_ -> L2 carrier frequency

__C -> C/A code



%OUTPUT

[See also page A14 in rinex 3.03 manual]
For every observational variable, we get three output variables:
1. Value of variable
2. Loss of Lock Indicator (LLI) ["should only be associated with the phase observation."]
3. Signal Strength Indicator (SSI) ["should be deprecated and replaced by a defined SNR field for each signal"]

%}

%filename = '../data/gnor182m.19o';
%[H,OBS] = read_rnx(filename);



%%
%Camera output from project Floor

%gpsTime: 1xn -> GPS Time since GPS initial epoch [s]
%gpsWcN: 1xn -> GPS Week Number
%gpsToW: 1xn -> GPS Time-of-Week [s] since last passage of Saturday to Sunday
%G:
%	ISLOS: mxn matrix containing [0] for NLOS and [1] for LOS m (is number of spacecraft for the GPS constellation). If satellite was not observed it has NaN.
%	svPRN: mx1 vector containing the number of the spacecraft in the ISLOS row.
%	separation: mxn matrix (same format as ISLOS) but containing the separation to the sky region in pixels.
%
%Similar structures are found for Galileo (E) and GLONASS (R)

%%

addpath(genpath('fisheyecameranlos/'));

%%
%Load Labels (Camera Data)

%Amsterdam 1
AMS1_labels = load('islosData_EXP01_AMS_2018.mat');
%[AMS1_obs_h,AMS1_obs] = read_rnx('../data/COM36_181107_073132_Rx5_Ams_01.obs');
%[AMS1_nav_h,AMS1_nav] = read_rnx('../data/COM36_181107_073132_Rx5_Ams_01.nav');
%Amsterdam 2 
AMS2_labels = load('islosData_EXP02_AMS_2018.mat');
%Rotterdam
RTM_labels = load('islosData_EXP01_RTM_2018.mat');

%%

% Parse Rinex
const = multi_constellation_settings(1,1,1,0,0,0);
[pr1, ph1, pr2, ph2, dop1, dop2, snr1, snr2, ...
          time_ref, time, week, date, pos, interval, antoff, antmod, tow] = ...
          load_RINEX_obs('../data/COM36_181107_073132_Rx5_Ams_01.obs', const);
%[Eph, iono, corrSysTime] = RINEX_get_nav('../data/COM36_181107_073132_Rx5_Ams_01.nav', const);

%%

%Get elevation and azimuth
%TODO: fix relative paths...

%get_AzEl('./fisheyecameranlos/')

%%
%TODO: include elevation and azimuth -> see "VideoPbMapSelection.m" from Floor

% Combine data

dataL1 = [];
sat_ids = strings(const.nEnabledSat,1);
sat_sys_array = [const.GPS,const.Galileo,const.GLONASS];
sat_sys_id_array = ['G','E','R'];
for i = 1:3
    sat_sys = sat_sys_array(i);
    sat_sys_id = sat_sys_id_array(i);
    
    for j = sat_sys.PRN
       sat_id_string = strcat(sat_sys_id, int2str(j));
       sat_ids(sat_sys.indexes(j)) = sat_id_string;
    end
end


for t = 1:size(time_ref) %loop over time
    
    time_mat = repmat(time_ref(t),const.nEnabledSat,1);
    temp = [time_mat sat_ids pr1(:,t) ph1(:,t) dop1(:,t) snr1(:,t)]; 
    
    sat_mask = [pr1(:,t) ~= 0]; %only add observable satellites
    temp = temp(sat_mask,:);
    
    dataL1 = [dataL1 ; temp];
end
      
      

 
%%

