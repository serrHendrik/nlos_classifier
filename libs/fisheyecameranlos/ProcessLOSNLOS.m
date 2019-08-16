%% STANDARD MATLAB
clear all
close all
clc

%% INPUT

% Input for generation of video/mat output
videoGen    = 0;
genPbOutput = 1;

% Input Time for plotting
timeTowStart    = 400;
timeTowStop     = 600;

%% Load data

load('../fisheyecameranlos/LabResults/GerardaResults/elev_gps.mat')
load('../fisheyecameranlos/LabResults/GerardaResults/error3D.mat')
load('../fisheyecameranlos/LabResults/GerardaResults/mission_time.mat')
load('../fisheyecameranlos/LabResults/GerardaResults/residuals_raw_gps.mat')
load('../fisheyecameranlos/LabResults/GerardaResults/residuals_true_gps.mat')
load('../fisheyecameranlos/LabResults/LabData/2019_02_07_15_24_00_labResults.mat','sampleLine','commonTime','nav')

%% Process Data

% Find timescale from NLOS/LOS results
gpsWeek         = floor(nav.timeScale/604800);
gpsToW          = nav.timeScale - gpsWeek*604800;

% Find common timescale
[commonTime, resIndices, pbIndices]      = intersect(mission_time,gpsToW);


%% Generate Output LOS/NLOS probability

if genPbOutput == 1

    % Store probability results in different format (time x noSVs matrix
    % size)
    pbSVMatTemp     = sampleLine.G.islos';

    noGPSSVs        = 32;
    pbSV            = NaN(length(commonTime),noGPSSVs);

    pbSV(:,nav.G.allSv)     = pbSVMatTemp;

    save('PNTNLOSLOSCAMERA.mat','pbSV','gpsToW','gpsWeek')

end

%% Compute number of SVs and SV labels

SVPRNs  = find(any(residuals_raw_gps(resIndices(timeTowStart:timeTowStop),:)));

%% Plot per SV (true residual)

noRows  = 3;
noCols  = length(SVPRNs)/noRows;

figure()

for i = 1:length(SVPRNs)
    subplot(noRows,noCols,i)
    yyaxis left
    plot(timeTowStart:timeTowStop,residuals_true_gps(resIndices(timeTowStart:timeTowStop),SVPRNs(i)),'LineWidth',2)
    ylabel('True GPS residual [m]')
    ylim([min(min(residuals_true_gps)) max(max(residuals_true_gps))])
    yyaxis right
    plot(timeTowStart:timeTowStop,pbSV(timeTowStart:timeTowStop,SVPRNs(i)),':','LineWidth',2)
    ylabel('Probability Sky [-]')
    ylim([-0.1 1.1])
    title(strcat('GPS -',{' '},'G',num2str(SVPRNs(i),'%.0f')))
    xlabel('Epoch [s]')
    xlim([timeTowStart timeTowStop])
    grid on
end

%% Plot per SV (raw residual)

figure()

for i = 1:length(SVPRNs)
    subplot(noRows,noCols,i)
    yyaxis left
    plot(timeTowStart:timeTowStop,residuals_raw_gps(resIndices(timeTowStart:timeTowStop),SVPRNs(i)),'LineWidth',2)
    ylabel('Raw GPS residual [m]')
    ylim([min(min(residuals_raw_gps)) max(max(residuals_raw_gps))])
    yyaxis right
    plot(timeTowStart:timeTowStop,pbSV(timeTowStart:timeTowStop,SVPRNs(i)),':','LineWidth',2)
    ylabel('Probability Sky [-]')
    ylim([-0.1 1.1])
    title(strcat('GPS -',{' '},'G',num2str(SVPRNs(i),'%.0f')))
    xlabel('Epoch [s]')
    xlim([timeTowStart timeTowStop])
    grid on
end

%% Plot per SV (elevation versus true residual)

figure()

for i = 1:length(SVPRNs)
    subplot(noRows,noCols,i)
    plot(residuals_true_gps(resIndices(timeTowStart:timeTowStop),SVPRNs(i)),pbSV(timeTowStart:timeTowStop,SVPRNs(i)),'+')
    xlabel('True GPS residual [m]')
    title(strcat('GPS -',{' '},'G',num2str(SVPRNs(i),'%.0f')))
    ylabel('Probability Sky [-]')
    grid on
end

%% Plot per SV (elevation versus raw residual)

figure()

for i = 1:length(SVPRNs)
    subplot(noRows,noCols,i)
    plot(residuals_raw_gps(resIndices(timeTowStart:timeTowStop),SVPRNs(i)),pbSV(timeTowStart:timeTowStop,SVPRNs(i)),'+')
    xlabel('Raw GPS residual [m]')
    title(strcat('GPS -',{' '},'G',num2str(SVPRNs(i),'%.0f')))
    ylabel('Probability Sky [-]')
    grid on
end

%% Plot Elevation and 3D error

for i = 1:length(SVPRNs)
    SVPRNsLegend{i}     = strcat('G',num2str(SVPRNs(i),'%.0f'));
end

figure()
subplot(2,1,1)
plot(timeTowStart:timeTowStop,error3D(resIndices(timeTowStart:timeTowStop)),'k')
ylabel('3D Error')
xlabel('Epoch [s]')
title('3D Error')
xlim([timeTowStart timeTowStop])
grid on

subplot(2,1,2)
plot(timeTowStart:timeTowStop,elev_gps(resIndices(timeTowStart:timeTowStop),SVPRNs),'LineWidth',2)
ylabel('Elevation [deg]')
xlabel('Epoch [s]')
title('Elevation')
xlim([timeTowStart timeTowStop])
legend(SVPRNsLegend)
grid on

%% Create video

if videoGen == 1
    
v   = VideoWriter('pbOverlay500-600.mp4','MPEG-4');
v.FrameRate     = 1;
hold on

open(v)

for ii = 500:600
    
    
    image(videoFrameStore(:,:,:,ii))
    himage = imagesc(pbMatInt(:,:,ii));
    himage.AlphaData = 0.3;  
    colorbar
    title(strcat('UTC:',{' '},datestr(utcDatetime(ii)),{' '},'Epoch:',{' '},num2str(ii,'%.0f')))
     % GPS Constellation
    if(~isempty(strfind(conf.constellation,'G')))

        % Loop over GPS SV
        for jj = 1:length(nav.G.allSv)

            % Check if SV is tracked by MMRx
            if(~isnan(sampleLine.G.sample(jj,ii)))

                % Plot SV
                if conf.getProbMat == 0 || conf.getProbMat == 1     % If probabilty map is available
                    if(sampleLine.G.islos(jj,ii) > 0.1)
                        plot(sampleLine.G.sample(jj,ii),sampleLine.G.line(jj,ii),'o','MarkerSize',5,...
                            'MarkerEdgeColor','b','MarkerFaceColor','g')                         
                    else
                        plot(sampleLine.G.sample(jj,ii),sampleLine.G.line(jj,ii),'o','MarkerSize',5,...
                            'MarkerEdgeColor','b','MarkerFaceColor','r')
                    end
                else                                                % If probability map is not available
                        plot(sampleLine.G.sample(jj,ii),sampleLine.G.line(jj,ii),'o','MarkerSize',5,...
                            'MarkerEdgeColor','b','MarkerFaceColor','r')                         
                end

                % Plot SV label
                text(sampleLine.G.sample(jj,ii)+1,sampleLine.G.line(jj,ii)+1,strcat('G',num2str(nav.G.allSv(jj),'%02.0f')))
            end
        end
    end
    
    ax = gca;
    ax.YDir = 'reverse';     
    xlim([0 720])
    ylim([0 576])
    
    % Draw in frame
    drawnow

    % Store frame to video
    F    = getframe(gcf);

    % Write video
    writeVideo(v, F);
    
end

close(v)

end

