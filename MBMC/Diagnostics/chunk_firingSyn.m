function chunk_firingSyn(worldSize, agent)

if ~any(agent.chunk_cells)
    error('No chunk cells currently firing.')
end

total_chunk = zeros(16*worldSize*3);
chunk_tracked = {};
total_tracked = [];

for chosen_cell = 1:numel(agent.chunk_cells)
    
    if agent.chunk_cells(chosen_cell) > 0 && any(agent.chunktoSA_synapses(chosen_cell,:))
        display = chunk_analyseSyn(worldSize, agent, 'N', false, chosen_cell);
        matDisplay = cell2mat(display);
        matDisplay = matDisplay * agent.chunk_cells(chosen_cell);
        
        total_tracked(end+1) = sum(agent.chunktoSA_synapses(chosen_cell,:));
        
        total_chunk = total_chunk + double(matDisplay);
        chunk_tracked{end+1} = double(matDisplay);
    end
    
end

figure(); imagesc(total_chunk);
slider_display(chunk_tracked, [], false);

end
