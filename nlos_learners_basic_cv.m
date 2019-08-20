%%
%Datahandler

%Select constellations
GPS_flag = true;
GAL_flag = false; 
GLO_flag = false;

%Select tour
%tour = 'AMS_01';
%tour = 'AMS_02';
tour = 'ROT_01';
%tour = 'ROT_02';

%Normalize numeric predictors?
normalize_flag = true;

%Create datahandler
dh = nlos_datahandler(tour, GPS_flag, GAL_flag, GLO_flag, normalize_flag);

%Sampling
%Not required for basic learners

%Extract final dataset from datahandler
dataset = dh.data;

%Info
dh.print_info_per_const(dataset);

%%
%Feature Engineering

%Standard features
%[predictors, response] = nlos_feature_extractor.extract_standard_features(dataset);

%Feature set 2
%[predictors, response] = nlos_feature_extractor.extract_features_set2(dataset);

%Feature set 3
[predictors, response] = nlos_feature_extractor.extract_features_set3(dataset);

%%
%Train Learner

%For basic_cv learners, set cv = true (CV = Cross Validation)
cv_flag = true;

%Model: Decision Tree
learner = nlos_models.classification_tree(predictors, response, cv_flag);

%Model: Linear Discriminant Analysis
%learner = nlos_models.discriminant_linear(predictors, response);

%Model: Quadratic Discriminant Analysis
%learner = nlos_models.discriminant_quadratic(predictors, response);

%Model: K-Nearest Neighbours (Euclidean distance)
%learner = nlos_models.knn_euclidean(predictors, response);

%Model: K-Nearest Neighbours (Euclidean distance, Squared-Inverse distance weighing)
%learner = nlos_models.knn_euclidean_SIweight(predictors, response);

%Model: K-Nearest Neighbours (Minkowski distance)
%learner = nlos_models.knn_minkowski(predictors, response);

%Model: Ensemble of Trees (bagging)
%learner = nlos_models.ensemble_bagging(predictors, response);

%%
%Performance

%Predict
[validationPredictions, validationScores] = kfoldPredict(learner);

%Report
response_mat = table2array(response);
nlos_performance.hard_classification_report(response_mat,validationPredictions);
nlos_performance.nlos_roc(response_mat,validationScores);




