classdef nlos_agent
    %NLOS_AGENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        dh              %datahandler
        
    end
    
    methods
        function obj = nlos_agent(data_table, labels_table, k_cv)
           
            obj.dh = datahandler_cv(data_table, labels_table, k_cv);
            
            
            
        end

    end
end

