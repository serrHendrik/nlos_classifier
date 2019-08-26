%%
%Datahandler

%Select constellations
GPS_flag = false;
GAL_flag = true; 
GLO_flag = false;

%Select TRAINING tour
tour_train = 'AMS_01';
%tour_train = 'AMS_02';
%tour_train = 'ROT_01';
%tour_train = 'ROT_02';

%Select VALIDATION tour
%tour_val = 'AMS_01';
%tour_val = 'AMS_02';
tour_val = 'ROT_01';
%tour_val = 'ROT_02';

%LAG
lag = 5;

%Create TRAINING and VALIDATION datahandler
dh_train = nlos_datahandler_cnn(tour_train, GPS_flag, GAL_flag, GLO_flag, lag);
dh_val = nlos_datahandler_cnn(tour_val, GPS_flag, GAL_flag, GLO_flag, lag);


%Extract final dataset from datahandler
%Dtrain = dh_train.data;
%Dval = dh_val.data;

%Sampling
%Sampling: timewise (keep 1 every X seconds)
%[Dtrain,~] = dh_train.sample_data_timewise(dh_train.data, 5, 0);
%[Dval,~] = dh_val.sample_data_timewise(dh_val.data, 5, 2);
%Sampling: balance classes
%[Dtrain,~] = dh_train.sample_data_balance_classes(Dtrain);
%[Dval,~] = dh_val.sample_data_balance_classes(Dval);
%Sampling: classwise (maintain balance while downsampling)
%[Dtrain,~] = dh_train.sample_data_classwise(Dtrain, 0.5);
%[Dval,~] = dh_val.sample_data_classwise(Dval, 0.5);

[data,~] = dh_train.sample_data_balance_classes(dh_train.data);
c = cvpartition(height(data),'KFold', 2);

Dtrain = data(c.test(1),:);
Dval = data(c.test(2),:);

%Info
dh_train.print_info_per_const(Dtrain);
dh_val.print_info_per_const(Dval);

%%
%Scaler
scale_flag = true;

%base_features = {'pseudorange', 'carrierphase', 'cnr', 'doppler', 'az', 'el', 'innovations'};
base_features = {'pseudorange', 'carrierphase', 'cnr', 'el','innovations'};

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

%%
% Learner

nb_feat = length(base_features);

weight_NLOS = dh_train.fraction_los;
weight_LOS = 1 - weight_NLOS;
classificationWeights = [weight_NLOS weight_LOS];

layers = [
    imageInputLayer([nb_feat lag 1],"Name","InputLayer")
    
    convolution2dLayer([1 2], 256, 'Stride', [1 1], 'Padding', 'same', "Name", "Conv1")
    %convolution2dLayer([nb_feat 1], 128, 'Stride', [1 1], 'Padding', 'same', "Name", "Conv1")
    reluLayer
    %dropoutLayer(0.2)
    convolution2dLayer([2 1], 64, 'Stride', [1 1], 'Padding', 'same', "Name", "Conv2")
    reluLayer
    %dropoutLayer(0.2)
    
    %maxPooling2dLayer([2 2])
    
    %convolution2dLayer([2 3], 64, 'Stride', [1 1], 'Padding', 'same', "Name", "Conv3")
    %reluLayer
    fullyConnectedLayer(32)
    reluLayer
    
    fullyConnectedLayer(2)
    reluLayer
    
    softmaxLayer
    classificationLayer
    %WeightedClassificationLayer(classificationWeights)
    ];

options = trainingOptions('adam', ...
    'InitialLearnRate',0.001, ...
    'MaxEpochs',10000, ...
    'Shuffle','every-epoch', ...
    'ValidationData',{Xval,Yval}, ...
    'ValidationFrequency',500, ...
    'Verbose',false, ...
    'Plots','training-progress', ...
    'ExecutionEnvironment', 'gpu');

net = trainNetwork(Xtrain,Ytrain,layers,options);


%% Evaluation

[Ytrain_hat,Ytrain_scores]  = classify(net,Xtrain);
[Yval_hat, Yval_scores] = classify(net,Xval);

%Convert categoricals to numerical
Ytrain_base = double(string(Ytrain));
Yval_base = double(string(Yval));

Ytrain_hat = double(string(Ytrain_hat));
Yval_hat = double(string(Yval_hat));

%Visualise performance
train_title_info = ['TRAINING SET ', tour_train];
val_title_info = ['VALIDATION SET ', tour_val];
nlos_performance.hard_classification_report2(Ytrain_base,Ytrain_hat, train_title_info);
nlos_performance.hard_classification_report2(Yval_base,Yval_hat, val_title_info);

%ROC
nlos_performance.nlos_roc(Ytrain_base,Ytrain_scores, train_title_info);
nlos_performance.nlos_roc(Yval_base,Yval_scores, val_title_info);

