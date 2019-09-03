classdef nlos_postprocessing
    %Postprocessing currently involves storing the unscaled datatable
    %together with a learners soft and hard classification output.
    %
    % An example can be found in nls_learners_trees.m
    
    properties 
    end
    
    methods(Static)

        function data_pp = store_results(data, los_hard, los_soft, full_filename_output)
            
            data_pp = data;
            
            %change name of 'los' column
            data_pp.Properties.VariableNames{end} = 'los_camera';
            
            %add ML hard los
            data_pp.los_ml_hard = los_hard;
            
            %add ML soft los
            data_pp.los_ml_soft = los_soft;
            
            %store new table
            if ~isfile(full_filename_output)
                writetable(data_pp,full_filename_output);
                disp('Output table stored. Postprocessing done.');
            else
                disp('File already exists. Remove it first if you want to produce a new one.')
            end
            
        end
    end
end

