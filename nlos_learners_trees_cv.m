%%
%Datahandler

%Select constellations
GPS_flag = true;
GAL_flag = true; 
GLO_flag = false;

%Select tour
tour = 'ROT_01';

%Normalize numeric predictors?
normalize_flag = false;

%Create datahandler
dh = nlos_datahandler(tour, GPS_flag, GAL_flag, GLO_flag, normalize_flag);
Data = dh.data;
%[Data,~] = dh.sample_data_timewise(Data, 2);

%Info
dh.print_info_per_const(Data);


%Scaler
scale_flag = false;

if scale_flag
    scalable_vars = Data.Properties.VariableNames(4:13);
    scaler = nlos_scaler_minmax(Data,scalable_vars);
    
    Data_ = scaler.scale(Data);
else
    Data_ = Data;    
end

[X, Y] = nlos_feature_extractor.extract_standard_features(Data_);

%%
K = 10;

learners = fitctree(...
    X, ...
    Y, ...
    'SplitCriterion', 'gdi', ...
    'MaxNumSplits', 200, ...
    'MinLeafSize', 1, ...
    'Surrogate', 'on', ...
    'ScoreTransform', 'none', ...
    'ClassNames', [0; 1], ...
    'KFold', K);  




%%
%Predict
[validationPredictions, validationScores] = kfoldPredict(learners);

%Report
response_mat = table2array(Y);
nlos_performance.hard_classification_report(response_mat,validationPredictions, tour);
%nlos_performance.nlos_roc(response_mat,validationScores, tour);

%%
%Test on entire datasets

%Train on all data
learner = fitctree(...
    X, ...
    Y, ...
    'SplitCriterion', 'gdi', ...
    'MaxNumSplits', 200, ...
    'MinLeafSize', 1, ...
    'Surrogate', 'on', ...
    'ScoreTransform', 'none', ...
    'ClassNames', [0; 1]); 
% Prune learner
[~,~,~,bestlevel] = cvLoss(learner,'SubTrees','All','TreeSize','min');
learner = prune(learner,'Level',bestlevel);

%%
%Test on other data
tour_test = 'AMS_01';
dh2 = nlos_datahandler(tour_test, GPS_flag, GAL_flag, GLO_flag, normalize_flag);
Data2 = dh2.data;
if scale_flag
    Data2_ = scaler.scale(Data2);
else
    Data2_ = Data2;    
end
[X2, Y2] = nlos_feature_extractor.extract_standard_features(Data2_);

[Y2_predict, Y2_scores] = predict(learner,X2);
Y2_mat = table2array(Y2);
nlos_performance.hard_classification_report(Y2_mat,Y2_predict, tour_test);



