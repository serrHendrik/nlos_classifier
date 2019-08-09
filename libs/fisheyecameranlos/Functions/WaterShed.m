%% Standard MATLAB

clear all
close all
clc

addpath('..\Functions\TestingImages')

%% Step 1: Read in the Color Image and Convert it to Grayscale

load('Testing3.mat')
% I = rgb2gray(testImage);
I = testImage(:,:,3);

aa = strel('Disk',576/2,8);

% Mask ESA Logo
I(486:end,1:80)     = 28;
I(526:end,650:end)  = 28;

figure()
imshow(I)

text(732,501,'Image courtesy of Corel(R)',...
     'FontSize',7,'HorizontalAlignment','right')
 
%% Step 2

gmag = imgradient(I);
figure()
imshow(gmag,[])
title('Gradient Magnitude')

L = watershed(gmag);
Lrgb = label2rgb(L);
figure()
imshow(Lrgb)
title('Watershed Transform of Gradient Magnitude')

%% Step 3

se = strel('disk',20);
Io = imopen(I,se);
figure()
imshow(Io)
title('Opening')

Ie = imerode(I,se);
Iobr = imreconstruct(Ie,I);
figure()
imshow(Iobr)
title('Opening-by-Reconstruction')

Ioc = imclose(Io,se);
figure()
imshow(Ioc)
title('Opening-Closing')

Iobrd = imdilate(Iobr,se);
Iobrcbr = imreconstruct(imcomplement(Iobrd),imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr);
figure()
imshow(Iobrcbr)
title('Opening-Closing by Reconstruction')

fgm = imregionalmax(Iobrcbr);
figure()
imshow(fgm)
title('Regional Maxima of Opening-Closing by Reconstruction')

I2 = labeloverlay(I,fgm);
figure()
imshow(I2)
title('Regional Maxima Superimposed on Original Image')

se2 = strel(ones(5,5));
fgm2 = imclose(fgm,se2);
fgm3 = imerode(fgm2,se2);

fgm4 = bwareaopen(fgm3,20);
I3 = labeloverlay(I,fgm4);
figure()
imshow(I3)
title('Modified Regional Maxima Superimposed on Original Image')

%% Step 4

bw = imbinarize(Iobrcbr);
figure()
imshow(bw)
title('Thresholded Opening-Closing by Reconstruction')

D = bwdist(bw);
DL = watershed(D);
bgm = DL == 0;
figure()
imshow(bgm)
title('Watershed Ridge Lines')

%% Step 5

% Set sink in each corner
fgm4(10,710)    = Inf;
fgm4(10,10)     = Inf;
fgm4(566,10)    = Inf;
fgm4(566,710)   = Inf;

gmag2 = imimposemin(gmag, fgm4);

L = watershed(gmag2);

%% Step 6

labels = imdilate(L==0,ones(3,3)) + 2*bgm + 3*fgm4;
I4 = labeloverlay(I,labels);
figure()
imshow(I4)
title('Markers and Object Boundaries Superimposed on Original Image')

Lrgb = label2rgb(L,'jet','w','shuffle');
figure()
imshow(Lrgb)
title('Colored Watershed Label Matrix')

figure()
imshow(I)
hold on
himage = imshow(Lrgb);
himage.AlphaData = 0.3;
title('Colored Labels Superimposed Transparently on Original Image')

%% Aditional Testing

fields = unique(L);
fieldMean   = zeros(length(fields)-1,1);
fieldStd    = zeros(length(fields)-1,1);
hist        = [];
histMarker  = [];

for i = 2:length(fields)
    fieldMean(i)	= multithresh(I(L == fields(i)));
    fieldStd(i)     = std2(I(L == fields(i)));
    hist            = [hist; I(L == fields(i))];
    histMarker      = [histMarker; (i-1)*ones(size(I(L == fields(i))))];
end

% Compute CDF
h       = imhist(I);
p       = h/sum(h);
cmh     = p;

for i = 2:256
    cmh(i) = cmh(i-1) + cmh(i);
end

idx             = kmeans(cmh,2);
meanImage       = multithresh(I);

selectedFields  = fields(fieldMean > meanImage);

sky         = zeros(size(L));
for i = 1:length(selectedFields)
    sky(L == selectedFields(i)) = 1;
end

se3     = strel('square',4);
SkyFinal = imdilate(sky,se3);

figure()
imshow(testImage)
hold on
himage = imshow(label2rgb(SkyFinal,'jet','w','shuffle'));
himage.AlphaData = 0.3;
title('Sky Region Superimposed Transparently on Original Image')

figure('Position',[0 0 1000 2000])

subplot(2,4,[1 2])
imshow(I)
hold on
himage = imshow(Lrgb);
himage.AlphaData = 0.3;
title('Colored Labels Superimposed Transparently on Original Image')

subplot(2,4,[5 6])
imagesc(L)
colorbar
axis image
ylabel('Line [pix]')
xlabel('Sample [pix]')
title('Regions without original image')

% subplot(2,3,3)
% hold on
% bar(fields,fieldMean,'HandleVisibility','Off')
% plot([fields(1),fields(end)+1],[meanImage meanImage],'DisplayName','Image Average','LineWidth',2)
% xlim([min(fields)-1 max(fields)+1])
% xlabel('Field index')
% ylabel('Average greyscale value [0-255]')
% legend

subplot(2,4,[3 4 7 8])
hold on
boxplot(hist,histMarker)
plot(fields,fieldMean,'x','MarkerSize',10,'LineWidth',5)
plot([0 length(fields)+1],[mean2(I) mean2(I)],'LineWidth',2,'LineStyle','--','Color','k')
plot([0 length(fields)+1],[mean2(I)-std2(I) mean2(I)-std2(I)],'LineWidth',1,'LineStyle','--','Color','r')
plot([0 length(fields)+1],[mean2(I)+std2(I) mean2(I)+std2(I)],'LineWidth',1,'LineStyle','--','Color','r')
title('Whisker per Segment')
xlabel('Segment [-]')
ylabel('Pixel Intensity [0-255]')
legend({'Field Average','Image Mean','Image Standard Deviation'},'Location','South')

%% Additional Histograms

figure()
subplot(1,4,1)
a = imhist(I);
bar(a)
title('Complete')

subplot(1,4,2)
b = imhist(I(SkyFinal == 1));
bar(b)
title('Sky')

subplot(1,4,3)
c = a - b;
bar(c);
title('Complete - Sky')

p = b/sum(b);
cmh     = p;

for i = 2:256
    cmh(i) = cmh(i-1) + cmh(i);
end

subplot(1,4,4)
plot(cmh)

idx = kmeans(cmh,2);

%% Additional Processing

meanSky     = mean2(I);
stdSky      = std2(I);

mypd        = normpdf(1:255,133,stdSky);
mycdf       = uint8(mypd);
for i = 1:255
    mycdf(i)    = 255*sum(mypd(1:i));
end
lut         = uint8(mycdf);

K = uint8(lut(1+I));
% K = min(K,uint8(255*SkyFinal));
% K = max(K,uint8(128*SkyFinal));

hsize   = 11;
sigma   = 3;
H       = fspecial('gaussian', hsize, sigma);
M       = imfilter(uint8(K),H);
M       = double(M)/double(255);

figure()
imshow(testImage)
hold on
himage              = imagesc(M);
himage.AlphaData    = 0.3;


%% Save Plots
% FolderName = pwd;   % Your destination folder
% FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
% for iFig = 1:length(FigList)
% FigHandle = FigList(iFig);
% FigName   = strcat('\PlotFolder\Figure',num2str(iFig,'%.0f'));
% % savefig(FigHandle, fullfile(FolderName, FigName, '.png'));
% saveas(FigHandle, strcat(FolderName, FigName, '.png'));
% end




