%{
NOTE: ONLY RUN THIS FILE AFTER EXECUTING CORRESPONDING PNT2 CONFIG SCRIPT

This script will use the generated PNT2 variables to construct a new struct
containing the necessary data for LOS/NLOS detection.

Execute this script from the nlos_classifier workspace as root.
%}

full_filename_output = 'data/AMS_01/PNT2data.mat';
PNT2_extract_input_data(full_filename_output, refPosCommonTime, nav, store);