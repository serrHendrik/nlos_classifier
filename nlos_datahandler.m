classdef nlos_datahandler
    %NLOS_DATAHANDLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = private)
        dataset_name
        file_location
        filename_FEdata
        filename_output
        FEdata
    end
    properties
        data
    end
    properties(Dependent)
        full_filename_FEdata
        full_filename_output  
        time_start              %in seconds
        time_end                %in seconds
        time_total              %in seconds
        labelled_sats
        fraction_los
        fraction_nlos
        
    end
    
    methods
        function obj = nlos_datahandler()
            %empty constructor
            %call the apropriate init function after creating an object.
        end
        
        %init function for AMS_01 dataset
        function obj = init_AMS_01(obj)
            obj.dataset_name = 'AMS_01';
            obj.file_location = 'data/AMS_01/';
            obj.filename_FEdata = 'outputVars_EXP01_AMS_2018.mat';
            obj.filename_output = 'AMS_01_datatable.csv';
            
            obj = obj.init_datahandler();
        end
        
        function obj = init_AMS_02(obj)
            obj.dataset_name = 'AMS_02';
            obj.file_location = 'data/AMS_02/'; 
            obj.filename_FEdata = 'outputVars_EXP02_AMS_2018.mat';
            obj.filename_output = 'AMS_02_datatable.csv';
            
            obj = obj.init_datahandler();
        end
        
        function obj = init_ROT_01(obj)
            obj.dataset_name = 'ROT_01';
            obj.file_location = 'data/ROT_01/'; 
            obj.filename_FEdata = 'outputVars_EXP01_ROT_2018.mat';
            obj.filename_output = 'ROT_01_datatable.csv';
            
            obj = obj.init_datahandler();            
        end
        
        function obj = init_ROT_02(obj)
            obj.dataset_name = 'ROT_02';
            obj.file_location = 'data/ROT_02/'; 
            obj.filename_FEdata = 'outputVars_EXP02_ROT_2018.mat';
            obj.filename_output = 'ROT_02_datatable.csv';
            
            obj = obj.init_datahandler();            
        end
        
        
        function v = get.full_filename_FEdata(obj)
            v = strcat(obj.file_location,obj.filename_FEdata);
        end
        
        function v = get.full_filename_output(obj)
            v = strcat(obj.file_location,obj.filename_output);
        end

        function v = get.time_start(obj)
            v = obj.data.common_time(1);
        end
        
        function v = get.time_end(obj)
            v = obj.data.common_time(length(obj.data.common_time));
        end
        
        function v = get.time_total(obj)
           v = obj.time_end - obj.time_start; 
        end
        
        function v = get.labelled_sats(obj)
           v = sum(~isnan(obj.data.los)); 
        end
        
        function v = get.fraction_los(obj)
           v = sum(obj.data.los) / length(obj.data.los); 
        end
        
        function v = get.fraction_nlos(obj)
           v = 1 - obj.fraction_los;
        end
        
    end
    methods (Access = private)
        
        function obj = init_datahandler(obj)
            %DATAHANDLER_V2 Construct an instance of this class
            %   Detailed explanation goes here
            
            
            %load FEdata
            obj.FEdata = load(obj.full_filename_FEdata);
            
            %parse FEdata to table
            obj = obj.construct_table();
            
            %Construct data table if it doesn't exist yet
            if isfile(obj.full_filename_output)
                disp('Output file already exists.')
                obj = obj.load_data_table();
            else
                disp('Constructing data table...')
                obj = obj.construct_table();
                obj.save_data_table();
            end
            
            %Info on dataset
            fprintf('\n*** Dataset Info ***\n');
            fprintf('Dataset name: %s\n', obj.dataset_name);
            fprintf('Duration of trip [HH:MM:SS]: %s\n', datestr(seconds(obj.time_total),'HH:MM:SS'));
            fprintf('Number of labelled satellites: %d\n', obj.labelled_sats);
            fprintf('Fraction of satellites labelled LOS: %.2f\n', obj.fraction_los);
            fprintf('Fraction of satellites labelled NLOS: %.2f\n', obj.fraction_nlos);
            fprintf('********************\n');
        end
        
        function obj = construct_table(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            
            %key (time, sv_sys, sv_id)
            key_table = obj.get_key_table();
            
            %observations
            obs_table = obj.get_obs_table();
            
            %azimuth and elevation
            azel_table = obj.get_azel_table();
            
            %labels
            labels_table = obj.get_labels_table();
            
            %merge tables
            obj.data = [key_table obs_table azel_table labels_table];
            
            %filter data
            nan_mask = isnan(obj.data.los(:)); 
            obj.data = obj.data(~nan_mask,:);
            
        end
        
        function key_table = get_key_table(obj)
           
            GPS = obj.FEdata.aZeLStructure.G;
            GAL = obj.FEdata.aZeLStructure.E;
            GLO = obj.FEdata.aZeLStructure.R;
            
            total_sats = size(GPS.allSv,1) + size(GAL.allSv,1) + size(GLO.allSv,1); 
            
            %time
            time_rep = repmat(obj.FEdata.commonTime',total_sats,1);
            time_rep = time_rep(:);
            
            %Satellite systems
            GPS_rep = repmat('G',size(GPS.allSv,1),1);
            GAL_rep = repmat('E',size(GAL.allSv,1),1);
            GLO_rep = repmat('R',size(GLO.allSv,1),1);
            SYS_rep = repmat([GPS_rep; GAL_rep; GLO_rep],size(GPS.time,2),1);
            
            %sv id's
            allSv = [GPS.allSv; GAL.allSv; GLO.allSv];
            sv_rep = repmat(allSv,length(GPS.time),1);
            
            
            key_names = {'common_time', 'sv_sys', 'sv_id'};
            key_table = table(time_rep, SYS_rep, sv_rep, ...
                'VariableNames', key_names);
           
        end
        
        function obs_table = get_obs_table(obj)
            GPS = obj.FEdata.nav.G;
            GAL = obj.FEdata.nav.E;
            GLO = obj.FEdata.nav.R;
            
            pseudorange = [GPS.matObs; GAL.matObs; GLO.matObs];
            cnr = [GPS.matCN0; GAL.matCN0; GLO.matCN0];
            doppler = [GPS.matDop; GAL.matDop; GLO.matDop];
            
            pseudorange = pseudorange(:);
            cnr = cnr(:);
            doppler = doppler(:);
            
            obs_names = {'pseudorange', 'cnr', 'doppler'};
            obs_table = table(pseudorange, cnr, doppler, ...
                'VariableNames', obs_names);
            
        end
        
        function azel_table = get_azel_table(obj)
            GPS = obj.FEdata.aZeLStructure.G;
            GAL = obj.FEdata.aZeLStructure.E;
            GLO = obj.FEdata.aZeLStructure.R;

            Az = [GPS.Az; GAL.Az; GLO.Az];
            AzCm = [GPS.AzCm; GAL.AzCm; GLO.AzCm];
            El = [GPS.El; GAL.El; GLO.El];
            ElCm = [GPS.ElCm; GAL.ElCm; GLO.ElCm];
            
            Az = Az(:);
            AzCm = AzCm(:);
            El = El(:);
            ElCm = ElCm(:); 
            
            azel_names = {'az', 'az_cm', 'el', 'el_cm'};
            azel_table = table(Az, AzCm, El, ElCm, ...
                'VariableNames', azel_names);
            
        end
        
        function labels_table = get_labels_table(obj)
            
            GPS = obj.FEdata.sampleLine.G;
            GAL = obj.FEdata.sampleLine.E;
            GLO = obj.FEdata.sampleLine.R; 
            
            ISLOS = [GPS.islos; GAL.islos ; GLO.islos];
            ISLOS = ISLOS(:);
            
            labels_table = table(ISLOS, 'VariableNames', {'los'});
            
        end
        
        function save_data_table(obj)
            
            fprintf('Writing data table... ')
            writetable(obj.data,obj.full_filename_output);
            fprintf('done!\n')
            
        end
        
        function obj = load_data_table(obj)
            fprintf('Loading data table... ')
            obj.data = readtable(obj.full_filename_output);
            fprintf('done!\n')          
        end
    end
end

