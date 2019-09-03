classdef nlos_scaler_minmax
    %NLOS_SCALER_MINMAX Summary of this class goes here
    %   A minmax scaler will scale all variables in scalable_vars to the
    %   range of [0, 1]. It will do so separately for every constellation.
    % 
    %   An important special case is the carrierphase, which contains a lot
    %   of 0 values before scaling, indicating that carrierphase
    %   information is missing. The scaler will only scale the nonzero
    %   carrierphase data and will change the original zeros to -1, to
    %   clearly distinguish the scaled minima from the missing data.
    %
    %   Remember to init the scaler with the training set, and then use it
    %   to scale both the training and validation/test sets, using the
    %   scale() method.

    
    properties
        scalable_vars   %cell array
        min_values             %struct
        max_values             %struct
    end
    
    methods
        function obj = nlos_scaler_minmax(Dtrain, scalable_vars)
            %NLOS_SCALER_MINMAX Construct an instance of this class
            %   Detailed explanation goes here
            
            obj.scalable_vars = scalable_vars;
            
            %init min_values and max_values
            for c = 'GER'
                for i = 1:length(obj.scalable_vars)
                   v = obj.scalable_vars{i};
                   obj.min_values.(c).(v) = inf;
                   obj.max_values.(c).(v) = -inf;
                end
            end
            
            %adapt min and max values based on Dtrain.
            %Note that when lag is present, all lag columns will be scaled to the same values!
            for c = 'GER'
                const_mask = cell2mat(Dtrain{:,{'sv_sys'}}) == c;
                
                for i = 1:length(obj.scalable_vars)
                   v = obj.scalable_vars{i};
                   
                   if sum(const_mask) == 0
                       %In case a constellation is not present in the data
                       obj.min_values.(c).(v) = 0;
                       obj.max_values.(c).(v) = 1;
                   else
                       
                       %loop over all variables in Dtrain, which may contain multiple columns per scalable variable
                       for j = 1:length(Dtrain.Properties.VariableNames)
                           Dv = Dtrain.Properties.VariableNames{j};
                           
                           %min value
                           if contains(Dv,v)
                               if ~contains(Dv,'carrierphase')
                                    currMin = obj.min_values.(c).(v);
                                    DvMin = min(Dtrain{const_mask,{Dv}});
                                    obj.min_values.(c).(v) = min(currMin,DvMin);
                               else
                                   mask_nonzero = Dtrain{:,{Dv}} ~= 0 & const_mask;
                                   currMin = obj.min_values.(c).(v);
                                   DvMin = min(Dtrain{mask_nonzero,{Dv}});
                                   obj.min_values.(c).(v) = min(currMin,DvMin);
                               end

                               %max value
                               currMax = obj.max_values.(c).(v);
                               DvMax = max(Dtrain{const_mask,{Dv}});
                               obj.max_values.(c).(v) = max(currMax,DvMax);
                           end
                       end
                       
                   end
                   
                end
            end
            
        end
        
        function data = scale(obj, datatable)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            
            data = datatable;
            for c = 'GER'
                const_mask = cell2mat(data{:,{'sv_sys'}}) == c;
                
                for i = 1:length(obj.scalable_vars)
                   v = obj.scalable_vars{i};
                   
                       %loop over all variables in datatable, which may contain multiple columns per scalable variable
                       for j = 1:length(data.Properties.VariableNames)
                           Dv = data.Properties.VariableNames{j};
                           
                           if contains(Dv,v)
                               %Handle carrierphase differently
                               if ~contains(Dv,'carrierphase')

                                   data{const_mask,{Dv}} = (data{const_mask,{Dv}} - obj.min_values.(c).(v)) / (obj.max_values.(c).(v) - obj.min_values.(c).(v));

                               else
                                   mask_nonzero = data{:,{Dv}} ~= 0 & const_mask;
                                   data{mask_nonzero,{Dv}} = (data{mask_nonzero,{Dv}} - obj.min_values.(c).(v)) / (obj.max_values.(c).(v) - obj.min_values.(c).(v));

                                   %change carrierphase 0 values to -1 (as 0 is now considered the minimum)
                                   mask_zero = data{:,{Dv}} == 0 & const_mask;
                                   data{mask_zero,{Dv}} = -1 * ones(sum(mask_zero),1);
                               end
                           end
                       end
                   

                end
            end
            
            
        end
    end
end

