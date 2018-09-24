function SA_analyseSyn_2DMap(figure_type, world, actions, synapses, SA_decoded, fromto, display_index, chosen_cell)

% Analyses a set of synapses leading from a cell to an SA layer and produces a graph of the state/actions that said cell connects to.
diagonal_actions = true;
normalise_criterion = true;

switch figure_type
    case 'arrows'
        arrows = arrowImport();
        display = repmat({uint8(zeros(16))}, [world.worldSize_x*3 world.worldSize_x*3]);
    case 'compass'
    otherwise error('Invalid Figure Type')
end

%% Setup 'From' or 'To'
switch fromto
    case 'from'
        synapses = synapses';
    case 'to'
        synapses = synapses;
end

%% Provide index of cells with synapses above a threshold value, and asks which cell to investigate.
% Threshold synaptic matrix
idx = [];
mapping_threshold = 0.002;
indices = synapses < mapping_threshold;
thresholded = synapses;
thresholded(indices) = 0;
thresholded(isnan(thresholded)) = 0;

if ~exist('display_index','var');
    display_index = input('Do you want to see available cells? Y/N: ', 's');
end

for cell = 1:size(synapses,1);
    if any(thresholded(cell,:))
        idx = [idx cell];
    end
end

switch display_index
    case 'Y'
        disp(idx);
end

if ~exist('chosen_cell','var')
    chosen_cell = input('Enter the cell whose synapses you wish to view: ');
end

%% Retrieve a cell's synapses and analyse.
% Ascertain the strongest value in the entire synapse matrix (i.e. the
% strongest synapse in the entire layer).
maximum_synapses = 1;


% Loop through the synapses, adding a representation of each onto the
% 'display' matrix.

switch figure_type
    case 'arrows'
        for SA_synapse = find(thresholded(chosen_cell,:))
            
            if any(SA_decoded(find(SA_decoded(:,3) == SA_synapse),1)) == 0;
                continue
            end
            
            
            [y, x] = ind2sub([world.worldSize_x world.worldSize_x], SA_decoded(find(SA_decoded(:,3) == SA_synapse),1));
            SA_state = (y * 3 - 1) + ((world.worldSize_x*3) + (world.worldSize_x*3) * 3 * (x-1));
            display{SA_state}(:) = 255;
            direction = SA_decoded(find(SA_decoded(:,3) == SA_synapse),2);
            direction = actions{direction};
            scaleDisplay = false;
            strength = synapses(chosen_cell,SA_synapse);
            display = arrowGraphic(display, arrows, SA_state, direction, strength, maximum_synapses, world.worldSize_x, scaleDisplay);
            
        end
        
        try
            figure(); image(cell2mat(display)); colormap(copper); title(sprintf('%s %d', fromto, chosen_cell))
        catch err
            disp(err.message)
        end
        
    case 'compass'
        
        for state = 1:prod([world.worldSize_x, world.worldSize_x])
            
            if ismember(state, world.walls)
                colour = [0.2 0.2 0.2];
            else
                colour = [1 1 1];
            end
            
            % look up cells that are linked to this state
            cells = SA_query(SA_decoded, 'state', state);
            cells(cells(:,2) == 3,:) = [];
            
            % dealing with diagonal (or not) action sets
            cells = sortrows(cells, 2);
            %BUG!! CRITERION ONLY TAKES ONE DIMENSION, NOT TWO. WORKS FOR
            %ACTIVATIONS BUT NOT SYNAPSES
            [x,y] = cellCompass(cells, chosen_cell, synapses, normalise_criterion, world.worldSize_x, diagonal_actions);
            
            tmp_plt = subplot(world.worldSize_x, world.worldSize_y, convertColToRow(state, world.worldSize_x));
            h = compass_copy(colour, x,y);
            set(h,'LineWidth',2)
        end
    otherwise error('Invalid Figure Type')
end

fprintf('Synapses, sorted: ')
disp(' ')
disp(sort(synapses(chosen_cell,find(synapses(chosen_cell,:))), 'descend'))

end