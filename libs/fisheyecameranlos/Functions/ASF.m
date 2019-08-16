function [ASFImage] = ASF(I,SES)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

ASFImage    = I;
SE          = strel('disk',SES);

for i = 1:SES
   ASFImage = imopen(imclose(ASFImage,SE),SE);
end

end

