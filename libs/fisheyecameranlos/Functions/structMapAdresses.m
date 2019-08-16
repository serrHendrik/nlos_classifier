function [ res ] = structMapAdresses( srcAdresses, targetPrefix, prefixPosition )
%STRUCTMAPADRESSES replaces prefixPosition levels of srcAdress struct
%adress by the given targetPrefix
%   Detailed explanation goes here
    if nargin < 3 || isempty(prefixPosition)
        prefixPosition = 0;
    end
    
    splitAdr = split( srcAdresses', '.' );
    [m,n] = size(splitAdr);
    
    prefixes = repmat({targetPrefix}, m, 1);
    
    if prefixPosition == 0
        res = [ prefixes, splitAdr ];
    else
        res = splitAdr;
        res(:,1:prefixPosition) = [];
        res = [ prefixes, res];
    end
    
    res = join( res, '.' );
    res = res';
    
    

end

