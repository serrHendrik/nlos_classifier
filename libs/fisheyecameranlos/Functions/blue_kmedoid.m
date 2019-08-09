function [threshold center1 center2] = blue_kmedoid(g_image);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% fast 1D k medoid

J=g_image;
% nrows = size(J,1);
% ncols = size(J,2);
% nColors = 2;
mth = uint8(mean2(J));
        
% Compute normalized image histogram
h=imhist(J);
% clearing out black corners (I=0)leads to worst thresholds
% h(1)=h(2); 
p=h/sum(h);

% Compute cumulative histogram for fast median computation 
cmh=p;

for i=2:256
    cmh(i)=cmh(i-1)+cmh(i);
end

% main iteration loop
for cicles = 1:3
% Lower center, mlo, is the median of pixels smaller than threshold
    mlo=0;
    uplimit=(cmh(1+mth))/2;
    while cmh(1+mlo) < uplimit
        mlo = mlo + 1;
    end
    mhi=mth;
    uplimit=(1+cmh(1+mth))/2;
    while cmh(1+mhi) < uplimit && mhi < 255
        mhi = mhi + 1;
    end
    mth = uint8((double(mlo) + double(mhi) ) / 2); 
end

threshold = double( mth );
center1 = mlo;
center2 = mhi;
