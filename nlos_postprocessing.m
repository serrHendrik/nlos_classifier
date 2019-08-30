classdef nlos_postprocessing
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
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
            writetable(data_pp,full_filename_output);
            disp('Postprocessing done.');
           
            
        end
    end
end

