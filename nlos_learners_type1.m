%nlos_agent_group2 info:

%input: {'pseudorange', 'cnr', 'doppler', 'az', 'az_cm', 'el', 'el_cm'}

%models: 
%2.1 Classification tree
%2.2 Linear Discriminant Analysis
%2.3 Quadratic Discriminant Analysis
%2.4: K-Nearest Neighbours (Euclidean distance)
%2.5: K-Nearest Neighbours (Euclidean distance, Squared-Inverse distance weighing)
%2.6: K-Nearest Neighbours (Minkowski distance)

%output: {'los'}

%performance: 
%   1. Hard classification: Precision, Recall, F1, Accuracy
%   2. Soft classification: 


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
vars_to_norm = {'pseudorange', 'carrierphase', 'cnr', 'doppler', 'az', 'az_cm', 'el', 'el_cm', 'third_ord_diff', 'innovations'};
dataset = dh.normalize_data_per_const(dataset,vars_to_norm);

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

%Model: Decision Tree
learner = nlos_models.classification_tree(predictors, response);

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

%%
%Performance: Test learner against new tour

% dh2 = nlos_datahandler();
% dh2 = dh2.init_AMS_02();
% dataset2 = dh2.select_constellations(dh2.data, GPS_flag, GAL_flag, GLO_flag);
% [predictors2, response2] = nlos_feature_extractor.extract_standard_features(dataset2);
% response2_mat = table2array(response2);
% 
% for i = 1:length(learner.Trained)
%     model = learner.Trained{i};
%     validationPredictions2 = predict(model, predictors2);
%     nlos_performance.hard_classification_report(response2_mat,validationPredictions2);
% end




