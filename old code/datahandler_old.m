classdef datahandler_old
    %DATAHANDLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        file_location
        filename_obs
        filename_FEdata
        filename_output
        parser_obs
        parser_azel
        parser_labels
    end
    
    methods
        function obj = datahandler(file_location, filename_obs, filename_FEdata, filename_output)
            %init attributes
            obj.file_location = file_location;
            obj.filename_obs = filename_obs;
            obj.filename_FEdata = filename_FEdata;
            obj.filename_output = filename_output;
            
            %parse observation data
            obj.parser_obs = obs_parser(obj.file_location, obj.filename_obs, 'obs_table.csv');
            
            %parse azimuth/elevation data
            obj.parser_azel = azel_parser(obj.file_location, obj.filename_FEdata, 'azel_table.csv');
            
            %parse labels data
            obj.parser_labels = label_parser(obj.file_location, obj.filename_FEdata, 'labels_table.csv');
            
            %This datahandler is incomplete
            %The three generated tables still need to be merged.
            
            
        end
        
    end
end

