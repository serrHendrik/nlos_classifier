%%
%Datahandler

%Select constellations
GPS_flag = true;
GAL_flag = true; 
GLO_flag = false;

%Select TRAINING tour
tour_train = 'AMS_01';
%tour_train = 'AMS_02';
%tour_train = 'ROT_01';
%tour_train = 'ROT_02';

%Select VALIDATION tour
%tour_val = 'AMS_01';
tour_val = 'AMS_02';
%tour_val = 'ROT_01';
%tour_val = 'ROT_02';

%LAG
lag = 2;

%Create TRAINING and VALIDATION datahandler
dh_train = nlos_datahandler_cnn(tour_train, GPS_flag, GAL_flag, GLO_flag, lag);
dh_val = nlos_datahandler_cnn(tour_val, GPS_flag, GAL_flag, GLO_flag, lag);


%Extract final dataset from datahandler
Dtrain = dh_train.data;
Dval = dh_val.data;

%Info
dh_train.print_info_per_const(Dtrain);
dh_val.print_info_per_const(Dval);

%%
%Scaler
scale_flag = true;

%base_features = {'pseudorange', 'carrierphase', 'cnr', 'doppler', 'az', 'el', 'innovations'};
base_features = {'pseudorange', 'cnr', 'el', 'innovations'};

if scale_flag
    %first = 2+lag+1;  %remove sv_sys, sv_id, common_time_X
    %last = length(Dtrain.Properties.VariableNames) - 1;
    %scalable_vars = Dtrain.Properties.VariableNames(first:last);
    scaler = nlos_scaler_minmax(Dtrain,base_features);
    
    Dtrain_ = scaler.scale(Dtrain);
    Dval_ = scaler.scale(Dval);
else
    Dtrain_ = Dtrain;
    Dval_ = Dval;    
end



%%
%Feature Engineering

%Standard features
[Xtrain, Ytrain] = nlos_feature_extractor.extract_standard_features_cnn(Dtrain_, base_features, lag);
[Xval, Yval] = nlos_feature_extractor.extract_standard_features_cnn(Dval_, base_features, lag);




