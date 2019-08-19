%%
%Datahandler

%Create datahandler
dh = nlos_datahandler();

%init datahandler with a predefined tour.
%dh = dh.init_AMS_01();
%dh = dh.init_AMS_02();
dh = dh.init_ROT_01();
%dh = dh.init_ROT_02();

%Select constellations
GPS_flag = true;
GAL_flag = false; 
GLO_flag = false;
dataset = dh.select_constellations(dh.data, GPS_flag, GAL_flag, GLO_flag);

%Normalise per constellation
%vars_to_norm = {'pseudorange', 'carrierphase', 'cnr', 'doppler', 'az', 'az_cm', 'el', 'el_cm', 'third_ord_diff', 'innovations'};
%dataset = dh.normalize_data_per_const(dataset,vars_to_norm);

%Sampling
%Not required for type1 learners

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
cv_flag = false;


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




