

function PNT2data = PNT2_extract_input_data(full_filename_output, utcTime, refPosCommonTime, nav, store)

    

    if isfile(full_filename_output)
        disp('File already exists. Remove it first before new data extraction.');
    else
        disp('Extracting data from PNT2 variables...');
        
        PNT2data.rxTime = store.timeRxTimescale';
        utcTime_temp = cellstr(datestr(datetime(utcTime),'dd-mm-yyyy HH:MM:SS'));
        PNT2data.utcTime = utcTime_temp';
        PNT2data.commonTime = refPosCommonTime';

        const = ['G', 'E', 'R'];

        %extract most data
        for c = const
            PNT2data.(c).sv_sys = c;       
            PNT2data.(c).allSv = nav.(c).allSv';
            PNT2data.(c).matObs = nav.(c).matObs;
            PNT2data.(c).matCN0 = nav.(c).matCN0;
            PNT2data.(c).matDopp = nav.(c).matDopp;
            PNT2data.(c).mat3ord = nav.(c).mat3ord;
            
            %For CP, replace NaNs with 0 to identify Loss of Lock
            PNT2data.(c).matCP = nav.(c).matCP;
            nan_indices = isnan(PNT2data.(c).matCP);
            PNT2data.(c).matCP(nan_indices) = 0;
            
            %Elevation
            PNT2data.(c).elev = store.(c).elev;
            PNT2data.(c).elev = PNT2data.(c).elev(PNT2data.(c).allSv,:);
            
        end

        %innovations
        PNT2data.G.kfInno = store.kfInno.innovationsGPS_EKF';
        PNT2data.G.kfInno = PNT2data.G.kfInno(PNT2data.G.allSv,:);
        PNT2data.E.kfInno = store.kfInno.innovationsGAL_EKF';
        PNT2data.E.kfInno = PNT2data.E.kfInno(PNT2data.E.allSv,:);
        PNT2data.R.kfInno = store.kfInno.innovationsGLO_EKF';
        PNT2data.R.kfInno = PNT2data.R.kfInno(PNT2data.R.allSv,:);


        save(full_filename_output,'PNT2data');
        disp('Done!');
        disp(['Data stored in ', full_filename_output]);
    end
end
    