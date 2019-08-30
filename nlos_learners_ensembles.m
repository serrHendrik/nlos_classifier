%%
%Datahandler

%Select constellations
GPS_flag = true;
GAL_flag = true; 
GLO_flag = false;

%Select TRAINING tour
%tour_train = 'AMS_01';
%tour_train = 'AMS_02';
tour_train = 'ROT_01';
%tour_train = 'ROT_02';

%Select VALIDATION tour
%tour_val = 'AMS_01';
%tour_val = 'AMS_02';
tour_val = 'ROT_01';
%tour_val = 'ROT_02';

%Normalize numeric predictors?
normalize_flag = false;

%Create TRAINING and VALIDATION datahandler
dh_train = nlos_datahandler(tour_train, GPS_flag, GAL_flag, GLO_flag, normalize_flag);
dh_val = nlos_datahandler(tour_val, GPS_flag, GAL_flag, GLO_flag, normalize_flag);

%Sampling
%Not required for basic learners

%Extract final dataset from datahandler
%Dtrain = dh_train.data;
%Dval = dh_val.data;

Data = dh_train.data;
[Data,~] = dh_train.sample_data_timewise(Data, 2);
c = cvpartition(height(Data),'Holdout', 0.2);
Dtrain = Data(c.training,:);
Dval = Data(c.test,:);

%Info
dh_train.print_info_per_const(Dtrain);
dh_val.print_info_per_const(Dval);

%%
%Feature Engineering

%Standard features
[Xtrain, Ytrain] = nlos_feature_extractor.extract_standard_features(Dtrain);
[Xval, Yval] = nlos_feature_extractor.extract_standard_features(Dval);

%Feature set 2
%[Xtrain, Ytrain] = nlos_feature_extractor.extract_features_set2(Dtrain);
%[Xval, Yval] = nlos_feature_extractor.extract_features_set2(Dval);

%Feature set 3
%[Xtrain, Ytrain] = nlos_feature_extractor.extract_features_set3(Dtrain);
%[Xval, Yval] = nlos_feature_extractor.extract_features_set3(Dval);

%%
%auto-tune (takes a long time)

% rng('default')
% t = templateTree('Reproducible',true);
% Mdl = fitcensemble(Xtrain, Ytrain,'OptimizeHyperparameters','auto','Learners',t, ...
%     'HyperparameterOptimizationOptions',struct('AcquisitionFunctionName','expected-improvement-plus'))

%Result
%Method: Bag
%NumLearningCycles: 484
%MinLeafSiz 2

%%
%Model 1

tt = templateTree(...
    'MaxNumSplits', 20, ...
    'MinLeafSize', 1);

learner1 = fitcensemble(...
    Xtrain, ...
    Ytrain, ...
    'Method', 'Bag', ...
    'Learners', tt, ...
    'NumLearningCycles',200);

%Methods: AdaBoostM1, RUSBoost, RobustBoost, GentleBoost, LogitBoost,
%           LPBoost, Bag
% Bag superior accuracy but very class imbalanced performance
% RUSBoost best class balance, but still not very good for NLOS.
%%
%Performance learner1

nlos_performance.validate_learner(learner1, tour_train, tour_val, Xtrain, Ytrain, Xval, Yval)

figure;
plot(loss(learner1,Xval,Yval,'mode','cumulative'))
xlabel('Number of trees')
ylabel('Validation classification error')


%% New data

tour_test = 'AMS_02';
dh2 = nlos_datahandler(tour_test, GPS_flag, GAL_flag, GLO_flag, normalize_flag);
Data2 = dh2.data;
Data2_ = scaler.scale(Data2);
[X2, Y2] = nlos_feature_extractor.extract_standard_features(Data2_);

[Y2_predict, Y2_scores] = predict(learner1,X2);
Y2_mat = table2array(Y2);
nlos_performance.hard_classification_report(Y2_mat,Y2_predict, tour_test);


