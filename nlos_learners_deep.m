%%
%Datahandler

%Select constellations
GPS_flag = true;
GAL_flag = false; 
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
%[predictors, response] = nlos_feature_extractor.extract_standard_features(dataset);

%Feature set 2
[predictors_deep, response_deep] = nlos_feature_extractor.extract_features_set2_deep_learning(Dtrain);
[predictors_deep_val, response_deep_val] = nlos_feature_extractor.extract_features_set2_deep_learning(Dval);

%Feature set 3
%[predictors, response] = nlos_feature_extractor.extract_features_set3(dataset);

%%
% Learner

nb_feat = size(predictors_deep,1);

weight_NLOS = dh_train.fraction_los;
weight_LOS = 1 - weight_NLOS;
classificationWeights = [weight_NLOS weight_LOS];

layers = [
    imageInputLayer([nb_feat 1 1],"Name","imageinput")
    
    fullyConnectedLayer(10)
    batchNormalizationLayer
    reluLayer
    
    fullyConnectedLayer(10)
    batchNormalizationLayer
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
    'ValidationData',{predictors_deep_val,response_deep_val}, ...
    'ValidationFrequency',30, ...
    'Verbose',false, ...
    'Plots','training-progress', ...
    'ExecutionEnvironment', 'gpu');

net = trainNetwork(predictors_deep,response_deep,layers,options);


%% Evaluation

responsePredicted = classify(net,predictors_deep_val);

%Convert categoricals to numerical
Y = double(string(response_deep_val));
Yhat = double(string(responsePredicted));

%Visualise performance
train_flag = false;
nlos_performance.hard_classification_report(Y,Yhat, train_flag);


