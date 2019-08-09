classdef nlos_preprocessing
    %PREPROCESSING Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Static)
        function [predictors, response] = extract_standard_features(datatable)
            
            predictorNames = {'pseudorange', 'cnr', 'doppler', 'az', 'az_cm', 'el', 'el_cm'};
            responseName = {'los'};
            predictors = datatable(:, predictorNames);
            response = datatable(:,responseName);
            
        end
        
        function [Xtrain, Ytrain, Xtest, Ytest] = prepare_holdout_nn(datatable, X_cols, Y_col, holdout_p)
           
            %split data in training and testing set, equally representing
            %the target classes in both sets.
            cv = cvpartition(datatable{:,Y_col},'HoldOut',holdout_p);

            %Vars for 'tonndata' method
            columnSamples = false; % are samples by column?.
            cellTime = false;     % time-steps in matrix (and not cell array).

            %Note: one-hot encoding for labels
            %Training set
            Xtrain_mat = datatable{cv.training,X_cols};
            Ytrain_mat = [datatable{cv.training,Y_col} ~datatable{cv.training,Y_col}];
            [Xtrain,Xtrain_wasMatrix] = tonndata(Xtrain_mat,columnSamples,cellTime);
            [Ytrain,Ytrain_wasMatrix] = tonndata(Ytrain_mat,columnSamples,cellTime);

            %Test set
            Xtest_mat = datatable{cv.test,X_cols};
            Ytest_mat = [datatable{cv.test,11} ~datatable{cv.test,Y_col}];
            [Xtest,Xtest_wasMatrix] = tonndata(Xtest_mat,columnSamples,cellTime);
            [Ytest,Ytest_wasMatrix] = tonndata(Ytest_mat,columnSamples,cellTime);

        end
    end
end

