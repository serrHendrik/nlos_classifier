classdef nlos_feature_extractor
    % Using the datatable provided by the nlos_datahandler, the feature
    % extractor will extract the predictor variables and the response
    % variable. 
    % There are also methods present to extract and prepare featuers for 
    % deep learning, which requires a slightly different format.
    %
    % To select standard features, see the get_basic_features() method!
    
    properties
    end
    
    methods(Static)
        
        function [predictors, response] = extract_standard_features(datatable)

            %Base Predictors and response
            [predictors, response] = nlos_feature_extractor.get_basic_features(datatable);
            
            %Provide user feedback
            nlos_feature_extractor.print_extracted_features(predictors);
            
        end
        
        function [predictors_deep, response_deep] = extract_standard_features_deep_learning(datatable)
            
            %Base Predictors and response
            [predictors, response] = nlos_feature_extractor.get_basic_features(datatable);
            
            %Adapt datatypes
            [predictors_deep, response_deep] = nlos_feature_extractor.prepare_deep_vars(predictors, response);
  
            %Provide user feedback
            nlos_feature_extractor.print_extracted_features(predictors);           
            
        end
        
        function [X_cnn, Y_cnn] = extract_standard_features_cnn(datatable, base_features, lag)
            
            %Predictors
            X_features = nlos_feature_extractor.get_X_features_cnn(base_features, lag);
            X = datatable(:, X_features);
            
            %Response
            Y_feature = {['los_',num2str(lag)]};
            Y = datatable(:, Y_feature);
            
            %adapt
            [X_cnn, Y_cnn] = nlos_feature_extractor.prepare_cnn_vars(X, Y, lag);
            
            %User feedback
            fprintf('\nCNN Features extraction done.\n');
            
            
        end
        
        function [predictors, response] = extract_features_set2(datatable)
            
            %Base Predictors and response
            [predictors, response] = nlos_feature_extractor.get_basic_features(datatable);
            
            %Add LLI
            predictors = nlos_feature_extractor.get_LLI(predictors,datatable.carrierphase);
            
            %Provide user feedback
            nlos_feature_extractor.print_extracted_features(predictors);

            
        end
        
        function [predictors_deep, response_deep] = extract_features_set2_deep_learning(datatable)
            
            %Base Predictors and response
            [predictors, response] = nlos_feature_extractor.get_basic_features(datatable);
            
            %Add LLI
            predictors = nlos_feature_extractor.get_LLI(predictors,datatable.carrierphase);
            
            %Adapt datatypes
            [predictors_deep, response_deep] = nlos_feature_extractor.prepare_deep_vars(predictors,response);
            
            %Provide user feedback
            nlos_feature_extractor.print_extracted_features(predictors); 
            
        end
        
        
        function [predictors, response] = extract_features_set3(datatable)
            
            %Base Predictors and response
            [predictors, response] = nlos_feature_extractor.get_basic_features(datatable);
            
            %Add LLI
            predictors = nlos_feature_extractor.get_LLI(predictors,datatable.carrierphase);
            
            %Add second order of third_ord_diff and innovations
            predictors = nlos_feature_extractor.get_TOD_sq(predictors);
            predictors = nlos_feature_extractor.get_inno_sq(predictors);
            
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
            
            %predictorNames = {'pseudorange', 'doppler', 'cnr', 'el', 'third_ord_diff', 'innovations'};
            predictorNames = {'cnr', 'el', 'innovations'};
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
            predictors_new.third_ord_diff_sq = sqrt(predictors_new.third_ord_diff .^2);
            
        end
        
        function [predictors_new] = get_inno_sq(predictors)
            
            predictors_new = predictors;
            predictors_new.innovations_sq = sqrt(predictors_new.innovations .^2);
            
        end
        
        function [predictors_deep, response_deep] = prepare_deep_vars(predictors,response)
            nb_feat = width(predictors);
            nb_samples = height(predictors);

            pred_mat = predictors{:,:};
            pred_mat = pred_mat';
            predictors_deep = reshape(pred_mat,nb_feat,1,1,nb_samples);

            resp_mat = response{:,:};
            response_deep = categorical(resp_mat,[0 1], {'0', '1'});     
            
        end
        
        function [predictors_cnn, response_cnn] = prepare_cnn_vars(predictors, response, lag)
            nb_feat = width(predictors) / lag;
            nb_samples = height(predictors);
            
            predictors_cnn = transpose(predictors{:,:});
            predictors_cnn = reshape(predictors_cnn,lag,nb_feat,1,nb_samples);
            %Features as channels
            %predictors_cnn = permute(predictors_cnn, [3 1 2 4]);
            %Features as rows
            predictors_cnn = permute(predictors_cnn, [2 1 3 4]);
            
            resp_mat = response{:,:};
            response_cnn = categorical(resp_mat,[0 1], {'0', '1'}); 
            
        end
        
        function X_features = get_X_features_cnn(base_features, lag)
            N = length(base_features);
            X_features = cell(1,N*lag);
            
            %Add all features with lag identifier
            for j = 1:length(base_features)
               for i = 1:lag
                   X_features{i + (j-1)*lag} = [base_features{j}, '_', num2str(i)];
               end
            end 
            
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

