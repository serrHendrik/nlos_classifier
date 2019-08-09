%_________________________________________________________________________%
%%FUNCTION to compute probability map and confidence coefficient
% INPUT: matlab image, 'I', reprezenting a frame from the video file
% OUTPUT: matlab image containing probability map, 'M', and the value of
% the confidence coefficient, 'conf'
%_________________________________________________________________________%
function [M, conf] = img_PbMap_Conf(I)

areaThreshold = 2000;
crv_th=2.5;

J=I(:,:,3);

thr=mean(mean(J));
BW=(J>mean(thr));

 % apply k-medoid algorithm
    [thr center1 center2] = blue_kmedoid(J);

    BW = ( J > thr ); 

    
    %Filter to remove small objects in sky segment
    SE=strel('square',5);       % Image Processing Toolbox
    SE1=strel('square', 5);     % Image Processing Toolbox
    BW=imdilate(BW,SE1);        % Image Processing Toolbox
    BW=imerode(BW,SE);          % Image Processing Toolbox
    
    
    % Detect vegetation adjacent to the skyline using curvature
    % Remove small area objects from Sky image
    [BW BW1]=DetectVegetation_Skyline(BW,crv_th,areaThreshold);

    sky = BW; % sky map
    veg = BW1; % vegetation map
    elsky = nnz(sky); % #sky pixels
    elveg = nnz(veg);% #vegetation pixels
    sv_ratio = elveg/(elsky+elveg); % vegetation-sky ratio

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % generate probability map
    % Pvisible = Psky + Pvegetation
    % Psky(gray) = Pdetected(threshold) + Gauss_cdf(gray|mu, sigma) 
    % mu = threshold
    % sigma = (mu2-mu1)/4;

    sigma=double((center2-center1)/4);
    mu=double( thr );
    gray=(1:255);
    % Generate Gauss pdf
    mypd=normpdf(gray,mu,sigma);
    % Normalize pdf
    mypd=mypd/sum(mypd);

    % Compute Gaussian cdf
    mycdf=uint8(mypd);
    for i=1:255
        mycdf(i)=255*sum(mypd(1:i));
    end
    % Store cdf in look-up table lut
    lut=uint8(mycdf);

    % set vegetation probability * 255 
    Wveg=100;
    % Generate SKY probability image, using lut
    K=uint8(lut(1+I(:,:,3)));
    % Intersect with sky map, to avoid inclusion of non-sky regions 
    K=min(K,uint8(255*BW));
    % Make sure detected sky point probabilites exceed 0.5
    K=max(K,uint8(128*BW));
    % Mark vegetation probability (in background) 
    K=K+uint8(Wveg*BW1);
   

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Model position uncertainty (car balance, satelite position, camera
    % alignment)
    % Bluring probability image 
    hsize=11;
    sigma=3;
    H = fspecial('gaussian', hsize, sigma);
    M=imfilter(uint8(K),H); % Final Probability Map
    M= double(M)/double(255);    
    


% sky pixels histogram
hsky = zeros(1,255);
for x=1:size(sky,1),
    for y=1:size(sky,2),
        if (sky(x,y)>0 && J(x,y)>0)
            hsky(J(x,y)) = hsky(J(x,y))+1;
        end
    end
end

% Confidence coefficient computation
kt = kurtosis(hsky)-6;

term1 = 0.98; % segmentation accuracy related term
term2 = 2*atan(kt)/pi; % term related to the uncertainty of the sky cluster
term3 = sv_ratio; % term related to vegetation-sky ratio

% compute confidence coefficient
conf = term1-term2*term3;
if (conf>1)
    conf = 1;
end

end