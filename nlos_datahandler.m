classdef nlos_datahandler
    %NLOS_DATAHANDLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = private)
        dataset_name
        file_location
        filename_FEdata
        filename_PNT2data
        filename_output
        FEdata
        PNT2data
        timestamp_first         %in seconds
        timestamp_last          %in seconds
    end
    properties
        data
        GPS_flag
        GAL_flag
        GLO_flag
        constellation_info
    end
    properties(Dependent)
        full_filename_FEdata
        full_filename_PNT2data
        full_filename_output  
        time_total              %in seconds
        labelled_sats
        fraction_los
        fraction_nlos
        
    end
    
    methods
        function obj = nlos_datahandler(tour_name, GPS_flag, GAL_flag, GLO_flag,normalize_flag)
            obj.GPS_flag = GPS_flag;
            obj.GAL_flag = GAL_flag;
            obj.GLO_flag = GLO_flag;
            
            %calls the apropriate tour init function after creating an object.
            switch tour_name
                case 'AMS_01'
                    obj = obj.init_AMS_01();
                case 'AMS_02'
                    obj = obj.init_AMS_02();
                case 'ROT_01'
                    obj = obj.init_ROT_01();
                case 'ROT_02'
                    obj = obj.init_ROT_02();
            end
            
            %Select appropriate constellations
            obj = obj.select_constellations();
            
            %Normalize data per constellation if requested
            if normalize_flag
                vars_to_norm = {'pseudorange', 'carrierphase', 'cnr', 'doppler', 'az', 'az_cm', 'el', 'el_cm', 'third_ord_diff', 'innovations'};
                obj = obj.normalize_data_per_const(vars_to_norm); 
            end
            
        end
        
        %init function for AMS_01 dataset
        function obj = init_AMS_01(obj)
            obj.dataset_name = 'AMS_01';
            obj.file_location = 'data/AMS_01/';
            obj.filename_FEdata = 'outputVars_EXP01_AMS_2018.mat';
            obj.filename_PNT2data = 'PNT2data.mat';
            obj.filename_output = 'AMS_01_datatable.csv';
            
            obj = obj.init_datahandler();
            
            %Filter data anomalies based on statistical analysis
            %remove points with LOS label and innovation > 100
            obj = obj.filter_innovations(100);
        end
        
        %init function for AMS_02 dataset
        function obj = init_AMS_02(obj)
            obj.dataset_name = 'AMS_02';
            obj.file_location = 'data/AMS_02/'; 
            obj.filename_FEdata = 'outputVars_EXP02_AMS_2018.mat';
            obj.filename_PNT2data = 'PNT2data.mat';
            obj.filename_output = 'AMS_02_datatable.csv';
            
            obj = obj.init_datahandler();
            
            %Filter data anomalies based on statistical analysis
            %remove points with LOS label and innovation > 100
            obj = obj.filter_innovations(100);
        end
        
        %init function for ROT_01 dataset
        function obj = init_ROT_01(obj)
            obj.dataset_name = 'ROT_01';
            obj.file_location = 'data/ROT_01/'; 
            obj.filename_FEdata = 'outputVars_EXP01_ROT_2018.mat';
            obj.filename_PNT2data = 'PNT2data.mat';
            obj.filename_output = 'ROT_01_datatable.csv';
            
            obj = obj.init_datahandler();
            
            %Filter data anomalies based on statistical analysis
            %remove points with LOS label and innovation > 100
            obj = obj.filter_innovations(100);
            
            
        end
        
        %init function for ROT_02 dataset
        function obj = init_ROT_02(obj)
            obj.dataset_name = 'ROT_02';
            obj.file_location = 'data/ROT_02/'; 
            obj.filename_FEdata = 'outputVars_EXP02_ROT_2018.mat';
            obj.filename_PNT2data = 'PNT2data.mat';
            obj.filename_output = 'ROT_02_datatable.csv';
            
            obj = obj.init_datahandler();   
            
            %Filter data anomalies based on statistical analysis, specific to this dataset
            %remove points with LOS label and innovation > 100
            obj = obj.filter_innovations(100);
        end
        
        
        function v = get.full_filename_FEdata(obj)
            v = strcat(obj.file_location,obj.filename_FEdata);
        end
        
        function v = get.full_filename_PNT2data(obj)
            v = strcat(obj.file_location,obj.filename_PNT2data);
        end
        
        function v = get.full_filename_output(obj)
            v = strcat(obj.file_location,obj.filename_output);
        end
        
        function v = get.time_total(obj)
           v = obj.timestamp_last - obj.timestamp_first; 
        end
        
        function v = get.labelled_sats(obj)
           v = sum(~isnan(obj.data.los)); 
        end
        
        function v = get.fraction_los(obj)
           not_nan_data = obj.data.los(~isnan(obj.data.los));
           v = sum(not_nan_data) / length(not_nan_data); 
        end
        
        function v = get.fraction_nlos(obj)
           v = 1 - obj.fraction_los;
        end
        
        function obj = select_constellations(obj)
            
            if ~obj.GPS_flag && ~obj.GAL_flag && ~obj.GLO_flag
                disp('No constellation selected.')
                return
            end
            
            mask_GPS = cell2mat(obj.data.sv_sys) == 'G';
            mask_GAL = cell2mat(obj.data.sv_sys) == 'E';
            mask_GLO = cell2mat(obj.data.sv_sys) == 'R';
            
            mask = obj.GPS_flag&mask_GPS | obj.GAL_flag&mask_GAL | obj.GLO_flag&mask_GLO;
            
            obj.data = obj.data(mask,:); 
            
            %User feedback:
            disp('Selected constellations:')
            if obj.GPS_flag
                fprintf('GPS ')
            end
            if obj.GAL_flag
                fprintf('GAL ')
            end
            if obj.GLO_flag
                fprintf('GLO ')
            end
            fprintf('\n\n')
        end
        
        function [data_subset,data_rest] = sample_data(obj, data, mod_b)
            
            fprintf('Sampling data... ')
            
            mask_ss = mod(data.common_time,mod_b) == 0;
            mask_inv = ~mask_ss;
            
            data_subset = data(mask_ss,:);
            data_rest = data(mask_inv,:);
            
            size_orig = length(mask_ss);
            size_samp = sum(mask_ss);
            frac_samp = size_samp / size_orig;
            fprintf('done!\n')
            fprintf('Original data size: %d (100%%), sample set size: %d (%.2f%%)\n',size_orig,size_samp,frac_samp*100);
            
            
            
        end
        
        function obj = normalize_data_per_const(obj, vars_to_norm)
            datatable_norm = obj.data;
            
            for c = 'GER'
                %get indices
                c_ind = find(cell2mat(obj.data.sv_sys) == c);
                
                %norm and insert back
                datatable_norm{c_ind,vars_to_norm} = normalize(obj.data{c_ind,vars_to_norm});
            
                if ismember('carrierphase',vars_to_norm)
                   %Get indices
                   nonzero_ind = intersect(find(obj.data.carrierphase),c_ind, 'stable');

                   %normalise nonzero data
                   nonzero_el = obj.data.carrierphase(nonzero_ind);
                   cp_norm = normalize(nonzero_el);

                   %create new carrierphase column for constellation c
                   datatable_norm.carrierphase(c_ind) = obj.data.carrierphase(c_ind);
                   datatable_norm.carrierphase(nonzero_ind) = cp_norm;

                end  
            end
            
            obj.data = datatable_norm;

        end
        
        function print_info_per_const(obj, datatable)
            mask_GPS = cell2mat(datatable.sv_sys) == 'G';
            mask_GAL = cell2mat(datatable.sv_sys) == 'E';
            mask_GLO = cell2mat(datatable.sv_sys) == 'R';
            
            datatable_GPS = datatable(mask_GPS,:);
            datatable_GAL = datatable(mask_GAL,:);
            datatable_GLO = datatable(mask_GLO,:);
            
            nb_obs_GPS = length(datatable_GPS.los);
            nb_obs_GAL = length(datatable_GAL.los);
            nb_obs_GLO = length(datatable_GLO.los);
            nb_obs_total = length(datatable.los);
            
            frac_los_GPS = NaN;
            frac_los_GAL = NaN;
            frac_los_GLO = NaN;
            frac_los_total = sum(datatable.los) / length(datatable.los);
            if nb_obs_GPS ~= 0
                frac_los_GPS = sum(datatable_GPS.los) / length(datatable_GPS.los);
            end
            if nb_obs_GAL ~= 0
                frac_los_GAL = sum(datatable_GAL.los) / length(datatable_GAL.los);
            end
            if nb_obs_GLO ~= 0
                frac_los_GLO = sum(datatable_GLO.los) / length(datatable_GLO.los);
            end

            
            
            fprintf('\n********** Info on datatable ****************\n');
            fprintf('             #observations    frac_los    frac_nlos\n');
            fprintf('GPS          %d                %.2f       %.2f\n',nb_obs_GPS, frac_los_GPS, 1-frac_los_GPS);
            fprintf('GAL          %d                %.2f       %.2f\n',nb_obs_GAL, frac_los_GAL, 1-frac_los_GAL);
            fprintf('GLO          %d                %.2f       %.2f\n',nb_obs_GLO, frac_los_GLO, 1-frac_los_GLO);
            fprintf('Total        %d                %.2f       %.2f\n', nb_obs_total, frac_los_total, 1-frac_los_total);
            fprintf('************************************************\n\n');
            
        end
        
    end
    methods (Access = private)
        
        function obj = init_datahandler(obj)
            %DATAHANDLER_V2 Construct an instance of this class
            %   Detailed explanation goes here
            
            %load FEdata
            obj.FEdata = load(obj.full_filename_FEdata);
            
            %load PNT2data
            obj.PNT2data = load(obj.full_filename_PNT2data);
            obj.PNT2data = obj.PNT2data.PNT2data;
            obj.constellation_info.G.sv_sys = 'G';
            obj.constellation_info.E.sv_sys = 'E';
            obj.constellation_info.R.sv_sys = 'R';
            obj.constellation_info.G.allSv = obj.PNT2data.G.allSv;
            obj.constellation_info.E.allSv = obj.PNT2data.E.allSv;
            obj.constellation_info.R.allSv = obj.PNT2data.R.allSv;
            
            %sync FEdata and PNT2data to match available labels data
            obj = obj.sync_FE_PNT2();
            
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
            fprintf('\n*** Dataset Initialisation Info ***\n');
            fprintf('Dataset name: %s\n', obj.dataset_name);
            fprintf('Duration of trip [HH:MM:SS]: %s\n', datestr(seconds(obj.time_total),'HH:MM:SS'));
            fprintf('Number of labelled satellites: %d\n', obj.labelled_sats);
            fprintf('Fraction of satellites labelled LOS: %.2f\n', obj.fraction_los);
            fprintf('Fraction of satellites labelled NLOS: %.2f\n', obj.fraction_nlos);
            fprintf('********************\n\n');
        end
        
        function obj = sync_FE_PNT2(obj)
            %available labels from FEdata is mostly shorter than entire PNT2 trip
            %Note: Sometimes, FEdata is longer than PNT2! (prob. mistake)
            
            timestamp_FE_first = obj.FEdata.commonTime(1);
            timestamp_PNT2_first = obj.PNT2data.commonTime(1);
            timestamp_FE_last = obj.FEdata.commonTime(end);
            timestamp_PNT2_last = obj.PNT2data.commonTime(end);
            
            obj.timestamp_first = max(timestamp_FE_first, timestamp_PNT2_first);
            obj.timestamp_last = min(timestamp_FE_last, timestamp_PNT2_last);
            
            mask_PNT2 = (obj.PNT2data.commonTime >= obj.timestamp_first) & (obj.PNT2data.commonTime <= obj.timestamp_last);
            mask_FE = (obj.FEdata.commonTime' >= obj.timestamp_first) & (obj.FEdata.commonTime' <= obj.timestamp_last);
            
            obj = obj.trim_FE(mask_FE);
            obj = obj.trim_PNT2(mask_PNT2);

        end
        
        function obj = trim_FE(obj, mask_FE)
            const = ['G', 'E', 'R'];
            azel_vars = ["Az", "AzCm", "El", "ElCm"];
            
            %Adapt time
            obj.FEdata.commonTime = obj.FEdata.commonTime(mask_FE');

            for c = const
                
               %nb_sats = length(obj.FEdata.aZeLStructure.(c).allSv);
               %mask_rep = repmat(mask_FE,nb_sats,1);
               
               %Adapt azelStructure
               for v = azel_vars
                   obj.FEdata.aZeLStructure.(c).(v) = ...
                       obj.FEdata.aZeLStructure.(c).(v)(:,mask_FE);
               end
               
               %Adapt labels
               obj.FEdata.sampleLine.(c).islos = ...
                   obj.FEdata.sampleLine.(c).islos(:,mask_FE);
            end
            
        end
        
        function obj = trim_PNT2(obj, mask_PNT2)
            const = ['G', 'E', 'R'];
            pnt2_vars = ["matObs", "matCN0", "matDopp", "mat3ord", "matCP", "elev", "kfInno"];
            
            %Adapt time
            obj.PNT2data.commonTime = obj.PNT2data.commonTime(mask_PNT2);
    
            for c = const
               %nb_sats = length(obj.PNT2data.(c).allSv);
               %mask_rep = repmat(mask_PNT2,nb_sats,1);

               %Adapt pnt2 vars
               for v = pnt2_vars
                   obj.PNT2data.(c).(v) = ...
                       obj.PNT2data.(c).(v)(:,mask_PNT2);
               end
               
            end
            
            
        end
        
        function obj = construct_table(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            
            %key (time, sv_sys, sv_id)
            key_table = obj.get_key_table();
            
            %observations
            obs_table = obj.get_obs_table();
            
            %navigation data
            nav_table = obj.get_nav_table();
            
            %labels
            labels_table = obj.get_labels_table();
            
            %merge tables
            obj.data = [key_table obs_table nav_table labels_table];
            
            %Filters
            %Innovations available from the second timestep, 3ord diff from the fourth timestep 
            nb_records_before = height(obj.data);
            fraction_los_before = obj.fraction_los;
            timesteps_to_trim = 3;
            obj = obj.trim_start(timesteps_to_trim);
            nb_records_after = height(obj.data);
            fprintf('Filter: remove first %d timesteps. \nRecords %d -> %d\nFraction LOS: %.2f -> %.2f\n', ...
                timesteps_to_trim, nb_records_before, nb_records_after, fraction_los_before, obj.fraction_los);
            
            %filter satellites below horizon or no LOS label available
            nb_records_before = height(obj.data);
            fraction_los_before = obj.fraction_los;
            nan_mask = isnan(obj.data.los(:)); 
            obj.data = obj.data(~nan_mask,:);
            nb_records_after = height(obj.data);
            fprintf('Filter: remove satellites with no label. \nRecords %d -> %d\nFraction LOS: %.2f -> %.2f\n', ...
                nb_records_before, nb_records_after, fraction_los_before, obj.fraction_los);
            
            %filter satellites with NaN values for third_order_diff or innovations
            nb_records_before = height(obj.data);
            fraction_los_before = obj.fraction_los;
            nan_mask = isnan(obj.data.third_ord_diff(:)) | isnan(obj.data.innovations(:));
            obj.data = obj.data(~nan_mask,:);
            nb_records_after = height(obj.data);
            fprintf('Filter: remove satellites with NaN values for third_ord_diff or innovations. \nRecords %d -> %d\nFraction LOS: %.2f -> %.2f\n', ...
                nb_records_before, nb_records_after, fraction_los_before, obj.fraction_los);
            
            
        end
        
        function key_table = get_key_table(obj)
           
            GPS = obj.FEdata.aZeLStructure.G;
            GAL = obj.FEdata.aZeLStructure.E;
            GLO = obj.FEdata.aZeLStructure.R;
            
            total_sats = size(GPS.allSv,1) + size(GAL.allSv,1) + size(GLO.allSv,1); 
            
            %time
            time_steps = length(obj.FEdata.commonTime);
            time_rep = repmat(obj.FEdata.commonTime',total_sats,1);
            time_rep = time_rep(:);
            
            %Satellite systems
            GPS_rep = repmat('G',size(GPS.allSv,1),1);
            GAL_rep = repmat('E',size(GAL.allSv,1),1);
            GLO_rep = repmat('R',size(GLO.allSv,1),1);
            SYS_rep = repmat([GPS_rep; GAL_rep; GLO_rep],time_steps,1);
            
            %sv id's
            allSv = [GPS.allSv; GAL.allSv; GLO.allSv];
            sv_rep = repmat(allSv,time_steps,1);
            
            
            key_names = {'common_time', 'sv_sys', 'sv_id'};
            key_table = table(time_rep, SYS_rep, sv_rep, ...
                'VariableNames', key_names);
           
        end
        
        function obs_table = get_obs_table(obj)
            GPS = obj.PNT2data.G;
            GAL = obj.PNT2data.E;
            GLO = obj.PNT2data.R;
            
            pseudorange = [GPS.matObs; GAL.matObs; GLO.matObs];
            carrierphase = [GPS.matCP; GAL.matCP; GLO.matCP];
            cnr = [GPS.matCN0; GAL.matCN0; GLO.matCN0];
            doppler = [GPS.matDopp; GAL.matDopp; GLO.matDopp];
            
            pseudorange = pseudorange(:);
            carrierphase = carrierphase(:);
            cnr = cnr(:);
            doppler = doppler(:);
            
            obs_names = {'pseudorange', 'carrierphase', 'cnr', 'doppler'};
            obs_table = table(pseudorange, carrierphase, cnr, doppler, ...
                'VariableNames', obs_names);
            
        end
        
        function nav_table = get_nav_table(obj)
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
            
            %In addition: add 3ord difference, EFK innovations
            GPS = obj.PNT2data.G;
            GAL = obj.PNT2data.E;
            GLO = obj.PNT2data.R;  
            
            third_ord_diff = [GPS.mat3ord; GAL.mat3ord; GLO.mat3ord];
            innovations = [GPS.kfInno; GAL.kfInno; GLO.kfInno];
            
            third_ord_diff = third_ord_diff(:);
            innovations = innovations(:);
            
            extra_names = {'third_ord_diff', 'innovations'};
            extra_table = table(third_ord_diff, innovations, ...
                'VariableNames', extra_names);
            
            %Finally, nav_table
            nav_table = [azel_table extra_table];
            
        end
        
        function labels_table = get_labels_table(obj)
            
            GPS = obj.FEdata.sampleLine.G;
            GAL = obj.FEdata.sampleLine.E;
            GLO = obj.FEdata.sampleLine.R; 
            
            ISLOS = [GPS.islos; GAL.islos ; GLO.islos];
            ISLOS = ISLOS(:);
            
            labels_table = table(ISLOS, 'VariableNames', {'los'});
            
        end
        
        function obj = trim_start(obj, k)
           %trim first k timesteps

           %new first time
           obj.timestamp_first = obj.timestamp_first + k;

           %mask
           mask_time = obj.data.common_time >= obj.timestamp_first;
           obj.data = obj.data(mask_time,:);
           
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
        
        function obj = filter_innovations(obj, threshold)
           
            remove_rows = obj.data.los == 1 & obj.data.innovations > threshold;
            obj.data = obj.data(~remove_rows,:);
            
            fprintf('Removed %d LOS rows with innovation > %d\n\n', sum(remove_rows), threshold)
            
        end
        
    end
end

