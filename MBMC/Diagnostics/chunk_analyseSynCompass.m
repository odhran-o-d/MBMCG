function chunk_analyseSynCompass(agent, world, chunk_cell, fromto, diagonal_actions, normalise_synapses)

figure();

for state = 1:prod([world.worldSize_x, world.worldSize_y])
    
    if ismember(state, world.walls)
        colour = [0.2 0.2 0.2];
    else
        colour = [1 1 1];
    end
    
    cells = SA_query(agent.SA_decoded, 'state', state);
    cells = sortrows(cells, 2);
    
    % filter SA cells to only those efferent from the chunk cell
    idx = chunk_query(agent, 'chunk', chunk_cell);
    filtered_cells = cells(ismember(cells(:,3), idx),:);
    
    switch fromto
        case 'from'
            synapses = agent.chunktoSA_synapses(chunk_cell,:);
        case 'to'
            synapses = agent.SAtochunk_synapses(:, chunk_cell);
        otherwise
            error('Switch Error')
    end
    
    [x, y] = cellCompass(filtered_cells, [], synapses, normalise_synapses, world.worldSize_x, diagonal_actions); % cells needs to contain [state, action, cell]; criterion format = [cell1;cell2;&c]
    subplot(world.worldSize_x, world.worldSize_y, convertColToRow(state, world.worldSize_x));
    h = compass_copy(colour, x,y);
    set(h,'LineWidth',2)
    
end
end