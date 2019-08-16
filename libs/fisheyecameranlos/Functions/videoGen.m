%% Video Generation script
%
% Script that generates a video and if available maps the generated
% probability map over the actual footage. Furthemore, the satellites which
% can be observed in the video are plotted onto their calibration location.
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

% Open Video file
vidfile             = VideoWriter(conf.testVideo,'MPEG-4');
vidfile.FrameRate   = conf.FrameRate;

% Create Video Frames
figure('name','TestVideo','units','normalized','outerposition',[0 0 1 1])
hold on
open(vidfile)

% Loop over number of considered epochs
for ii = 1:length(videoReadID)

    % Only proceed if frame and timetag were both present
    if videoReadID(ii) == 1

        % Plot RGB Matrix -> Video
        image((videoFrameStore(:,:,:,ii)))
        
        % Plot Sky/non-Sky if available
        if conf.getProbMat == 0 || conf.getProbMat == 1
            imageProb               = imagesc(pbMat(:,:,ii));
            imageProb.AlphaData     = 0.3;  % Set Transparency
        end
        
        % Plot calibration contour
%         contour(el_calibration)
%         contour(az_calibration)

        % Plot time (UTC) and heading string
        title(strcat('Rx:',conf.receiver,' - UTC:',{' '},datestr(utcDatetime(ii)),{' '},'Heading:',{' '},num2str(refPosVel.refRot(ii,3))))

        % GPS Constellation
        if(~isempty(strfind(conf.constellation,'G')))

            % Loop over GPS SV
            for jj = 1:length(nav.G.allSv)

                % Check if SV is tracked by MMRx
                if(~isnan(sampleLine.G.sample(jj,ii)))

                    % Plot SV
                    if conf.getProbMat == 0 || conf.getProbMat == 1     % If probabilty map is available
                        if(sampleLine.G.islos(jj,ii) > 0.8)
                            plot(sampleLine.G.sample(jj,ii),sampleLine.G.line(jj,ii),'o','MarkerSize',5,...
                                'MarkerEdgeColor','g','MarkerFaceColor','r')                         
                        else
                            plot(sampleLine.G.sample(jj,ii),sampleLine.G.line(jj,ii),'o','MarkerSize',5,...
                                'MarkerEdgeColor','k','MarkerFaceColor','r')
                        end
                    else                                                % If probability map is not available
                            plot(sampleLine.G.sample(jj,ii),sampleLine.G.line(jj,ii),'o','MarkerSize',5,...
                                'MarkerEdgeColor','k','MarkerFaceColor','r')                         
                    end

                    % Plot SV label
                    if(~isempty(strfind(conf.ObsToProcess,'S')))
                        text(sampleLine.G.sample(jj,ii)+conf.svLabelLeftPos,sampleLine.G.line(jj,ii),strcat('G',num2str(nav.G.allSv(jj),'%02.0f'),'/',num2str(nav.G.matCN0(jj,ii),'%.0f')),'Color','r')
                    else
                        text(sampleLine.G.sample(jj,ii)+conf.svLabelLeftPos,sampleLine.G.line(jj,ii),strcat('G',num2str(nav.G.allSv(jj),'%02.0f')),'Color','r')
                    end
                end
            end
        end
        
        % GLONASS Constellation
        if(~isempty(strfind(conf.constellation,'R')))

            % Loop over GLONASS SV
            for jj = 1:length(nav.R.allSv)

                % Check if SV is tracked by MMRx
                if(~isnan(sampleLine.R.sample(jj,ii)))

                    % Plot SV
                    if conf.getProbMat == 0 || conf.getProbMat == 1     % If probabilty map is available
                        if(sampleLine.R.islos(jj,ii) > 0.8)
                            plot(sampleLine.R.sample(jj,ii),sampleLine.R.line(jj,ii),'o','MarkerSize',5,...
                                'MarkerEdgeColor','g','MarkerFaceColor','g')                         
                        else
                            plot(sampleLine.R.sample(jj,ii),sampleLine.R.line(jj,ii),'o','MarkerSize',5,...
                                'MarkerEdgeColor','k','MarkerFaceColor','g')
                        end
                    else                                                % If probability map is not available
                            plot(sampleLine.R.sample(jj,ii),sampleLine.R.line(jj,ii),'o','MarkerSize',5,...
                                'MarkerEdgeColor','k','MarkerFaceColor','g')                         
                    end

                    % Plot SV label
                    if(~isempty(strfind(conf.ObsToProcess,'S')))
                        text(sampleLine.R.sample(jj,ii)+conf.svLabelLeftPos,sampleLine.R.line(jj,ii),strcat('R',num2str(nav.R.allSv(jj),'%02.0f'),'/',num2str(nav.R.matCN0(jj,ii),'%.0f')),'Color','g')
                    else
                        text(sampleLine.R.sample(jj,ii)+conf.svLabelLeftPos,sampleLine.R.line(jj,ii),strcat('R',num2str(nav.R.allSv(jj),'%02.0f')),'Color','g')
                    end
                end
            end
        end
        
        % Galileo Constellation
        if(~isempty(strfind(conf.constellation,'E')))

            % Loop over GPS SV
            for jj = 1:length(nav.E.allSv)

                % Check if SV is tracked by MMRx
                if(~isnan(sampleLine.E.sample(jj,ii)))

                    % Plot SV
                    if conf.getProbMat == 0 || conf.getProbMat == 1     % If probabilty map is available
                        if(sampleLine.E.islos(jj,ii) > 0.8)
                            plot(sampleLine.E.sample(jj,ii),sampleLine.E.line(jj,ii),'o','MarkerSize',5,...
                                'MarkerEdgeColor','g','MarkerFaceColor','b')                         
                        else
                            plot(sampleLine.E.sample(jj,ii),sampleLine.E.line(jj,ii),'o','MarkerSize',5,...
                                'MarkerEdgeColor','k','MarkerFaceColor','b')
                        end
                    else                                                % If probability map is not available
                            plot(sampleLine.E.sample(jj,ii),sampleLine.E.line(jj,ii),'o','MarkerSize',5,...
                                'MarkerEdgeColor','k','MarkerFaceColor','b')                         
                    end

                    % Plot SV label
                    if(~isempty(strfind(conf.ObsToProcess,'S')))
                        text(sampleLine.E.sample(jj,ii)+conf.svLabelLeftPos,sampleLine.E.line(jj,ii),strcat('E',num2str(nav.E.allSv(jj),'%02.0f'),'/',num2str(nav.E.matCN0(jj,ii),'%.0f')),'Color','b')
                    else
                        text(sampleLine.E.sample(jj,ii)+conf.svLabelLeftPos,sampleLine.E.line(jj,ii),strcat('E',num2str(nav.E.allSv(jj),'%02.0f')),'Color','b')
                    end
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
        F(ii)    = getframe(gcf);
        writeVideo(vidfile, F(ii));

        % Refresh frame
        cla
    end
end

close(vidfile)