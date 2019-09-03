classdef obs_parser
    %READ_RNX_DATAHANDLER Summary of this class goes here
    %   Parser to extract data from rinex file
    %
    %   Parser currently not used anymore (See nlos_datahandler instead).
   
%     properties (Access = private)
%        obs_parser_function = @load_RINEX_obs 
%     end
    
    properties 
        full_filename_obs                %filename of .obs file
        full_filename_output             %filename of .csv file
        obs_table              %table
    end 
    
    methods
        function obj = obs_parser(file_location, filename_obs, filename_output)
            %init files
            obj.full_filename_obs = strcat(file_location, filename_obs);
            obj.full_filename_output = strcat(file_location, filename_output);
            
            %check if output already exists.
            %If so, load data.
            %Else, construct data from file.
            if isfile(obj.full_filename_output)
                obj = obj.load_obs_table();
            else
                obj = obj.construct_data();
                obj.save_obs_table();
            end
            
        end
        
        
    end
    methods (Access = private)
        
        function obj = construct_data(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            
            %read obs file
            constellations = multi_constellation_settings(1,1,1,0,0,0);
            [pr1, ph1, pr2, ph2, dop1, dop2, snr1, snr2, ...
                time_ref, time, week, date, pos, interval, antoff, antmod, tow] = ...
            load_RINEX_obs(obj.full_filename_obs, constellations);
         
            disp('Storing data in table ...')
            
            %store data in one table
            varNames = {'sv_sys', 'sv_id', ...
                'pr1', 'ph1', ...
                'pr2', 'ph2', ...
                'dop1', 'dop2', ...
                'snr1', 'snr2', ...
                'time_ref', 'time'};
            obj.obs_table = cell2table(cell(0,12), 'VariableNames', varNames);
            
            %create array of sv_sys and sv_id
            [sv_sys_mat, sv_id_mat] = obj.get_sat_ids(constellations);
            
            %Add all records to data table in chronological order
            total_time = size(time_ref,1);
            for t = 1:total_time
                
                %Provide feedback to user
                if (mod(t,500) == 1) || (t == total_time)
                   disp(['Status: ', num2str(t/total_time * 100,3), '%']) 
                end
                
                %repeat variables which are shared for all sats at time t
                time_ref_mat = repmat(time_ref(t),constellations.nEnabledSat,1);
                time_mat = repmat(time(t),constellations.nEnabledSat,1);
                %week_mat = repmat(week(t),constellations.nEnabledSat,1);
                %date_mat = repmat(date(t,:),const.nEnabledSat,1);
                
                %construct all the new rows (one row per satellite) generated at time t
                new_rows = table(sv_sys_mat, sv_id_mat, ...
                    pr1(:,t), pr2(:,t), ...
                    ph1(:,t), ph2(:,t), ...
                    dop1(:,t), dop2(:,t), ...
                    snr1(:,t), snr2(:,t), ...
                    time_ref_mat, time_mat, ...
                    'VariableNames', varNames); 
                
                %only add observable satellites
                sat_mask = pr1(:,t) ~= 0; 
                new_rows = new_rows(sat_mask,:);
                
                %add new rows to data table
                obj.obs_table = [obj.obs_table ; new_rows];
            end
 
            disp('Done!')
            
        end
        
        function [sv_sys_mat, sv_id_mat] = get_sat_ids(obj, const)
           %create string array of sat_ids. A sat_id might be 'G12'
           
%             sat_sys_array = [const.GPS,const.Galileo,const.GLONASS];
%             sat_sys_id_array = ['G','E','R'];
            
            sv_sys_mat = [repmat('G',const.GPS.numSat,1); ...
                repmat('E',const.Galileo.numSat,1); ...
                repmat('R',const.GLONASS.numSat,1)];
            
            sv_id_mat = [const.GPS.PRN'; ...
                const.Galileo.PRN'; ...
                const.GLONASS.PRN'];
            
%             for i = 1:3
%                 sat_sys = sat_sys_array(i);
%                 sat_sys_id = sat_sys_id_array(i);
%                 
%                 sv_sys_mat = [sv_sys_mat; repmat(sat_sys_id,sat_sys.numSat,1)];
%                 sv_id_mat = [sv_id_mat; sat_sys.PRN'];
%                 
%                 for j = sat_sys.PRN
%                    sat_id_string = strcat(sat_sys_id, int2str(j));
%                    sat_ids(sat_sys.indexes(j)) = sat_id_string;
%                 end
%                 
%             end 

        end
        
        function save_obs_table(obj)
            
            disp('Writing obs data table...')
            writetable(obj.obs_table,obj.full_filename_output)
            disp('Done!')
            
        end
        
        function obj = load_obs_table(obj)
            disp('Loading obs data table...')
            obj.obs_table = readtable(obj.full_filename_output);
            disp('Done!')          
        end


    end %end private methods
    
end %end class

