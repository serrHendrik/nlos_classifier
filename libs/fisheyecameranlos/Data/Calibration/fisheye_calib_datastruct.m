function [elevation, azimuth] = fisheye_calib_datastruct()

load('Omni_Calib_Results.mat');
img = imread('img01.jpg');

elevation = zeros(size(img,1),size(img,2));
azimuth = zeros(size(img,1),size(img,2));
%i=1;
for x=1:size(img,1)
    for y=1:size(img,2)
        m = [x; y];
        n = cam2world(m, calib_data.ocam_model);
       
%         p(i,:) = n;
%         i= i+1;
       
        [az, el] = cipCompAzEl(n);
        elevation(x,y) = el;
        azimuth(x,y) = az;
    end
end



function [az, el] = cipCompAzEl(n)
 
% n = cam2world(m, calib_data.ocam_model);
x = n(1);
y = n(2);
z = n(3);
q = sqrt(x*x+y*y);
 
az = atan2(y,x);
el = atan2(z,q);
 
az = az*180/pi;
el = el*180/pi;

