function [ cdStruct ] = cdsAddSource( SRC )
%CDSADDSOURCE Loads struct from source and adds INFO.SRC field to it

    cdStruct = load( SRC );
    cdStruct.INFO.SRC = SRC;
    cdStruct.INFO.label = '';
    cdStruct.INFO.configuration = '';

end

