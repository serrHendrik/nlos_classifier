%% Verification/Validation Plotter
%
% Script that generates figures that can be used for
% validation/verification
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Author: Floor Melman
% Company: European Space Agency
%
% Date: 12.02.2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Change History
%
% - V0.1: Prototyping
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Convert GPS Time to UTC-datetime for visualization
utcTime     = gps2utc(vboTag.GPSWeek(cameraImSel),vboTag.tagTOW(cameraImSel),18);
utcDatetime = datetime(utcTime(:,1),utcTime(:,2),utcTime(:,3),utcTime(:,4),utcTime(:,5),utcTime(:,6));

figure()
polarplot(deg2rad(aZeLStructure.G.Az(:,1)),aZeLStructure.G.El(:,1),'ro','MarkerFaceColor','r')
hold on
polarplot(deg2rad(aZeLStructure.R.Az(:,1)),aZeLStructure.R.El(:,1),'ro','MarkerFaceColor','g')
polarplot(deg2rad(aZeLStructure.E.Az(:,1)),aZeLStructure.E.El(:,1),'ro','MarkerFaceColor','b')
for ii = 1:length(nav.G.allSv)
    text(deg2rad(aZeLStructure.G.Az(ii,1)),aZeLStructure.G.El(ii,1),strcat('G',num2str(nav.G.allSv(ii),'%02.0f')))
end
for ii = 1:length(nav.R.allSv)
    text(deg2rad(aZeLStructure.R.Az(ii,1)),aZeLStructure.R.El(ii,1),strcat('R',num2str(nav.R.allSv(ii),'%02.0f')))
end
for ii = 1:length(nav.E.allSv)
    text(deg2rad(aZeLStructure.E.Az(ii,1)),aZeLStructure.E.El(ii,1),strcat('E',num2str(nav.E.allSv(ii),'%02.0f')))
end
ax = gca;
ax.ThetaZeroLocation = 'top';
ax.ThetaDir = 'clockwise';
ax.RDir = 'reverse';
ax.RLim = [0 90];
thetaticks(0:22.5:(360-22.5))
thetaticklabels({'N','NNE','NE','ENE','E','ESE','SE','SSE','S','SSW','SW','WSW','W','WNW','NW','NNW'})
rticks(0:10:80)
ax.RAxisLocation = -80;
title(strcat('ENU -- UTC:',{' '},datestr(utcDatetime(1)),{' '},'Heading:',{' '},num2str(refPosVel.refRot(1,3))))

figure()
polarplot(deg2rad(aZeLStructure.G.AzCm(:,1)),aZeLStructure.G.ElCm(:,1),'ro','MarkerFaceColor','r')
hold on
polarplot(deg2rad(aZeLStructure.R.AzCm(:,1)),aZeLStructure.R.ElCm(:,1),'ro','MarkerFaceColor','g')
polarplot(deg2rad(aZeLStructure.E.AzCm(:,1)),aZeLStructure.E.ElCm(:,1),'ro','MarkerFaceColor','b')
for ii = 1:length(nav.G.allSv)
    text(deg2rad(aZeLStructure.G.AzCm(ii,1)),aZeLStructure.G.ElCm(ii,1),strcat('G',num2str(nav.G.allSv(ii),'%02.0f')))
end
for ii = 1:length(nav.R.allSv)
    text(deg2rad(aZeLStructure.R.AzCm(ii,1)),aZeLStructure.R.ElCm(ii,1),strcat('R',num2str(nav.R.allSv(ii),'%02.0f')))
end
for ii = 1:length(nav.E.allSv)
    text(deg2rad(aZeLStructure.E.AzCm(ii,1)),aZeLStructure.E.ElCm(ii,1),strcat('E',num2str(nav.E.allSv(ii),'%02.0f')))
end
ax = gca;
ax.ThetaZeroLocation = 'top';
ax.ThetaDir = 'clockwise';
ax.RDir = 'reverse';
ax.RLim = [0 90];
rticks(0:10:80)
title(strcat('Rx:',conf.receiver,' - VEHICLE -- UTC:',{' '},datestr(utcDatetime(1)),{' '},'Heading:',{' '},num2str(refPosVel.refRot(1,3))))

figure()
hold on
image((videoFrameStore(:,:,3,1)))
% GPS Spacecraft
for ii = 1:length(nav.G.allSv)
    if ~isnan(sampleLine.G.sample(ii,1))
        plot(sampleLine.G.sample(ii,1),sampleLine.G.line(ii,1),'o','MarkerSize',5,'MarkerEdgeColor','k','MarkerFaceColor','r')
        text(sampleLine.G.sample(ii,1)+conf.svLabelLeftPos,sampleLine.G.line(ii,1),strcat('G',num2str(nav.G.allSv(ii),'%02.0f')))
    end
end
% GLONASS Spacecraft
for ii = 1:length(nav.R.allSv)
    if ~isnan(sampleLine.R.sample(ii,1))
        plot(sampleLine.R.sample(ii,1),sampleLine.R.line(ii,1),'o','MarkerSize',5,'MarkerEdgeColor','k','MarkerFaceColor','g')
        text(sampleLine.R.sample(ii,1)+conf.svLabelLeftPos,sampleLine.R.line(ii,1),strcat('R',num2str(nav.R.allSv(ii),'%02.0f')))
    end
end
% Galileo Spacecraft
for ii = 1:length(nav.E.allSv)
    if ~isnan(sampleLine.E.sample(ii,1))
        plot(sampleLine.E.sample(ii,1),sampleLine.E.line(ii,1),'o','MarkerSize',5,'MarkerEdgeColor','k','MarkerFaceColor','b')
        text(sampleLine.E.sample(ii,1)+conf.svLabelLeftPos,sampleLine.E.line(ii,1),strcat('E',num2str(nav.E.allSv(ii),'%02.0f')))
    end
end
xlim([0 720])
ylim([0 576])
contour(el_calibration)
contour(az_calibration)
ax = gca;
ax.YDir = 'reverse';
title(strcat('IMAGE - UTC:',{' '},datestr(utcDatetime(1)),{' '},'Heading:',{' '},num2str(refPosVel.refRot(1,3))))

figure()
hold on
if conf.getProbMat == 0 || conf.getProbMat == 1
    imagesc(pbMat(:,:,1))   
else
    imagesc(videoFrameStore(:,:,:,1))
end
% Plot GPS Spacecraft
for jj = 1:length(nav.G.allSv)
% Check if SV is tracked by MMRx
if(~isnan(sampleLine.G.sample(jj,1)))
% Plot SV
if conf.getProbMat == 0 || conf.getProbMat == 1     % If probability map is available
    if(sampleLine.G.islos(jj,1) > 0.4)
        plot(sampleLine.G.sample(jj,1),sampleLine.G.line(jj,1),'o','MarkerSize',5,...
            'MarkerEdgeColor','k','MarkerFaceColor','r')                         
    else
        plot(sampleLine.G.sample(jj,1),sampleLine.G.line(jj,1),'o','MarkerSize',5,...
            'MarkerEdgeColor','g','MarkerFaceColor','r')
    end
else                                                % If probability map is not available
    plot(sampleLine.G.sample(jj,1),sampleLine.G.line(jj,1),'o','MarkerSize',5,...
        'MarkerEdgeColor','k','MarkerFaceColor','r')
end
% Plot SV label
text(sampleLine.G.sample(jj,1)+conf.svLabelLeftPos,sampleLine.G.line(jj,1),strcat('G',num2str(nav.G.allSv(jj),'%02.0f'),'/',num2str(nav.G.matCN0(jj,1),'%.0f')),'Color','r')
end
end
% Plot GLONASS Spacecraft
for jj = 1:length(nav.R.allSv)
% Check if SV is tracked by MMRx
if(~isnan(sampleLine.R.sample(jj,1)))
% Plot SV
if conf.getProbMat == 0 || conf.getProbMat == 1     % If probability map is available
    if(sampleLine.R.islos(jj,1) > 0.4)
        plot(sampleLine.R.sample(jj,1),sampleLine.R.line(jj,1),'o','MarkerSize',5,...
            'MarkerEdgeColor','k','MarkerFaceColor','g')                         
    else
        plot(sampleLine.R.sample(jj,1),sampleLine.R.line(jj,1),'o','MarkerSize',5,...
            'MarkerEdgeColor','g','MarkerFaceColor','g')
    end
else                                                % If probability map is not available
    plot(sampleLine.R.sample(jj,1),sampleLine.R.line(jj,1),'o','MarkerSize',5,...
        'MarkerEdgeColor','k','MarkerFaceColor','g')
end
% Plot SV label
text(sampleLine.R.sample(jj,1)+conf.svLabelLeftPos,sampleLine.R.line(jj,1),strcat('R',num2str(nav.G.allSv(jj),'%02.0f'),'/',num2str(nav.R.matCN0(jj,1),'%.0f')),'Color','g')
end
end
% Plot Galileo Spacecraft
for jj = 1:length(nav.E.allSv)
% Check if SV is tracked by MMRx
if(~isnan(sampleLine.E.sample(jj,1)))
% Plot SV
if conf.getProbMat == 0 || conf.getProbMat == 1     % If probability map is available
    if(sampleLine.E.islos(jj,1) > 0.4)
        plot(sampleLine.E.sample(jj,1),sampleLine.E.line(jj,1),'o','MarkerSize',5,...
            'MarkerEdgeColor','k','MarkerFaceColor','b')                         
    else
        plot(sampleLine.E.sample(jj,1),sampleLine.E.line(jj,1),'o','MarkerSize',5,...
            'MarkerEdgeColor','g','MarkerFaceColor','b')
    end
else                                                % If probability map is not available
    plot(sampleLine.E.sample(jj,1),sampleLine.E.line(jj,1),'o','MarkerSize',5,...
        'MarkerEdgeColor','k','MarkerFaceColor','b')
end
% Plot SV label
text(sampleLine.E.sample(jj,1)+conf.svLabelLeftPos,sampleLine.E.line(jj,1),strcat('E',num2str(nav.E.allSv(jj),'%02.0f'),'/',num2str(nav.E.matCN0(jj,1),'%.0f')),'Color','b')
end
end
ax = gca;
ax.YDir = 'reverse';
xlim([0 720])
ylim([0 576])
colorbar
% Plot time (UTC) and heading string
title(strcat('Rx:',conf.receiver,' - UTC:',{' '},datestr(utcDatetime(1)),{' '},'Heading:',{' '},num2str(refPosVel.refRot(1,3))))   

figure()
yyaxis left
hold on
plot(1:length(commonTime),refPosVel.refRot(:,1))
plot(1:length(commonTime),refPosVel.refRot(:,2))
ylabel('Roll/Pitch [deg]')

yyaxis right
plot(1:length(commonTime),refPosVel.refRot(:,3))
ylabel('Heading [deg]')
xlabel('Epoch [s]')
title('Test Vehicle Orientation')
legend('Roll','Pitch','Heading')

%% Plot Verification of Calibration

figure()
subplot(1,3,1)
imagesc(az_calibration)
colorbar
ylabel('Line [px]')
xlabel('Sample [px]')
title('Azimuth')

subplot(1,3,2)
imagesc(el_calibration)
colorbar
ylabel('Line [px]')
xlabel('Sample [px]')
title('Elevation')

subplot(1,3,3)
hold on
image(videoFrameStore(:,:,:,1))
contour(el_calibration)
contour(az_calibration)
ax = gca;
ax.YDir = 'reverse';
ylabel('Line [px]')
xlabel('Sample [px]')
title('Footage')

%% Trajectory Plot

figure()
hold on
plot(refPosVel.spanLong,refPosVel.spanLat,'LineWidth',2)
plot(vboTag.longitude(cameraImSel),vboTag.latitude(cameraImSel))
title('Trajectory')
xlabel('Longitude [deg] (East Positive)')
ylabel('Latitude [deg]')
legend('SPAN','Camera')
grid on
axis equal