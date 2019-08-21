classdef nlos_feature_extractor
    %PREPROCESSING Summary of this class goes here
    %   Detailed explanation goes here
    
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
        
        function [predictors_CNN, response_CNN] = extract_features_CNN(datatable, constellation_info, lag)
            %TODO
            %Create row with time delay, delete rows with time larger than lag
            %save load (perhaps create new datahandler?)
            
            
            %init feature table
            %base_features = {'common_time', 'pseudorange', 'carrierphase', 'cnr', 'doppler', 'az', 'el', 'innovations'};
            base_features = {'pseudorange', 'cnr', 'doppler', 'el', 'innovations'};
            [sv_feature_table_template, X_features, Y_feature] = nlos_feature_extractor.init_cnn_feature_table(lag, base_features);
            feature_table = sv_feature_table_template;
            
            for c = 'GER'
                ids = constellation_info.(c).allSv;
                for i = 1:length(ids)
                    sv_id = ids(i);
                    %sv table
                    mask_part1 = (cell2mat(datatable.sv_sys) == c);
                    mask_part2 = (datatable.sv_id == sv_id);
                    sv_table_mask = mask_part1 & mask_part2;
                    sv_base_table = datatable(sv_table_mask, :);
                    
                    %extract new features
                    sv_feature_table = nlos_feature_extractor.extract_features_CNN_for_sv(c, sv_id, sv_base_table, lag, base_features, sv_feature_table_template);
                    
                    %expand feature table
                    feature_table = [feature_table; sv_feature_table];
                    
                end
            end
            
            %Select predictors and response
            predictors_CNN = feature_table(:,X_features);
            response_CNN = feature_table(:,Y_feature);
            
            
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
            predictorNames = {'cnr', 'innovations'};
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
        
        function [feature_table, X_features, Y_feature] = init_cnn_feature_table(lag, base_features)
            
            N = length(base_features);
            X_features = cell(1,N*lag);
            
            %Add all features with lag identifier
            for j = 1:length(base_features)
               for i = 1:lag
                   X_features{i + (j-1)*lag} = [base_features{j}, '_', num2str(i)];
               end
            end
            
            %Add sat_sys and sat_id and label
            Y_feature = {['los_', num2str(lag)]};
            all_features = [{'sat_sys'}, {'sat_id'}, X_features, Y_feature];
            
            %init table
            table_width = length(all_features);
            feature_table = cell2table(cell(0,table_width),'VariableNames',all_features);
            
            
        end
        
        function sv_feature_table = extract_features_CNN_for_sv(sv_sys, sv_id, sv_table, lag, base_features, sv_feature_table_template)
            
            sv_feature_table = sv_feature_table_template;
            N = height(sv_table);
            
            if (N >= lag)
                
                for i = 1:N-lag+1
                    
                    row_mat = sv_table{i:i+lag-1, base_features};
                    row_cell = num2cell(transpose(row_mat(:)));
                    label = sv_table(i+lag-1,{'los'});
                    row = [{sv_sys}, {sv_id}, row_cell, {label}];
                    
                    sv_feature_table = [sv_feature_table; row];
                    
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

