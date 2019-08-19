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
%Train Learner

%For basic_holdout learners, set cv = false (CV = Cross Validation)
cv_flag = false;


%Model: Decision Tree
learner = nlos_models.classification_tree(Xtrain, Ytrain, cv_flag);

%Model: Linear Discriminant Analysis
%learner = nlos_models.discriminant_linear(Xtrain, Ytrain, cv_flag);

%Model: Quadratic Discriminant Analysis
%learner = nlos_models.discriminant_quadratic(Xtrain, Ytrain, cv_flag);

%Model: K-Nearest Neighbours (Euclidean distance)
%learner = nlos_models.knn_euclidean(Xtrain, Ytrain, cv_flag);

%Model: K-Nearest Neighbours (Euclidean distance, Squared-Inverse distance weighing)
%learner = nlos_models.knn_euclidean_SIweight(Xtrain, Ytrain, cv_flag);

%Model: K-Nearest Neighbours (Minkowski distance)
%learner = nlos_models.knn_minkowski(Xtrain, Ytrain, cv_flag);

%Model: Ensemble of Trees (bagging)
%learner = nlos_models.ensemble_bagging(Xtrain, Ytrain, cv_flag);

%%
%Performance

train_flag = true;

%Training data
Ytrain_predict = predict(learner,Xtrain);
Ytrain_mat = table2array(Ytrain);
nlos_performance.hard_classification_report(Ytrain_mat,Ytrain_predict, train_flag);

%Validation data
Yval_predict = predict(learner,Xval);
Yval_mat = table2array(Yval);
nlos_performance.hard_classification_report(Yval_mat,Yval_predict, ~train_flag);


%Obtaining scores possible with these learners? (possible with
%kfoldPredict...)


% %Predict
% [validationPredictions, validationScores] = kfoldPredict(learner);
% 
% %Report
% response_mat = table2array(response);
% nlos_performance.hard_classification_report(response_mat,validationPredictions);
% nlos_performance.nlos_roc(response_mat,validationScores);




