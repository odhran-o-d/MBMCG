function [weights] = GenerateZeroWeights(preSynaptic_size, postSynaptic_size, dilution)
    
    %defines matrix of random values as synapse weights and an initial
    %matrix to record the synapses which are pruned
    
    dilution = 1-dilution;
    
    weights=zeros(preSynaptic_size,postSynaptic_size);
    pruned = zeros(round(dilution*preSynaptic_size),postSynaptic_size);
    %
    for column = (1:postSynaptic_size);    %for each cell in layer
        
        % create an array of unique random numbers that are within the
        % range of synapses; the amount created depends on the set dilution
        dilute = randperm(preSynaptic_size,round(dilution*preSynaptic_size));
        
        %uses these to replace some of the synapse weights with NaN, giving
        %diluted connectivity
        weights(dilute,column)=NaN;
 
        %records the pruned syanpses
        pruned(1:end,column) = dilute';
    end
    %}
    %{
    [~, dilute] = sort(rand(preSynaptic_size, postSynaptic_size));
    dilute = dilute(1:round(dilution*preSynaptic_size),:)';
    
    for column = 1:postSynaptic_size
        weights(dilute(column,:),column)=NaN;
    end
    %}
end