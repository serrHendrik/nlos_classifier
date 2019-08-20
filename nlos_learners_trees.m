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
%Not required for basic learners

%Extract final dataset from datahandler
Dtrain = dh_train.data;
Dval = dh_val.data;

%Info
dh_train.print_info_per_const(Dtrain);
dh_val.print_info_per_const(Dval);

%%
%Feature Engineering

%Standard features
%[Xtrain, Ytrain] = nlos_feature_extractor.extract_standard_features(Dtrain);
%[Xval, Yval] = nlos_feature_extractor.extract_standard_features(Dval);

%Feature set 2
[Xtrain, Ytrain] = nlos_feature_extractor.extract_features_set2(Dtrain);
[Xval, Yval] = nlos_feature_extractor.extract_features_set2(Dval);

%Feature set 3
%[Xtrain, Ytrain] = nlos_feature_extractor.extract_features_set3(Dtrain);
%[Xval, Yval] = nlos_feature_extractor.extract_features_set3(Dval);

%%
%Try auto-tuning hyperparameters
%Result -> MinLeafSize = 18-24

%learner = fitctree(Xtrain,Ytrain,'OptimizeHyperparameters','auto');

% learner = fitctree(Xtrain,Ytrain,...
%     'OptimizeHyperparameters','auto',...
%     'HyperparameterOptimizationOptions',struct('Holdout',0.3,...
%     'AcquisitionFunctionName','expected-improvement-plus'));

%Train Custom Learner
learner = fitctree(...
    Xtrain, ...
    Ytrain, ...
    'SplitCriterion', 'gdi', ...
    'MaxNumSplits', 2000, ...
    'MinLeafSize', 1, ...
    'Surrogate', 'off', ...
    'ScoreTransform', 'none', ...
    'ClassNames', [0; 1]); 

%    

%%
%Performance

%%
%Predict importance of the variables
imp = predictorImportance(learner);

figure;
bar(imp);
title('Predictor Importance Estimates');
ylabel('Estimates');
xlabel('Predictors');
h = gca;
h.XTickLabel = learner.PredictorNames;
h.XTickLabelRotation = 45;
h.TickLabelInterpreter = 'none';

%%

%Training data
[Ytrain_predict, Ytrain_scores] = predict(learner,Xtrain);
Ytrain_mat = table2array(Ytrain);
train_title_info = ['TRAINGING SET ', tour_train];

nlos_performance.hard_classification_report(Ytrain_mat,Ytrain_predict, train_title_info);
nlos_performance.nlos_roc(Ytrain_mat,Ytrain_scores, train_title_info);

%Validation data
[Yval_predict, Yval_scores] = predict(learner,Xval);
Yval_mat = table2array(Yval);
val_title_info = ['VALIDATION SET ', tour_val];

nlos_performance.hard_classification_report(Yval_mat,Yval_predict, val_title_info);
nlos_performance.nlos_roc(Yval_mat,Yval_scores, val_title_info);





