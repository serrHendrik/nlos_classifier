function [SkyFinal,L] = waterShedSegmentation(rgbImage,cameraMask,settings)
%[SkyFinal] = waterShedSegmentation(rgbImage,settings)
%   This functions processes an image and segments it into a sky and a
%   non-sky region (denoted by 1 and 0 respectively)
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
% Date: 18.02.2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Change History
%
% - V0.1: Prototyping 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If options are not Specified Set Defaults
if nargin < 3
    settings.se1Size    = 20;
    settings.se2Size    = 5;
    settings.se3Size    = 4;
    settings.BWASize    = 20;
end

% Step 1 - Read in the Color Image and Convert it to Grayscale
% I       = rgb2gray(rgbImage);
I       = rgbImage(:,:,3);   % Blue Channel

% Mask ESA Logo
I(486:end,1:80)     = 28;
I(526:end,650:end)  = 28;

% Apply mask 
% I(cameraMask == 1)  = uint8(0);

% Step 2 - Find Image Gradient Unprocessed Image
gmag    = imgradient(I);

% Step 3 - Opening-Closing by Reconstruction (Smoothing)
se      = strel('disk',settings.se1Size);    % Structuring Element

Ie      = imerode(I,se);                    % Morphological Erosion
Iobr    = imreconstruct(Ie,I);              % Morphological Reconstruction
Iobrd   = imdilate(Iobr,se);                % Morphological Dilation

Iobrcbr = imreconstruct(imcomplement(Iobrd),imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr);            % Opening-Closing by Reconstruction

fgm     = imregionalmax(Iobrcbr);           % Find Regional Maxima

% Additional Smoothing of Regional Minima
se2     = strel(ones(settings.se2Size,settings.se2Size));   % Structuring Element 2
fgm2    = imclose(fgm,se2);                 % Morphological Closing
fgm3    = imerode(fgm2,se2);                % Morphological Erosion

fgm4    = bwareaopen(fgm3,settings.BWASize);% Remove Small Objects from Binary Image

% Step 4 - Find Watershed Ridge Lines
% Ridge Lines ->
bw      = imbinarize(Iobrcbr);              % Create binary Image
D       = bwdist(bw);                       % Compute Euclidean Distance Transform of a Binary Image 
DL      = watershed(D);                     % Separate Regions with Global maximum
bgm     = DL == 0;                          % Ridge Lines

% Step 5 - Compute Watershed Smoothened Image

% Set sink in each corner
fgm4(10,710)    = Inf;
fgm4(10,10)     = Inf;
fgm4(566,10)    = Inf;
fgm4(566,710)   = Inf;

gmag2   = imimposemin(gmag, fgm4);          % Only set regional minima when bgm (ridge line) or fgm (local minima) is nonzero

L       = watershed(gmag2);                 % Segmented Regions -> L = 0 (Ridges)

% Step 6 - Find Sky Region
fields      = unique(L);                    % Find Indices for Each Segment
fieldMean   = zeros(length(fields)-1,1);    % Create Empty Vector for Mean storage

% Find Mean Pixel Intensity per Field
for i = 2:length(fields)    % i = 0 is boundary
    fieldMean(i)    = mean2(I(L == fields(i)));
end

meanImage   = mean2(I);     % Mean Pixel Intensity Complete Image

% Select Fields for Which the Average Field Intensity is Higher than the
% Image Average
selectedFields      = fields(fieldMean > meanImage);

sky         = zeros(size(L));   % Create Logical Matrix for Sky/Non-Sky
for i = 1:length(selectedFields)
    sky(L == selectedFields(i)) = 1;
end

% Remove Watershed Lines in Sky Region
se3         = strel('square',settings.se3Size);
SkyFinal    = imdilate(sky,se3);   % Morphological Delition

end

