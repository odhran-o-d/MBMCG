
function SA_analysis(recurrent_synapses, SA_decoded, cell_of_interest, worldSize_x, worldSize_y, num_motor)

%% create a 3D index of xy(states) and z(action)

% create a worldSize_x by worldSize_y by numel(num_motor) matrix
index = zeros(worldSize_y, worldSize_x, num_motor(2));

% assign each SA cell to appropriate position

[x, y] = ind2sub([worldSize_y worldSize_x], SA_decoded(:,1));
z = SA_decoded(:,2);
for cell = 1:size(SA_decoded, 1);
    index(x(cell), y(cell), z(cell)) = SA_decoded(cell, 3);
end
    
%% Produce Figures of the Cells that the COI synapses to:
 
    % get the value of COI synapses

    [~, idx] = ismember(index, find(recurrent_synapses(cell_of_interest,:)));
activation = zeros(size(idx));  
    
% arrange them into an indexed structure
    
    for z = 1:size(idx,3)
        for y = 1:size(idx, 2)
            for x = 1:size(idx,1)
                
                if idx(x, y, z) ~= 0
    activation(x, y, z) = recurrent_synapses(cell_of_interest,index(x,y,z));
                end
            end
        end
    end
    
    %[~, ndx] = ismember(cell_of_interest, list(:,3));
    %ndx = list(ndx, 1)
    %[x, y] = ind2sub([worldSize_y worldSize_x], world(ndx);
    
    % graph
    activation_summed = zeros(size(activation(:,:,1)));
    for z = 1:size(idx,3)
    figure(); imagesc(activation(:,:,z)); colorbar;
    activation_summed = activation_summed + activation(:,:,z);
    end
    
    figure(); imagesc(activation_summed); colorbar;
    
    
end