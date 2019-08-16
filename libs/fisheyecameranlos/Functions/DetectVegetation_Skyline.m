function [BW BW1] = DetectVegetation_Skyline(BW_Sky,crv_th,areaThreshold);
% BW_Veg is binary vegetation region adjacent to skyline
% BW_Sky is input binary image, with true sky
%extract the biggest cluster as sky
%this may be not enough when sky is split
%using connected components function
[lin col]=size(BW_Sky);
% BW will contain the biggest sky component
% BW1 will contain Vegetation region
BW=BW_Sky;
BW(:,:)=0;
BW1=BW;
CC = bwconncomp(BW_Sky,8);
numPixels = cellfun(@numel,CC.PixelIdxList);
% find the biggest sky component and mark it in BW
[biggest,idx] = max(numPixels);
skyline=CC.PixelIdxList{idx};
% mark the biggest component of the sky region in BW
BW(skyline)=1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXTRACT SKYLINE BY BOUNDARY TRACING METHOD
% DETECT NON-SMOOTH REGIONS OF THE SKYLINE 
% USE THEESE REGIONS AS VEGETATION CANDIDATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% find first skyline pixel in scanning order
l=0;c=0;found=0;
[nlin ncol]=size(BW);
while(l<nlin && found==0)
    l=l+1;
    c=0;
    while(c<ncol && found==0)
        c=c+1;
        if BW(l,c)==1
            found=1;
            lin1=l;
            col1=c;
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Trace boundary
B = bwtraceboundary(BW, [lin1 col1], 'W', 8);
% figure, plot(B(:,1));
% figure, plot(B(:,2));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Estimate local boundary curvature
% Using laplacian type convolution operator 
% CIRCULAR CONVOLUTION needed, since boundary is periodic
LoG=[1 0 1 0 -4 0 1  0 1];
ct=floor(size(LoG,2)/2); % half window size
% copy extensions
Bx=cat(1,B(end-ct+1:end,1),B(:,1),B(1:ct,1));
By=cat(1,B(end-ct+1:end,2),B(:,2),B(1:ct,2));

test_x=conv(Bx,LoG);
test_y=conv(By,LoG);
cvx=test_x(2*ct+1:end-2*ct); 
cvy=test_y(2*ct+1:end-2*ct);
cv=abs(cvx)+abs(cvy);
med_cv=medfilt1(cv,33);
% figure, plot(med_cv);

% find high curvature skyline regions by thresholding
curvature_sky=(med_cv > crv_th);
curvature_sky=medfilt1(double(curvature_sky),55);
% figure, plot(curvature_sky);
% zero out smooth region coordinates
B(:,1)=B(:,1).*curvature_sky;
B(:,2)=B(:,2).*curvature_sky;
%replace zero coordinates by (1,1)
%first image pixel contaminated - usually in background, so no harm made
B(:,1)=max(B(:,1),1);
B(:,2)=max(B(:,2),1);

% start with a clear image
BW1=BW;
BW1(:,:)=0;

for i=1:size(B,1)
    BW1(B(i,1),B(i,2))=1;
end
% Clear the fake point (1,1)
BW1(1,1)=0;
% SKYLINE in BW1 now

% Continue with sky detection
% Find SKY components bigger than area size threshold from CC
% Mark SKY REGION in BW
sp=size(numPixels,2);
for idx=1:sp
    if numPixels(idx) > areaThreshold
        BW(CC.PixelIdxList{idx})=1;    
    end
end

% Dilate curved skyline points marked in BW1 
SE2=strel('square',21);
BW1=imdilate(BW1,SE2);
% Intersect with background to define ambiguous region in background
BW1=BW1&(~BW);

