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

%%
%Feature Engineering

%Select constellations
GPS_flag = true;
GAL_flag = false;
GLO_flag = false;

%Standard features
[predictors, response] = nlos_feature_extractor.extract_standard_features(dh.data, GPS_flag, GAL_flag, GLO_flag);


%%
%Train Learner

% Model 2.1: Decision Tree
%learner = nlos_models.classification_tree(predictors, response);

%Model 2.2: Linear Discriminant Analysis
%learner = nlos_models.discriminant_linear(predictors, response);

%Model 2.3: Quadratic Discriminant Analysis
%learner = nlos_models.discriminant_quadratic(predictors, response);

%Model 2.4: K-Nearest Neighbours (Euclidean distance)
%learner = nlos_models.knn_euclidean(predictors, response);

%Model 2.5: K-Nearest Neighbours (Euclidean distance, Squared-Inverse distance weighing)
learner = nlos_models.knn_euclidean_SIweight(predictors, response);

%Model 2.6: K-Nearest Neighbours (Minkowski distance)
%learner = nlos_models.knn_minkowski(predictors, response);




%Model 2.X: Linear SVM
%Note: needs to be adapted to work on big dataset
%learner = nlos_models.svm_linear(predictors, response);

%%
%Performance

%Predict
[validationPredictions, validationScores] = kfoldPredict(learner);

%Report
response_mat = table2array(response);
nlos_performance.hard_classification_report(response_mat,validationPredictions);

%%
%Performance: Test learner against new tour

dh2 = nlos_datahandler();
dh2 = dh2.init_AMS_02();
[predictors2, response2] = nlos_feature_extractor.extract_standard_features(dh2.data);
response2_mat = table2array(response2);

for i = 1:length(learner.Trained)
    model = learner.Trained{i};
    validationPredictions2 = predict(model, predictors2);
    nlos_performance.hard_classification_report(response2_mat,validationPredictions2);
end




