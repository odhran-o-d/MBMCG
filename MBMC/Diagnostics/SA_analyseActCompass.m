function SA_analyseActCompass(agent, analysed_cells, world, diagonal_actions)

fig = figure();

for state = 1:prod([world.worldSize_x, world.worldSize_y])
    
    if ismember(state, world.walls)
        colour = [0.2 0.2 0.2];
    elseif state == find(world.state(:,:,2))
        colour = [1 0.87 0];
    else
        colour = [1 1 1];
    end
    
    % look up cells that are linked to this state
    cells = SA_query(agent.SA_decoded, 'state', state);
    cells(cells(:,2) == 3,:) = [];
    
    % continue to next iteration if there are no SA cells for this state
    %if isempty(cells)
    %    continue
    %end
    
    % dealing with diagonal (or not) action sets
    cells = sortrows(cells, 2);
    
    [x, y] = cellCompass(cells, [], analysed_cells, false, world.worldSize_x, diagonal_actions);
    
    tmp_plt = subplot(world.worldSize_x, world.worldSize_y, convertColToRow(state, world.worldSize_x));
    h = compass_copy(colour, x,y);
    set(h,'LineWidth',2)
    if state == find(world.state(:,:,1))
        co = fig.Color;
        set(tmp_plt, 'box', 'on', 'Visible', 'on', 'xtick', [], 'ytick', [],'color',co)
    elseif ismember(state, world.walls)
        %set(tmp_plt, 'box', 'on', 'Visible', 'on', 'xtick', [], 'ytick', [])
    end
    
end
%{

%}