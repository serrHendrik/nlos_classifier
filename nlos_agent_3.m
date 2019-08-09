%nlos_agent_3 info:
%input: {'pseudorange', 'cnr', 'doppler', 'az', 'az_cm', 'el', 'el_cm'}
%model: Classification tree
%output: {'los'}
%performance: (hard classification) Precision, Recall, F1, Accuracy

%%
%Datahandler

%Create datahandler
dh = nlos_datahandler();

%init datahandler with a predefined tour.
dh = dh.init_AMS_01();

%%
%Feature Engineering

%Standard features
[predictors, response] = nlos_preprocessing.extract_standard_features(dh.data);


%%
%Learner

% Model 2: Decision Tree
% Train
learner = nlos_models.discriminant_linear(predictors, response);

%%
%Performance

%Predict
[validationPredictions, validationScores] = kfoldPredict(learner);

%Report
response_mat = table2array(response);
nlos_performance.hard_classification_report(response_mat,validationPredictions);



