classdef nlos_feature_extractor
    %PREPROCESSING Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Static)
        
        function [predictors, response] = extract_standard_features(datatable)

            predictorNames = {'pseudorange', 'carrierphase', 'cnr', 'doppler', 'el', 'third_ord_diff', 'innovations'};
            responseName = {'los'};
            predictors = datatable(:, predictorNames);
            response = datatable(:,responseName);
            
            %User feedback:
            fprintf('\n')
            disp('Features Extracted:')
            for i = 1:length(predictorNames)
               fprintf('%s ', predictorNames{i})
            end
            fprintf('\n')
            
        end
        
        function [predictors, response] = extract_features_set2(datatable)
            
            %Base Predictors and response
            [predictors, response] = nlos_feature_extractor.get_basic_features(datatable);
            
            %Add LLI
            predictors = nlos_feature_extractor.get_LLI(predictors,datatable.carrierphase);
            
            %Provide user feedback
            nlos_feature_extractor.print_extracted_features(predictors);

            
        end
        
        function [predictors, response] = extract_features_set3(datatable)
            
            %Base Predictors and response
            [predictors, response] = nlos_feature_extractor.get_basic_features(datatable);
            
            %Add LLI
            predictors = nlos_feature_extractor.get_LLI(predictors,datatable.carrierphase);
            
            %Add second order of third_ord_diff and innovations
            predictors = get_TOD_sq(predictors);
            predictors = get_inno_sq(predictors);
            
            %Provide user feedback
            nlos_feature_extractor.print_extracted_features(predictors);
            
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
    
    methods(Static, Access = private)
        function [predictors, response] = get_basic_features(datatable)
            
            predictorNames = {'pseudorange', 'cnr', 'el', 'third_ord_diff', 'innovations'};
            responseName = {'los'};
            
            predictors = datatable(:, predictorNames);
            response = datatable(:,responseName);
            
        end
        
        function [predictors_new] = get_LLI(predictors,CP)

            lli_var = CP == 0;
            lli_table = table(lli_var, 'VariableNames',{'lli'});
            predictors_new = [predictors lli_table];
            
        end
        
        function [predictors_new] = get_TOD_sq(predictors)
            
            predictors_new = predictors;
            predictors_new.third_ord_diff_sq = predictors_new.third_ord_diff .^2;
            
            
        end
        
        function [predictors_new] = get_inno_sq(predictors)
            
            predictors_new = predictors;
            predictors_new.innovations_sq = predictors_new.innovations .^2;
            
        end
        
        function print_extracted_features(predictors)
            
            %User feedback:
            fprintf('\n')
            disp('Features Extracted:')
            for i = 1:length(predictors.Properties.VariableNames)
               fprintf('%s ', predictors.Properties.VariableNames{i})
            end
            fprintf('\n')
            
        end

    end
end

