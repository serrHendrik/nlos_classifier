
% Support Vector Machines

%%
%Data

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

%Subsampling required for SVM (otherwise very long training time)
[data_subset, data_rest] = dh.sample_data(dataset, 4);
dh.print_info_per_const(data_subset);

%%
%feature selection

[predictors, response] = nlos_feature_extractor.extract_standard_features(data_subset);

%%
% Train learner

%Model: Linear SVM
%learner = nlos_models.svm_linear(predictors, response);

%Model: RBF SVM
learner = nlos_models.svm_rbf(predictors, response);

%%
% Performance

%Predict
[validationPredictions, validationScores] = kfoldPredict(learner);

%Report
response_mat = table2array(response);
nlos_performance.hard_classification_report(response_mat,validationPredictions);





