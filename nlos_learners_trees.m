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

%Extract final dataset from datahandler
%Dtrain = dh_train.data;
%Dval = dh_val.data;

%Sampling: balance classes
%[Dtrain,~] = dh_train.sample_data_balance_classes(dh_train.data);
%[Dval,~] = dh_train.sample_data_balance_classes(dh_val.data);

Data = dh_train.data;
%[Data,~] = dh_train.sample_data_timewise(Data, 3);
%[Data,~] = dh_train.sample_data_classwise(Data, 0.95);
c = cvpartition(height(Data),'Holdout', 0.2);
Dtrain = Data(c.training,:);
Dval = Data(c.test,:);

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
[Xtrain, Ytrain] = nlos_feature_extractor.extract_standard_features(Dtrain_);
[Xval, Yval] = nlos_feature_extractor.extract_standard_features(Dval_);

%Feature set 2
%[Xtrain, Ytrain] = nlos_feature_extractor.extract_features_set2(Dtrain);
%[Xval, Yval] = nlos_feature_extractor.extract_features_set2(Dval);

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
learner1 = fitctree(...
    Xtrain, ...
    Ytrain, ...
    'SplitCriterion', 'gdi', ...
    'MaxNumSplits', 800, ...
    'MinLeafSize', 1, ...
    'Surrogate', 'on', ...
    'ScoreTransform', 'none', ...
    'ClassNames', [0; 1]); 


%%
%Performance learner1

nlos_performance.validate_learner(learner1, tour_train, tour_val, Xtrain, Ytrain, Xval, Yval)


%%
% Prune learner

%Find optimal tree depth
[~,~,~,bestlevel] = cvLoss(learner1,'SubTrees','All','TreeSize','min');
%view(learner1,'Mode','Graph','Prune',bestlevel)

learner2 = prune(learner1,'Level',bestlevel); 
%view(learner,'Mode','Graph')

%%
%Predict importance of the variables
imp = predictorImportance(learner2);

figure;
bar(imp);
title('Predictor Importance Estimates');
ylabel('Estimates');
xlabel('Predictors');
h = gca;
h.XTickLabel = learner2.PredictorNames;
h.XTickLabelRotation = 45;
h.TickLabelInterpreter = 'none';

%%
%Performance learner2
nlos_performance.validate_learner(learner2, tour_train, tour_val, Xtrain, Ytrain, Xval, Yval);



%%
%Test on other data
tour_test = 'AMS_02';
dh2 = nlos_datahandler(tour_test, GPS_flag, GAL_flag, GLO_flag, normalize_flag);
Data2 = dh2.data;
if scale_flag
    Data2_ = scaler.scale(Data2);
else
    Data2_ = Data2;    
end
[X2, Y2] = nlos_feature_extractor.extract_standard_features(Data2_);

[Y2_predict, Y2_scores] = predict(learner2,X2);
Y2_mat = table2array(Y2);
nlos_performance.hard_classification_report(Y2_mat,Y2_predict, tour_test);

%%
%Store results
learner_name = 'DecisionTree';
filename = ['data/',tour_test,'/',tour_test,'_output_',learner_name,'.csv'];
Data_final = nlos_postprocessing.store_results(Data2,Y2_predict, Y2_scores(:,2),filename);


%%

% 
% % Overfit model
% 
% learner3 = fitctree(...
%     Xtrain, ...
%     Ytrain, ...
%     'SplitCriterion', 'gdi', ...
%     'MaxNumSplits', 10000, ...
%     'MinLeafSize', 1, ...
%     'Surrogate', 'on', ...
%     'ScoreTransform', 'none', ...
%     'ClassNames', [0; 1]); 

% %%
% %Performance learner3
% 
% nlos_performance.validate_learner(learner3, tour_train, tour_val, Xtrain, Ytrain, Xval, Yval);
% 
% %%
% %ROC-curve of three learners
% train_title_info = ['TRAINGING SET ', tour_train];
% val_title_info = ['VALIDATION SET ', tour_val];
% learners = {learner1, learner2, learner3};
% learner_names = ["DT-basecase", "DT-pruned", "DT-overfit"];
% 
% %Training ROC
% Ytrain_mat = table2array(Ytrain);
% nlos_performance.nlos_roc_multiple(Xtrain, Ytrain_mat, learners, learner_names, train_title_info);
% 
% %Validation ROC
% Yval_mat = table2array(Yval);
% nlos_performance.nlos_roc_multiple(Xval, Yval_mat, learners, learner_names, val_title_info);


