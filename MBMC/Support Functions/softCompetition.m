function firingRates = softCompetition(sparseness, slope, activation)

% set a desired percentile of non-firing cells between 0 and 100

    % sort the neurons by activation
    %sort(firingRates);
    
    %firingRates = zeros(size(activation));

    % pick the neuron at the desired percentile and retrieve its activation
    threshold = prctile(activation,sparseness);

    % for each cell, compare with the others to get the competition factor
    %for postsynapticCell = 1 : outputCells,
        
        %competition = activation(postsynapticCell) - threshold;

        % then feed it into a sigmoid transfer function to calculate the firing rate
        %firingRates(postsynapticCell) = 1/(1 + exp((-2)*slope*competition));
    %end
    
    
    
    
    
    
    
    
    firingRates = 1./(1 + exp((-2)*slope*(activation - threshold)));
    
end