function SA_analyseSyn_arm(worldSize, synapses, SA_decoded, display_index, chosen_cell)

% Analyses a set of synapses leading from a cell to an SA layer and produces a graph of the state/actions that said cell connects to. 
% DOESN'T WORK YET

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

display = repmat({uint8(zeros(16))}, [10*3 10*3]);

%% Provide index of cells with synapses above a threshold value, and asks which cell to investigate.
mapping_threshold = 0.2;

if ~exist('display_index','var');
    display_index = input('Do you want to see available cells? Y/N: ');
end

idx = [];
indices = synapses < mapping_threshold;
thresholded = synapses;
thresholded(indices) = 0;
thresholded(isnan(thresholded)) = 0;
%}

for cell = 1:size(synapses,1);
    if any(thresholded(cell,:))
        idx = [idx cell];
    end
end


if display_index == 'Y'
    disp(idx);
end

if ~exist('chosen_cell','var')
    chosen_cell = input('Enter the cell whose synapses you wish to view: ');
end

%% Retrieve the cell's synapses and analyse.




%{
% Thresholding by the least active SA cell (within SA_decoded).
minimum_activation = min(min(SA_cells(SA_decoded(:,6))));
SA_cells = SA_cells - minimum_activation;

% Get maximum activation that remains.
maximum_activation = max(max(SA_cells));

for column = 1:size(SA_cells,3)
    
    [~, cell] = max(SA_cells(:,:,column));
    cell = sub2ind(size(SA_cells), cell, 1, column);
    
    % Check that cell has a sensory and motor conneciton i.e. is within
    % SA_decoded.
    if any(ismember(SA_decoded(:,6), cell)) == 1
        
        SA_decoded_line = SA_decoded(SA_decoded(:,6)==cell,:);
        %[y, x] = ind2sub([angle_layer_size angle_layer_size], SA_decoded(find(SA_decoded(:,3) == cell),1));
        j1_angle = SA_decoded_line(1); j2_angle = SA_decoded_line(2);
        [angle_cells] = Experiment66_angles_gauss(j1_angle, j2_angle, gauss_deviation);
        j1_angle = find(WTA_Competition(angle_cells{1})); j2_angle = find(WTA_Competition(angle_cells{2}));
        SA_state = (j1_angle * 3 - 1) + ((angle_layer_size*3) + (angle_layer_size*3) * 3 * (j2_angle-1));
        display{SA_state}(:) = 255;
        
        switch SA_decoded_line(5)
            
            case 6
                display{SA_state - angle_layer_size*3 - 1} = arrows{1};
                
            case 4
                display{SA_state - angle_layer_size*3} = arrows{2};
                
            case 9
                display{SA_state - angle_layer_size*3 + 1} = arrows{3};
                
            case 1
                display{SA_state - 1} = arrows{4};
                
            case 2
                display{SA_state + 1} = arrows{6};
                
            case 7
                display{SA_state + angle_layer_size*3 - 1} = arrows{7};
                
            case 3
                display{SA_state + angle_layer_size*3} = arrows{8};
                
            case 8
                display{SA_state + angle_layer_size*3 + 1} = arrows{9};
                
        end
    end
end

%}




% Ascertain the strongest value in the entire synapse matrix (i.e. the
% strongest synapse in the entire layer).
maximum_synapses = max(max(synapses));


% Loop through the synapses, adding a representation of each onto the
% 'display' matrix.
for SA_synapse = find(thresholded(chosen_cell,:))
    
    if any(SA_decoded(find(SA_decoded(:,6) == SA_synapse),1:2)) == 0;
        continue
    end
    
    j1_angle = SA_decoded(find(SA_decoded(:,6) == SA_synapse),1); j2_angle = SA_decoded(find(SA_decoded(:,6) == SA_synapse),2);
    SA_state = (y * 3 - 1) + ((worldSize*3) + (worldSize*3) * 3 * (x-1));
    display{SA_state}(:) = 255;
    
    switch SA_decoded(find(SA_decoded(:,3) == SA_synapse),2)
        
        case 1
            display{SA_state - 10*3 - 1} = arrows{1} * (synapses(chosen_cell,SA_synapse) / maximum_synapses);
            
        case 2
            display{SA_state - 10*3} = arrows{2} * (synapses(chosen_cell,SA_synapse) / maximum_synapses);
            
        case 3
            display{SA_state - 10*3 + 1} = arrows{3} * (synapses(chosen_cell,SA_synapse) / maximum_synapses);
            
        case 4
            display{SA_state - 1} = arrows{4} * (synapses(chosen_cell,SA_synapse) / maximum_synapses);
            
        case 6
            display{SA_state + 1} = arrows{6} * (synapses(chosen_cell,SA_synapse) / maximum_synapses);
            
        case 7
            display{SA_state + 10*3 - 1} = arrows{7} * (synapses(chosen_cell,SA_synapse) / maximum_synapses);
            
        case 8
            display{SA_state + 10*3} = arrows{8} * (synapses(chosen_cell,SA_synapse) / maximum_synapses);
            
        case 9
            display{SA_state + 10*3 + 1} = arrows{9} * (synapses(chosen_cell,SA_synapse) / maximum_synapses);
            
    end
    
    %chunk_display{SA_decoded(find(SA_decoded(:,3) == chunk_SA),1)} = arrows{SA_decoded(find(SA_decoded(:,3) == chunk_SA),2)};
    
end

try
    figure(); image(cell2mat(display)); colormap(copper); title(chosen_cell)
catch err
    disp(err.message)
end

fprintf('Synapses, sorted: ')
disp(' ')
disp(sort(synapses(chosen_cell,find(synapses(chosen_cell,:))), 'descend'))

end