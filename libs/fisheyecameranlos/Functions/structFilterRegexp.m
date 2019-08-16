function [ nestedFieldNames, appliedFilters, N ] = structFilterRegexp( srcStruct, levelFilters, preFieldName, level )

    if (nargin < 3) || isempty(preFieldName)
        nestedName = '';
    else
        nestedName = sprintf('%s.',preFieldName);
    end

    if (nargin < 4) 
        level = 1;
    else
        level = level + 1;
    end

    if level == 1
        nestedName = sprintf('%s.',inputname(1));
    end

    nestedFieldNames = {};
    appliedFilters = {};%struct([]);
    N = 0;

    levelsLeft = length(levelFilters) - level;
    if levelsLeft < 0
       return 
    end
    
    levelFilter = levelFilters{level};
    levels = numel(levelFilters);
    availFields = fieldnames(srcStruct);
    if isempty(availFields)
       return 
    end

    if isempty(levelFilter)
        applyFilter = availFields;
    else
        m = regexp( availFields, strjoin(levelFilter,'|'), 'match' );
        applyFilter = [m{:}]' ;
    end
    %levelFilters{level} = applyFilter;
    appliedFilters{level} = applyFilter;
    if isempty(applyFilter)
        appliedFilters{levels} = [];
    end
    
    for i = 1:length(applyFilter)
        fName = applyFilter{i};
        thisNestedName = sprintf('%s%s', nestedName, fName);
        resAF = {};
        if levelsLeft == 0
              nestedFieldNames = [nestedFieldNames, thisNestedName];
        elseif isstruct( srcStruct.(fName) )
            [res, resAF, resN] = structFilterRegexp(srcStruct.(fName), levelFilters, thisNestedName, level );
            if ~isempty(res)
                nestedFieldNames = [nestedFieldNames, res];
            end
        else
            continue
        end

        for ii = level+1:levels
            if length(appliedFilters) < ii
                appliedFilters{ii} = resAF{ii};
                continue
            end
            if ~isempty(resAF{ii})
                appliedFilters{ii} = union( appliedFilters{ii}, resAF{ii});
            end
        end

    end

    nestedFieldNames = unique( nestedFieldNames );
    N = length(nestedFieldNames);
end