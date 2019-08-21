classdef nlos_performance
    %NLOS_PERFORMANCE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
       
    end
    
    methods(Static)
        
        function validate_learner(learner, tour_train, tour_val, Xtrain, Ytrain, Xval, Yval)
            %Training data
            [Ytrain_predict, Ytrain_scores] = predict(learner,Xtrain);
            Ytrain_mat = table2array(Ytrain);
            train_title_info = ['TRAINGING SET ', tour_train];

            nlos_performance.hard_classification_report(Ytrain_mat,Ytrain_predict, train_title_info)
            %nlos_performance.nlos_roc(Ytrain_mat,Ytrain_scores, train_title_info);

            %Validation data
            [Yval_predict, Yval_scores] = predict(learner,Xval);
            Yval_mat = table2array(Yval);
            val_title_info = ['VALIDATION SET ', tour_val];

            nlos_performance.hard_classification_report(Yval_mat,Yval_predict, val_title_info);
            %nlos_performance.nlos_roc(Yval_mat,Yval_scores, val_title_info);

        end

        function hard_classification_report(Y,Yhat, plot_title)
            %Y = cell2mat(Y_cell);
            %Yhat_ = cell2mat(Yhat_cell);plot_title
           
            %Soft to hard prediction
            %Yhat = nlos_performance.soft_to_hard(Yhat_);
            
            %get basic stats
            [True_LOS, False_LOS, True_NLOS, False_NLOS] = nlos_performance.get_base_statistics(Y, Yhat);
            
            %Accuracy
            accuracy = nlos_performance.get_accuracy(True_LOS, False_LOS, True_NLOS, False_NLOS);

            %Precision
            [precision_LOS, precision_NLOS] = nlos_performance.get_precision(True_LOS, False_LOS, True_NLOS, False_NLOS);
            
            %Recall
            [recall_LOS, recall_NLOS] = nlos_performance.get_recall(True_LOS, False_LOS, True_NLOS, False_NLOS);

            %F1
            [F1_LOS, F1_NLOS] = nlos_performance.get_f1(precision_LOS, precision_NLOS, recall_LOS, recall_NLOS);
            
            %print results
            nlos_performance.print_hard_classification_report(precision_LOS, precision_NLOS, recall_LOS, recall_NLOS, F1_LOS, F1_NLOS, accuracy);
            
            %Show confusion table
            ind_ = strfind(plot_title, '_');
            title_modified = [plot_title(1:ind_-1) '\' plot_title(ind_:end)];
            Y_cat = categorical(Y, [0 1], {'NLOS', 'LOS'});
            Yhat_cat = categorical(Yhat, [0 1], {'NLOS', 'LOS'});
            figure;
            plotconfusion(Y_cat,Yhat_cat, title_modified);
            
        end
        
        function nlos_roc(Y,Yhat_scores, plot_title)
            
            %Compute ROC variables
            posClass = 1;
            [ROC_X,ROC_Y,ROC_T,AUC,OPTROCPT] = perfcurve(Y,Yhat_scores(:,2),posClass);
            
            ind_ = strfind(plot_title, '_');
            title_modified = [plot_title(1:ind_-1) '\' plot_title(ind_:end)];
            
            %Plot
            figure;
            plot(ROC_X,ROC_Y)
            hold on
            plot(OPTROCPT(1),OPTROCPT(2),'ro')
            xlabel('False LOS rate') 
            ylabel('True LOS rate')
            title([title_modified, ' ROC Curve (AUC = ', num2str(AUC), ')'])
            hold off
        end
        
        function nlos_roc_multiple(X, Y, learners, learner_names, plot_title)
            
            ind_ = strfind(plot_title, '_');
            title_modified = [plot_title(1:ind_-1) '\' plot_title(ind_:end)];
            posClass = 1;
            
            %Plot
            figure;
            hold on
            for k = 1:length(learners)
                learner = learners{k};
                [~, Yscores] = predict(learner,X);
                [ROC_X,ROC_Y,ROC_T,AUC,OPTROCPT] = perfcurve(Y,Yscores(:,2),posClass);
                name = strcat(learner_names(k), ' [AUC=', num2str(AUC), ']');
                plot(ROC_X,ROC_Y, 'DisplayName', name);
            end
            xlabel('False LOS rate') 
            ylabel('True LOS rate')
            legend('-DynamicLegend', 'Location','Best')
            title([title_modified, ' ROC Curve'])
            hold off           
            
            
        end
        
        function Yhat_onehot_hard = soft_to_hard(Yhat_onehot_soft)
            Yhat_onehot_hard = Yhat_onehot_soft;
            
            for i = 1:size(Yhat_onehot_hard,2)
                if Yhat_onehot_soft(1,i) > Yhat_onehot_soft(2,i)
                    Yhat_onehot_hard(1,i) = 1;
                    Yhat_onehot_hard(2,i) = 0;
                else
                    Yhat_onehot_hard(1,i) = 0;
                    Yhat_onehot_hard(2,i) = 1;
                end
            end            
        end
    end
    
    methods(Static, Access = private)
        function [True_LOS, False_LOS, True_NLOS, False_NLOS] = get_base_statistics(Y,Yhat)
            True_LOS = 0;
            False_LOS = 0;
            True_NLOS = 0;
            False_NLOS = 0;
            for i = 1:length(Y)
                if Y(i) == 1 %LOS
                    if Y(i) == Yhat(i)
                       True_LOS = True_LOS + 1;
                    else
                       False_NLOS = False_NLOS + 1;
                    end

                else  %NLOS
                    if Y(i) == Yhat(i)
                       True_NLOS = True_NLOS + 1;
                    else
                       False_LOS = False_LOS + 1;
                    end        
                end
            end
            
        end
        
        function accuracy = get_accuracy(True_LOS, False_LOS, True_NLOS, False_NLOS)
            
           accuracy = (True_LOS + True_NLOS) / (True_LOS + True_NLOS + False_LOS + False_NLOS);
           
        end
        
        % precision_LOS is the ratio of correctly classified LOS to all LOS classifications.
        function [precision_LOS, precision_NLOS] = get_precision(True_LOS, False_LOS, True_NLOS, False_NLOS)
           
            precision_LOS = True_LOS / (True_LOS + False_LOS);
            precision_NLOS = True_NLOS / (True_NLOS + False_NLOS);
            
        end
        
        % recall_LOS is the ratio of correctly classified LOS to all existing LOS signals
        function [recall_LOS, recall_NLOS] = get_recall(True_LOS, False_LOS, True_NLOS, False_NLOS)
            
            recall_LOS = True_LOS / (True_LOS + False_NLOS);
            recall_NLOS = True_NLOS / (True_NLOS + False_LOS);
            
        end
        
        %F1 score: Harmonic average of precision and recall
        function [F1_LOS, F1_NLOS] = get_f1(precision_LOS, precision_NLOS, recall_LOS, recall_NLOS)
            
            F1_LOS = 2 * (precision_LOS * recall_LOS) / (precision_LOS + recall_LOS);
            F1_NLOS = 2 * (precision_NLOS * recall_NLOS) / (precision_NLOS + recall_NLOS);
            
        end
        
        function print_hard_classification_report(precision_LOS, precision_NLOS, recall_LOS, recall_NLOS, F1_LOS, F1_NLOS, accuracy)
            
            fprintf('LOS/NLOS Hard Classification Report:\n');
            fprintf('          Precision          Recall          F1\n');
            fprintf('LOS       %.2f               %.2f            %.2f\n', precision_LOS, recall_LOS, F1_LOS);
            fprintf('NLOS      %.2f               %.2f            %.2f\n', precision_NLOS, recall_NLOS, F1_NLOS);
            fprintf('\nOverall Accuracy: %.2f\n\n', accuracy); 
            
        end
        
        
    end
end

