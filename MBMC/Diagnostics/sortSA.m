function columnsbystate = sortSA(SA_cells, SAtoSA, SA_decoded)
% order SA cells by associated state

columnsbystate = zeros([1 size(SA_cells, 3)]);

for i = 1:size(SA_cells, 3)
    
    for j = 1:size(SA_cells, 1)
        
        cell = size(SA_cells, 1) * (i - 1) + j;
        
        if any(SA_query(SA_decoded, 'cell', cell))
            data = SA_query(SA_decoded, 'cell', cell);
            columnsbystate(data(1)) = i;
            break
        end
        
        state = 0;
        
    end
end

cellsbystate = zeros([1 numel(SA_cells)]);

for i = 1:numel(columnsbystate)
    
    if any(columnsbystate(i))
        cellsbystate(size(SA_cells, 1) * (i - 1) + 1:size(SA_cells, 1) * (i - 1) + size(SA_cells, 1)) = ...
            size(SA_cells, 1) * (columnsbystate(i) - 1) + 1:size(SA_cells, 1) * (columnsbystate(i) - 1) + size(SA_cells, 1);
    end
end

sorted_SAtoSA = sortSynapses(SAtoSA, cellsbystate);
sorted_SAtoSA = sortSynapses(sorted_SAtoSA', cellsbystate);
sorted_SAtoSA = sorted_SAtoSA';

figure(); imagesc(sorted_SAtoSA); colormap('gray'); colorbar

end

function sorted_Synapses = sortSynapses(synapses, index)

sorted_Synapses = zeros(numel(index)); assert(isequal(size(sorted_Synapses), size(synapses)))

for i = 1:numel(index)
    if any(index(i))
        sorted_Synapses(i, :) = synapses(index(i), :);
    else
        sorted_Synapses(i, :) = 0;
    end
end


end