% A custom designed classification layer allowing us to give more
% importance to classes which are represented less in the training data.
% Therefore, a network trained with this layer should have no bias towards
% any given class.

classdef WeightedClassificationLayer < nnet.layer.ClassificationLayer
        
    properties
        classWeights
    end
 
    methods
        function layer = WeightedClassificationLayer(classWeights, name)           
            % Layer constructor function goes here.
            
            layer.classWeights = classWeights;
            
            if nargin == 2
                layer.Name = name;
            end
            
            layer.Description = 'Weighted Cross Entropy';
        end

        function loss = forwardLoss(layer, Y, T)
            % Return the loss between the predictions Y and the 
            % training targets T.
            %
            % Inputs:
            %         layer - Output layer
            %         Y     ? Predictions made by network
            %         T     ? Training targets
            %
            % Output:
            %         loss  - Loss between Y and T

            % Layer forward loss function goes here.
            
            N = size(Y,4);
            Y = squeeze(Y);
            T = squeeze(T);
            W = layer.classWeights;
            
            loss = - 1/N * sum(W*(T.*log(Y)));
            
            
        end
        
        function dLdY = backwardLoss(layer, Y, T)
            % Backward propagate the derivative of the loss function.
            %
            % Inputs:
            %         layer - Output layer
            %         Y     ? Predictions made by network
            %         T     ? Training targets
            %
            % Output:
            %         dLdY  - Derivative of the loss with respect to the predictions Y

            % Layer backward loss function goes here.
            
            [~,~,K,N] = size(Y);
            Y = squeeze(Y);
            T = squeeze(T);
            W = layer.classWeights;
            
            dLdY = -(W'.*T./Y)/N;
            dLdY = reshape(dLdY, [1 1 K N]);
            
        end
    end
end