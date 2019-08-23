%%
%Datahandler

%Select constellations
GPS_flag = false;
GAL_flag = true; 
GLO_flag = false;

%Select TRAINING tour
%tour_train = 'AMS_01';
%tour_train = 'AMS_02';
tour_train = 'ROT_01';
%tour_train = 'ROT_02';

%Select VALIDATION tour
tour_val = 'AMS_01';
%tour_val = 'AMS_02';
%tour_val = 'ROT_01';
%tour_val = 'ROT_02';

%Normalize numeric predictors?
normalize_flag = false;

%Create TRAINING and VALIDATION datahandler
dh_train = nlos_datahandler(tour_train, GPS_flag, GAL_flag, GLO_flag, normalize_flag);
dh_val = nlos_datahandler(tour_val, GPS_flag, GAL_flag, GLO_flag, normalize_flag);

%Extract final dataset from datahandler
Dtrain = dh_train.data;
Dval = dh_val.data;

%Sampling
%[Dtrain,~] = dh_train.sample_data_classwise(dh_train.data, 0.75);
%[Dval,~] = dh_train.sample_data_classwise(dh_val.data, 0.95);

%Info
dh_train.print_info_per_const(Dtrain);
dh_val.print_info_per_const(Dval);

%%
%Scaler
scale_flag = true;

if scale_flag
    scalable_vars = Dtrain.Properties.VariableNames(4:13);
    scaler = nlos_scaler_minmax(Dtrain,scalable_vars);
    
    Dtrain_ = scaler.scale(Dtrain);
    Dval_ = scaler.scale(Dval);
else
    Dtrain_ = Dtrain;
    Dval_ = Dval;    
end

%%
%Feature Engineering

%Standard features
[Xtrain, Ytrain] = nlos_feature_extractor.extract_standard_features_deep_learning(Dtrain_);
[Xval, Yval] = nlos_feature_extractor.extract_standard_features_deep_learning(Dval_);

%Feature set 2
%[Xtrain, Ytrain] = nlos_feature_extractor.extract_features_set2_deep_learning(Dtrain_);
%[Xval, Yval] = nlos_feature_extractor.extract_features_set2_deep_learning(Dval_);

%Feature set 3
%[predictors, response] = nlos_feature_extractor.extract_features_set3(dataset);


%Xval = Xtrain;
%Yval = Ytrain;


%%
% Learner

nb_feat = size(Xtrain,1);

weight_NLOS = dh_train.fraction_los;
weight_LOS = 1 - weight_NLOS;
classificationWeights = [weight_NLOS weight_LOS];

layers = [
    imageInputLayer([nb_feat 1 1],"Name","imageinput")
    
    fullyConnectedLayer(512)
    %batchNormalizationLayer
    reluLayer
    
    fullyConnectedLayer(256)
    %batchNormalizationLayer
    reluLayer
    
    fullyConnectedLayer(88)
    %batchNormalizationLayer
    reluLayer
    
    fullyConnectedLayer(2)
    %batchNormalizationLayer("Name", "batchNorm2")
    reluLayer
    
    softmaxLayer
    %classificationLayer
    WeightedClassificationLayer(classificationWeights)
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

    %'LearnRateSchedule', 'piecewise', ...
    %'LearnRateDropFactor',0.95, ...
    %'L2Regularization',0.0005, ...
    
net = trainNetwork(Xtrain,Ytrain,layers,options);


%% Evaluation

[Ytrain_predicted, Ytrain_scores] = classify(net,Xtrain);
[Yval_predicted, Yval_scores] = classify(net,Xval);

%Convert categoricals to numerical
Ytrain_base = double(string(Ytrain));
Yval_base = double(string(Yval));

Ytrain_hat = double(string(Ytrain_predicted));
Yval_hat = double(string(Yval_predicted));

%Visualise performance
train_title_info = ['TRAINING SET ', tour_train];
val_title_info = ['VALIDATION SET ', tour_val];
nlos_performance.hard_classification_report2(Ytrain_base,Ytrain_hat, train_title_info);
nlos_performance.hard_classification_report2(Yval_base,Yval_hat, val_title_info);

%ROC
nlos_performance.nlos_roc(Ytrain_base,Ytrain_scores, train_title_info);
nlos_performance.nlos_roc(Yval_base,Yval_scores, val_title_info);
