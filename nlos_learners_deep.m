%%
%Datahandler

%Select constellations
GPS_flag = true;
GAL_flag = false; 
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

%Normalize numeric predictors?
normalize_flag = true;

%Create TRAINING and VALIDATION datahandler
dh_train = nlos_datahandler(tour_train, GPS_flag, GAL_flag, GLO_flag, normalize_flag);
dh_val = nlos_datahandler(tour_val, GPS_flag, GAL_flag, GLO_flag, normalize_flag);

%Sampling
%Not required for deep learners

%Extract final dataset from datahandler
Dtrain = dh_train.data;
Dval = dh_val.data;

%Info
dh_train.print_info_per_const(Dtrain);
dh_val.print_info_per_const(Dval);

%%
%Feature Engineering

%Standard features
[Xtrain, Ytrain] = nlos_feature_extractor.extract_standard_features_deep_learning(Dtrain);
[Xval, Yval] = nlos_feature_extractor.extract_standard_features_deep_learning(Dval);

%Feature set 2
%[Xtrain, Ytrain] = nlos_feature_extractor.extract_features_set2_deep_learning(Dtrain);
%[Xval, Yval] = nlos_feature_extractor.extract_features_set2_deep_learning(Dval);

%Feature set 3
%[predictors, response] = nlos_feature_extractor.extract_features_set3(dataset);

%%
% Learner

nb_feat = size(Xtrain,1);

weight_NLOS = dh_train.fraction_los;
weight_LOS = 1 - weight_NLOS;
classificationWeights = [weight_NLOS weight_LOS];

layers = [
    imageInputLayer([nb_feat 1 1],"Name","imageinput")
    
    fullyConnectedLayer(10)
    %batchNormalizationLayer
    reluLayer
    
    fullyConnectedLayer(10)
    %batchNormalizationLayer
    reluLayer
    
    fullyConnectedLayer(2)
    %batchNormalizationLayer("Name", "batchNorm2")
    %reluLayer("Name","relu2")
    
    softmaxLayer
    WeightedClassificationLayer(classificationWeights)];

options = trainingOptions('adam', ...
    'InitialLearnRate',0.001, ...
    'MaxEpochs',4, ...
    'Shuffle','every-epoch', ...
    'ValidationData',{Xval,Yval}, ...
    'ValidationFrequency',500, ...
    'Verbose',false, ...
    'Plots','training-progress', ...
    'ExecutionEnvironment', 'gpu');

net = trainNetwork(Xtrain,Ytrain,layers,options);


%% Evaluation

Ytrain_predicted = classify(net,Xtrain);
Yval_predicted = classify(net,Xval);

%Convert categoricals to numerical
Ytrain_base = double(string(Ytrain));
Yval_base = double(string(Yval));

Ytrain_hat = double(string(Ytrain_predicted));
Yval_hat = double(string(Yval_predicted));

%Visualise performance
train_title_info = ['TRAINING SET ', tour_train];
val_title_info = ['VALIDATION SET ', tour_val];
nlos_performance.hard_classification_report(Ytrain_base,Ytrain_hat, train_title_info);
nlos_performance.hard_classification_report(Yval_base,Yval_hat, val_title_info);


