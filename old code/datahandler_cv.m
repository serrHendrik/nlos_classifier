classdef datahandler_cv
    %DATAHANDLER_CV Summary of this class goes here
    % Cross-Validation (CV) is used by this datahandler to split the data
    % into training and test sets
    
    properties
        data_table
        labels_table
        k_cv
        cv
    end
    
    methods
        function obj = datahandler_cv(data_table,labels_table,k_cv)
            %DATAHANDLER Construct an instance of this class
            %   Detailed explanation goes here
            
            if (size(data_table,1) ~= size(labels_table,1))
                error('number of data points must be equal to number of labels')
            else
                obj.data_table = data_table;
                obj.labels_table = labels_table;
                
                if (nargin == 3)
                    obj.k_cv = k_cv;
                else
                    obj.k_cv = 10;
                end

                obj.cv = cvpartition(size(data_table,1),'KFold',k_cv);
            end
            
        end
        
        function [X_train, Y_train, X_test, Y_test] = split_train_and_test(obj,i)
            %Input:
            %   i: index of k-fold cross validation. 1 <= i <= k_cv
            
            idx_train = obj.cv.training(i);
            idx_test = obj.cv.test(i);
            % Separate to training and test data
            X_train = obj.data_table(idx_train,:);
            Y_train = obj.labels_table(idx_train,:);
            X_test  = obj.data_table(idx_test,:);
            Y_test = obj.labels_table(idx_test,:);
            
        end
    end
end

