classdef label_parser
    %LABEL_PARSER Summary of this class goes here
    %   Given the filename from the Fisheye output file, this parser
    %   extracts the labels. 
    %
    %   Parser currently not used anymore (See nlos_datahandler instead).
    
    properties
        full_filename_FEdata
        full_filename_output     %file to write labels_table
        FEdata
        labels_table
    end
    
    methods
        function obj = label_parser(file_location, filename_FEdata, filename_output)
            %LABEL_PARSER Construct an instance of this class
            %   Detailed explanation goes here
            
            obj.full_filename_FEdata = strcat(file_location, filename_FEdata);
            obj.full_filename_output = strcat(file_location, filename_output);
            
            %load FE data
            obj.FEdata = load(obj.full_filename_FEdata);
            
            %Construct labels_table if it doesn't exist yet
            if isfile(obj.full_filename_output)
                obj = obj.load_labels_table();
            else
                obj = obj.construct_labels_table();
                obj.save_labels_table();
            end
            
            
        end
        
        function obj = construct_labels_table(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            
            GPS = obj.FEdata.sampleLine.G;
            GAL = obj.FEdata.sampleLine.E;
            GLO = obj.FEdata.sampleLine.R;
            navGPS = obj.FEdata.nav.G;
            navGAL = obj.FEdata.nav.E;
            navGLO = obj.FEdata.nav.R;
            
            total_sats = length(obj.FEdata.nav.allSv);
            
            ISLOS = [GPS.islos; GAL.islos ; GLO.islos];
            ISLOS = ISLOS(:);
            
            time_steps = length(obj.FEdata.commonTime);
            time_rep = repmat(obj.FEdata.commonTime',total_sats,1);
            time_rep = time_rep(:);
            
            %SV id's
            allSv = [navGPS.allSv; navGAL.allSv; navGLO.allSv];
            sv_rep = repmat(allSv,time_steps,1);
            
            %Satellite systems
            GPS_rep = repmat('G',length(navGPS.allSv),1);
            GAL_rep = repmat('E',length(navGAL.allSv),1);
            GLO_rep = repmat('R',length(navGLO.allSv),1);
            SYS_rep = repmat([GPS_rep; GAL_rep; GLO_rep],time_steps,1);
            
            varNames = {'time', 'sv_sys', 'sv_id', 'los'};
            obj.labels_table = table(time_rep,SYS_rep,sv_rep, ISLOS, ...
                'VariableNames', varNames);
            
            %filter table
            sat_mask = isnan(obj.labels_table.los(:)); 
            obj.labels_table = obj.labels_table(~sat_mask,:);
            
        end
        
        function save_labels_table(obj)
            
            disp('Writing labels data table...')
            writetable(obj.labels_table,obj.full_filename_output)
            disp('Done!')
            
        end
        
        function obj = load_labels_table(obj)
            disp('Loading labels data table...')
            obj.labels_table = readtable(obj.full_filename_output);
            disp('Done!')          
        end
        
    end
end

