%%
%Datahandler

%Select constellations
GPS_flag = false;
GAL_flag = true; 
GLO_flag = false;

%Select TRAINING tour
tour_train = 'AMS_01';
%tour_train = 'AMS_02';
%tour_train = 'ROT_01';
%tour_train = 'ROT_02';

%Select VALIDATION tour
%tour_val = 'AMS_01';
tour_val = 'AMS_02';
%tour_val = 'ROT_01';
%tour_val = 'ROT_02';

%Normalize numeric predictors?
normalize_flag = false;

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
[Xtrain, Ytrain] = nlos_feature_extractor.extract_standard_features(Dtrain);
[Xval, Yval] = nlos_feature_extractor.extract_standard_features(Dval);

%Feature set 2
%[Xtrain, Ytrain] = nlos_feature_extractor.extract_features_set2(Dtrain);
%[Xval, Yval] = nlos_feature_extractor.extract_features_set2(Dval);

%Feature set 3
%[Xtrain, Ytrain] = nlos_feature_extractor.extract_features_set3(Dtrain);
%[Xval, Yval] = nlos_feature_extractor.extract_features_set3(Dval);

%%
%auto-tune (takes a long time)

% rng('default')
% t = templateTree('Reproducible',true);
% Mdl = fitcensemble(Xtrain, Ytrain,'OptimizeHyperparameters','auto','Learners',t, ...
%     'HyperparameterOptimizationOptions',struct('AcquisitionFunctionName','expected-improvement-plus'))

%Result
%Method: Bag
%NumLearningCycles: 484
%MinLeafSiz 2

%%
%Model 1

tt = templateTree(...
    'MaxNumSplits', 100, ...
    'MinLeafSize', 1);

learner1 = fitcensemble(...
    Xtrain, ...
    Ytrain, ...
    'Method', 'RUSBoost', ...
    'Learners', tt, ...
    'NumLearningCycles',200);

%Methods: AdaBoostM1, RUSBoost, RobustBoost, GentleBoost, LogitBoost,
%           LPBoost, Bag
% Bag superior accuracy but very class imbalanced performance
% RUSBoost best class balance, but still not very good for NLOS.
%%
%Performance learner1

nlos_performance.validate_learner(learner1, tour_train, tour_val, Xtrain, Ytrain, Xval, Yval)



figure;
plot(loss(learner1,Xval,Yval,'mode','cumulative'))
xlabel('Number of trees')
ylabel('Validation classification error')



%%
% 
% %KNN Ensemble
% %Performs very poor
% 
% %%
% % Find best K
% N = height(Xtrain);
% rng(8000,'twister') % for reproducibility
% %K = round(logspace(0,log10(N/10),10)); % number of neighbors 
% K = [5 10 13 14 15 16 17 20 25 30];
% 
% cvloss = zeros(numel(K),1);
% for k=1:numel(K)
%     knn = fitcknn(Xtrain,Ytrain,...
%         'NumNeighbors',K(k),...
%         'ClassNames', [0; 1],...
%         'KFold',10);
%     
%     cvloss(k) = kfoldLoss(knn);
% end
% figure; % Plot the accuracy versus k
% semilogx(K,cvloss);
% xlabel('Number of nearest neighbors');
% ylabel('10 fold classification error');
% title('k-NN classification');
% 
% 
% %%
% %Find ensemble size
% bestK = 10;
% 
% tempKNN = templateKNN('NumNeighbors',bestK);
% ens = fitcensemble(Xtrain,Ytrain,'Method','Subspace','Learners',tempKNN,'CrossVal','on');
% figure; % Plot the accuracy versus number in ensemble
% plot(kfoldLoss(ens,'Mode','Cumulative'))
% xlabel('Number of learners in ensemble');
% ylabel('10 fold classification error');
% title('k-NN classification with Random Subspace');
% 
% %%
% %Final ensemble
% bestEnsembleSize = 50;
% 
% tempKNN = templateKNN('NumNeighbors',bestK);
% ens = fitcensemble(Xtrain,Ytrain,'Method','Subspace','NumLearningCycles',bestEnsembleSize,...
%     'Learners',tempKNN);
% cens = compact(ens);
% s1 = whos('ens');
% s2 = whos('cens');
% [s1.bytes s2.bytes] % si.bytes = size in bytes
% 
% %%
% % Validating
% 
% nlos_performance.validate_learner(cens, tour_train, tour_val, Xtrain, Ytrain, Xval, Yval)
