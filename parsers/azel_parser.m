classdef azel_parser
    %AZEL_PARSER Summary of this class goes here
    %   azel_parser takes the Fisheye output datafile (filename_FEdata) as 
    %   input and extracts azimuth and elevation information.
    %   
    %   Parser currently not used anymore as azimuth and elevation info is extracted from PNT2.
    
    properties
        timestamp_first
        timestamp_last
        full_filename_FEdata     % .mat filename from fisheye project
        full_filename_output     %file to write azel_table
        FEdata                   %output struct of fisheye project
        azel_table
    end
    
    methods
        function obj = azel_parser(file_location, filename_FEdata, filename_output)
            %AZEL_PARSER Construct an instance of this class
            %   Detailed explanation goes here
            
            %load file to parse
            obj.full_filename_FEdata = strcat(file_location, filename_FEdata);
            obj.FEdata = load(obj.full_filename_FEdata);
            
            %time (use currentTime or timescale? They differ after 8000 sth)
            last_time_index = length(obj.FEdata.nav.timeScale);
            obj.timestamp_first = obj.FEdata.nav.timeScale(1);
            obj.timestamp_last = obj.FEdata.nav.timeScale(last_time_index);
            
            %outputfile (where final table will be written to)
            obj.full_filename_output = strcat(file_location,filename_output);
 
            
            %Construct azel_table if it doesn't exist yet
            if isfile(obj.full_filename_output)
                obj = obj.load_azel_table();
            else
                obj = obj.construct_azel_table();
                obj.save_azel_table();
            end
            
        end
    end
    
    methods (Access = private)
        function obj = construct_azel_table(obj)

            GPS = obj.FEdata.aZeLStructure.G;
            GAL = obj.FEdata.aZeLStructure.E;
            GLO = obj.FEdata.aZeLStructure.R;
            
            total_sats = size(GPS.allSv,1) + size(GAL.allSv,1) + size(GLO.allSv,1);
            
            Az = [GPS.Az' GAL.Az' GLO.Az'];
            Az = Az';
            AzCm = [GPS.AzCm' GAL.AzCm' GLO.AzCm'];
            AzCm = AzCm';
            El = [GPS.El' GAL.El' GLO.El'];
            El = El';
            ElCm = [GPS.ElCm' GAL.ElCm' GLO.ElCm'];
            ElCm = ElCm';
            
            Az = Az(:);
            AzCm = AzCm(:);
            El = El(:);
            ElCm = ElCm(:);
            
            %Note: there's also a 'common time' in the obj.outputFisheye
            %struct. Which one to use???
            time_rep = repmat(GPS.time,total_sats,1);
            time_rep = time_rep(:);
            
            %SV id's
            allSv = [GPS.allSv; GAL.allSv; GLO.allSv];
            sv_rep = repmat(allSv,size(GPS.time,2),1);
            
            %Satellite systems
            GPS_rep = repmat('G',size(GPS.allSv,1),1);
            GAL_rep = repmat('E',size(GAL.allSv,1),1);
            GLO_rep = repmat('R',size(GLO.allSv,1),1);
            SYS_rep = repmat([GPS_rep; GAL_rep; GLO_rep],size(GPS.time,2),1);
            
            varNames = {'time', 'sv_sys', 'sv_id', 'az', 'az_cm', 'el', 'el_cm'};
            obj.azel_table = table(time_rep,SYS_rep,sv_rep, ...
                Az, AzCm, El, ElCm, ...
                'VariableNames', varNames);
            
            %filter table
            sat_mask = isnan(obj.azel_table.az(:)); 
            obj.azel_table = obj.azel_table(~sat_mask,:);
            
 
        end
        
        function save_azel_table(obj)
            
            disp('Writing azel data table...')
            writetable(obj.azel_table,obj.full_filename_output);
            disp('Done!')
            
        end
        
        function obj = load_azel_table(obj)
            disp('Loading azel data table...')
            obj.azel_table = readtable(obj.full_filename_output);
            disp('Done!')          
        end
        

    end
    

end

