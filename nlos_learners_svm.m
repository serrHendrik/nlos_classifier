% Support Vector Machines

%%
%Select constellations
GPS_flag = true;
GAL_flag = false; 
GLO_flag = false;

%Select tour
%tour = 'AMS_01';
%tour = 'AMS_02';
tour = 'ROT_01';
%tour = 'ROT_02';

%Create datahandler
dh = nlos_datahandler(tour, GPS_flag, GAL_flag, GLO_flag);

%Extract final dataset from datahandler
dataset = dh.data;

%Sampling
%Subsampling required for SVM (otherwise very long training time)
%[data_subset, data_rest] = dh.sample_data_timewise(dataset, 10);
dh.print_info_per_const(data_subset);

%%
%feature selection

%Standard features
%[predictors, response] = nlos_feature_extractor.extract_standard_features(data_subset);

%Feature set 2
[predictors, response] = nlos_feature_extractor.extract_features_set2(dataset);

%%
% Train learner

%Model: Linear SVM
%learner = nlos_models.svm_linear(predictors, response);

%Model: RBF SVM
learner = nlos_models.svm_rbf(predictors, response);

%Model: RBF SVM 2
%learner = nlos_models.svm_rbf2(predictors, response);

%Model: Polynomial (order 2) SVM
%learner = nlos_models.svm_poly2(predictors, response);

%Model: Polynomial (order 3) SVM
%learner = nlos_models.svm_poly3(predictors, response);

%%
% Performance

%Predict
[validationPredictions, validationScores] = kfoldPredict(learner);

%Report
response_mat = table2array(response);
nlos_performance.hard_classification_report(response_mat,validationPredictions, tour);






