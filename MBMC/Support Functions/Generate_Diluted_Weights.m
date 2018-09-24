function [weights] = Generate_Diluted_Weights(preSynaptic_cells, postSynaptic_cells, dilution, downscaling_factor)

    % Defines matrix of random values as synapse weights and prunes them.
    % Dilution of 1.0 gives all connections, dilution of 0 gives none.

    dilution = abs(dilution - 1);
    preSynaptic_size = numel(preSynaptic_cells);
    
    weights = downscaling_factor * rand(preSynaptic_size, numel(postSynaptic_cells));
    %pruned = zeros(round(dilution*inputcells),outputcells);
    
    for column = 1:numel(postSynaptic_cells);    %for each column
        
        % create an array of unique random numbers that are within the
        % range of synapses; the amount created depends on the set dilution
        dilute = randperm(preSynaptic_size, round(dilution*preSynaptic_size));
        
        %uses these to replace some of the synapse weights with NaN, giving
        %diluted connectivity
        weights(dilute,column)=NaN;
        
        %records the pruned syanpses
        %pruned(1:end,column) = dilute';
    end
    
end