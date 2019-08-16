%nlos_agent_1 info:
%input: {'pseudorange', 'cnr', 'doppler', 'az', 'az_cm', 'el', 'el_cm'}
%model: feedforwardnet
%output: {'los', 'nlos'}
%performance: (hard classification) Precision, Recall, F1, Accuracy

%%
%Initiate datatable

%Create handle to datahandler
dh = nlos_datahandler();
%init datahandler with a predefined tour.
dh = dh.init_AMS_01();

%%
%Define train and test set

%Hold out fraction p for testing.
p = 0.2;
X_cols = 4:10;
Y_col = 11;
[trainX, trainY, testX, testY] = nlos_preprocessing.prepare_holdout_nn(dh.data, X_cols, Y_col, p);

%%
% Model 1: Neural network

net = feedforwardnet([10 8]);
%view(net)
net = configure(net, trainX, trainY);
%view(net)
net = train(net, trainX, trainY);



%%
%Performance

%Predict
pred_testY = net(testX);

%Cell to matrix
testY_mat = cell2mat(testY);
pred_testY_mat = cell2mat(pred_testY);

%soft prediction to hard classification
hard_pred_testY_mat = nlos_performance.soft_to_hard(pred_testY);

%convert one-hot enconding to normal
testY_ = testY(1,:);
hard_pred_testY_ = hard_pred_testY_(1,:);

nlos_performance.hard_classification_report(testY_,hard_pred_testY_);



