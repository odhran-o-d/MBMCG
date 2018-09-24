function [weights] = GenerateWeights(layer_size, output_size, dilution)
    
    %defines matrix of random values as synapse weights and an initial
    %matrix to record the synapses which are pruned
    
    dilution = 1-dilution;
    
    weights=rand(output_size,layer_size);
    pruned = zeros(round(dilution*output_size),layer_size);
    
    for column = (1:layer_size);    %for each cell in layer
        
        % create an array of unique random numbers that are within the
        % range of synapses; the amount created depends on the set dilution
        dilute = randperm(output_size,round(dilution*output_size));
        
        %uses these to replace some of the synapse weights with NaN, giving
        %diluted connectivity
        weights(dilute,column)=NaN;
        
        %records the pruned syanpses
        pruned(1:end,column) = dilute';
    end
    
end