%% Standard MATLAB
clear all
close all
clc

%% Input

nlosThres       = 0.45;
videoRequest    = 1; 
pnt2Request     = 0;

%% Load Data

oldData     = load('..\fisheyecameranlos\LabResults\LabData\2019_02_19_10_18_labResultsOld.mat');
newData     = load('..\fisheyecameranlos\LabResults\LabData\2019_02_19_10_39_labResultsNew.mat');

%% Retrieve Probability Matrices

pbMatOld    = double(oldData.pbMatSave)/100;
pbMatNew    = double(newData.pbMatSave)/100;

%% Add Data and Function Folders to Path 

addpath('../fisheyecameranlos/Data')
addpath('../fisheyecameranlos/Functions')

%% Compute Combined Probability

pbMat       = (pbMatOld+pbMatNew)/2;

%% Plot Resulting Video

% Retrieve struct fields required for videoRead
vboTag          = newData.vboTag;
cameraImSel     = newData.cameraImSel;
utcTime         = newData.utcTime;
conf            = newData.conf;
conf.nlosThres  = nlosThres;
videoReadID     = newData.videoReadID;
videoFrameStore = newData.videoFrameStore;
el_calibration  = newData.el_calibration;
az_calibration  = newData.az_calibration;
refPosVel       = newData.refPosVel;
nav             = newData.nav;
aZeLStructure   = newData.aZeLStructure;

%% Compute sample/line coordinate for each SV

[sampleLine]        = aZeL2PixelLoc(conf,aZeLStructure,az_calibration,el_calibration,pbMat);

%% Generate Video

if videoRequest == 1
    videoGen;
end

%% Generate PNT2 Dataformat

if pnt2Request == 1
    islos.G.data    = sampleLine.G.islos;
    islos.R.data    = sampleLine.R.islos;
    islos.E.data    = sampleLine.E.islos;
    islos.time      = newData.commonTime;
    islos.G.svPRN   = nav.G.allSv;
    islos.R.svPRN   = nav.R.allSv;
    islos.E.svPRN   = nav.E.allSv;
    save('C:\Users\floor melman\Documents\Code\PNT2-ENGINE\pnt2\inputData\cameranlos\islos.mat','islos')
end

