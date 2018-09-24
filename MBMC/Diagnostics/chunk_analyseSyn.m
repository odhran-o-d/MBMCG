function display = chunk_analyseSyn(worldSize, actions, agent, display_index, display_figure, scale_figure, chosen_cell)

% Analyses whic SA cells that a particular chunk cell is synapsed to, and
% the strength of those synapses.

%% Parameters

if ~exist('display_figure','var');
display_figure = true;
end

if ~exist('scale_figure','var');
scale_figure = true;
end

%% Import arrows.
arrows = repmat({uint8(zeros(16))}, [3 3]);
arrows{1} = imread('arrow_nw.png');
arrows{2} = imread('arrow_w.png');
arrows{3} = imread('arrow_sw.png');
arrows{4} = imread('arrow_n.png');
arrows{6} = imread('arrow_s.png');
arrows{7} = imread('arrow_ne.png');
arrows{8} = imread('arrow_e.png');
arrows{9} = imread('arrow_se.png');

for arrow = 1:numel(arrows);
    arrowNormalised = arrows{arrow};
    arrowNormalised(arrowNormalised > 0) = 255;
    arrows{arrow} = arrowNormalised;
end

display = repmat({uint8(zeros(16))}, [worldSize*3 worldSize*3]);

%% Provide index of cells with synapses above a threshold value, and asks which cell to investigate.
mapping_threshold = 0.00000003;

if ~exist('display_index','var');
    display_index = input('Do you want to see available cells? Y/N: ', 's');
end

idx = [];
indices = agent.chunktoSA_synapses < mapping_threshold;
thresholded = agent.chunktoSA_synapses;
thresholded(indices) = 0;
thresholded(isnan(thresholded)) = 0;
%}

for cell = 1:size(agent.chunktoSA_synapses,1);
    if any(thresholded(cell,:))
        idx = [idx cell];
    end
end


if display_index == true
    disp(idx);
end

if ~exist('chosen_cell','var')
    chosen_cell = input('Enter the cell whose synapses you wish to view: ');
end

%% Retrieve the cell's synapses and analyse.
% Ascertain the strongest value in the entire synapse matrix (i.e. the
% strongest synapse in the entire layer).
maximum_synapses = max(max(agent.chunktoSA_synapses));

% for each connected SA cell:
for connected_SA = find(thresholded(chosen_cell,:));
    
    % if SA cell is in SA_decoded:
    if any(agent.SA_decoded(find(agent.SA_decoded(:,3) == connected_SA),1)) == 0;
        continue
    end
    
    % add the state/action of that SA cell to the display and modify by
    % strength of the synaptic connections
    
    [y, x] = ind2sub([worldSize worldSize], agent.SA_decoded(find(agent.SA_decoded(:,3) == connected_SA),1));
    SA_state = (y * 3 - 1) + ((worldSize*3) + (worldSize*3) * 3 * (x-1));
    display{SA_state}(:) = 255;
    
    direction = actions{agent.SA_decoded(find(agent.SA_decoded(:,3) == connected_SA),2)};
    display = arrowGraphic(display, arrows, SA_state, direction, agent.chunktoSA_synapses(chosen_cell,connected_SA), maximum_synapses, worldSize, scale_figure);
    %{
    switch direction
        
        case 'NW'
            display{SA_state - worldSize*3 - 1} = arrows{1} * (agent.chunktoSA_synapses(chosen_cell,connected_SA) / maximum_synapses);
            
        case 'W'
            display{SA_state - worldSize*3} = arrows{2} * (agent.chunktoSA_synapses(chosen_cell,connected_SA) / maximum_synapses);
            
        case 'SW'
            display{SA_state - worldSize*3 + 1} = arrows{3} * (agent.chunktoSA_synapses(chosen_cell,connected_SA) / maximum_synapses);
            
        case 4
            display{SA_state - 1} = arrows{4} * (agent.chunktoSA_synapses(chosen_cell,connected_SA) / maximum_synapses);
            
        case 6
            display{SA_state + 1} = arrows{6} * (agent.chunktoSA_synapses(chosen_cell,connected_SA) / maximum_synapses);
            
        case 7
            display{SA_state + worldSize*3 - 1} = arrows{7} * (agent.chunktoSA_synapses(chosen_cell,connected_SA) / maximum_synapses);
            
        case 8
            display{SA_state + worldSize*3} = arrows{8} * (agent.chunktoSA_synapses(chosen_cell,connected_SA) / maximum_synapses);
            
        case 9
            display{SA_state + worldSize*3 + 1} = arrows{9} * (agent.chunktoSA_synapses(chosen_cell,connected_SA) / maximum_synapses);
            
    end
    %}
    
end

if display_figure == true
    try
        figure(); image(cell2mat(display)); colormap(copper); title(chosen_cell)
        fprintf('Chunk''s strongest synapse = %d', max(agent.chunktoSA_synapses(chosen_cell,:)));
disp(' ')
    catch err
        disp(err.message)
    end
end

%{
fprintf('Synapses, sorted: ')
disp(' ')
disp(sort(agent.chunktoSA_synapses(chosen_cell,find(agent.chunktoSA_synapses(chosen_cell,:))), 'descend'))
%}


end