function [commonTime,cameraImSel]   = findCommonTime(vboTag,nav)
% [commonTime,cameraImSel] = findCommonTime(conf,vboTag)
% Function that finds the indices a video metafile timescale that intersect
% with the available epochs of a GNSS receiver
%
% Input:
%
% Output:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author: Floor Melman
% Company: European Space Agency
%
% Date: 28.01.2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Change History
% 
% - V0.1: Prototyping
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load MMrx5 timescale
MMrxGPSTime                 = nav.timeScale;	% Observation Epochs in GPS Time [s]

% Find Common TimeScale (use round)
[commonTime,cameraImSel,~]  = intersect(round(vboTag.GPSTime,1),round(MMrxGPSTime));	% Indices of Fisheye Camera which are selected

end

