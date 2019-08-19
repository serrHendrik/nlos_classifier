%%
%Datahandler TRAINING

%Create datahandler
dh = nlos_datahandler();

%init datahandler with a predefined tour.
dh = dh.init_AMS_01();
%dh = dh.init_AMS_02();
%dh = dh.init_ROT_01();
%dh = dh.init_ROT_02();

%Select constellations
GPS_flag = true;
GAL_flag = true; 
GLO_flag = false;
dataset = dh.select_constellations(dh.data, GPS_flag, GAL_flag, GLO_flag);

%Normalise per constellation
vars_to_norm = {'pseudorange', 'carrierphase', 'cnr', 'doppler', 'az', 'az_cm', 'el', 'el_cm', 'third_ord_diff', 'innovations'};
dataset = dh.normalize_data_per_const(dataset,vars_to_norm);

%Sampling
%Not required for type1 learners

%Info
dh.print_info_per_const(dataset);


%%
%Datahandler VALIDATION

%Create datahandler
dh2 = nlos_datahandler();

%init datahandler with a predefined tour.
%dh2 = dh2.init_AMS_01();
%dh2 = dh2.init_AMS_02();
dh2 = dh2.init_ROT_01();
%dh2 = dh2.init_ROT_02();

%Select constellations
GPS_flag = true;
GAL_flag = true; 
GLO_flag = false;
dataset_validation = dh2.select_constellations(dh2.data, GPS_flag, GAL_flag, GLO_flag);

%Normalise per constellation
vars_to_norm = {'pseudorange', 'carrierphase', 'cnr', 'doppler', 'az', 'az_cm', 'el', 'el_cm', 'third_ord_diff', 'innovations'};
dataset_validation = dh2.normalize_data_per_const(dataset_validation,vars_to_norm);

%Sampling
%Not required for type1 learners

%Info
dh2.print_info_per_const(dataset_validation);



%%
%Feature Engineering

%Standard features
%[predictors, response] = nlos_feature_extractor.extract_standard_features(dataset);

%Feature set 2
[predictors_deep, response_deep] = nlos_feature_extractor.extract_features_set2_deep_learning(dataset);
[predictors_deep_val, response_deep_val] = nlos_feature_extractor.extract_features_set2_deep_learning(dataset_validation);

%Feature set 3
%[predictors, response] = nlos_feature_extractor.extract_features_set3(dataset);

%%
% Learner

nb_feat = size(predictors_deep,1);

weight_NLOS = dh.fraction_los;
weight_LOS = 1 - dh.fraction_los;
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

nlos_performance.hard_classification_report(Y,Yhat);


