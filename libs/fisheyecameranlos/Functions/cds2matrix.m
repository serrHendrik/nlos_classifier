function [ O, O_labels, af, O_m ] = cds2matrix( obs, filter )
%CDS2MATRIX Summary of this function goes here
%   Detailed explanation goes here
    [O_labels, af, O_m]  = structFilterRegexp( obs, filter );
    
    O_n = 0;
    
    O = []; 
% %     validDimension = false(1, O_m);
    for obsIdx = 1:O_m
        obsAddress = O_labels{ obsIdx };
        tmp = eval( obsAddress );
        if O_n == 0 || isempty( O )
            O_n = length( tmp );
            O = nan( O_m, O_n );
        end
        O(obsIdx,:) = tmp;
% %         if length(tmp) == O_n
% %             O(obsIdx,:) = tmp;
% %             validDimension(obsIdx) = 1;
% %         else
% %             warning('Dimensions do not match to first obs: %s', obsAddress);
% %         end
    end
    
% %     O = O(validDimension, :);
% %     O_labels = O_labels(validDimension);
% %     O_m = sum(validDimension);

end

