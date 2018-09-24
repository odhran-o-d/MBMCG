function [ postSynaptic_fr, synaptic_weights ] = layer_update( preSynaptic_fr, postSynaptic_trace, synaptic_weights, postSynaptic_size, sparseness, slope, learningRate, eta, competition_type )
%LAYER_UPDATE Calculates the postsynaptic firing rate and updates the
%connection weights

            % create a copy of the weight matrix with 0 instead of NaN
            
            noNaNweights=synaptic_weights;
            noNaNweights(isnan(noNaNweights)) = 0;
            
            % calculate activations
            
            activations=dot(noNaNweights,(repmat(preSynaptic_fr',1,postSynaptic_size)));
            
            % Add noise (make optional)
            
            activations = activations + 0.1.*std(activations)*randn(1,size(activations,2));
            postSynaptic_fr = activations;
            
            % Determine competition type to be used.
            
            if strcmp(competition_type,'Soft')

                % calculate the effect of soft competition using a threshold
                % sigmoid transfer function. Sparseness between 0 and 100.

                postSynaptic_fr = softCompetition(sparseness, slope, postSynaptic_fr);
                
            elseif strcmp(competition_type,'WTA')
                
                % Use winner-takes-all model to select a single firing cell.
                
                postSynaptic_fr = WTA_Competition(postSynaptic_fr);
                
            else
                error('No Competition.')
                
            end

            % calculate trace values for postsynaptic cells (equals current firing
            % when eta is 0, ignores current firing when eta = 1)
            if eta ~= 0
                trace = ((1-eta)*postSynaptic_fr) + eta*postSynaptic_trace;
            else
                trace = postSynaptic_fr;
            end 
                
            %weightupdate = learning rate * postSynaptic trace *
            %preSynaptic firing
            
            synaptic_weights=synaptic_weights+(learningRate*(preSynaptic_fr'*trace));
            
            % normalise the weights to a total of 1 for each cell
            
            synaptic_weights = normalise(synaptic_weights);
            
end

function y = normalise(matrix)

% Normalise matrix so that each column's sum approaches 1. Ignores NaN.

%get number of rows and columns in matrix

[rows, columns] = size(matrix);

% sum each column
summed = nansum(matrix);
for column = 1:columns
    %divide each row in that column by that sum
    for row = 1:rows
        matrix(row,column) = (matrix(row,column)/summed(column));
    end
end
y = matrix;


end

