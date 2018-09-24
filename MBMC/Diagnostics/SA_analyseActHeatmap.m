function [display] = SA_analyseActHeatmap(worldType, diagonalActions, worldSize, actions, SA_cells, SA_decoded, display_figure)

% Make an array to display the arrows in.
for i = 1:numel(unique(SA_decoded(:,2)))
    display{i} = zeros(worldSize);
end

%% Retrieve the SA layer's activation and display
% Thresholding by the least active SA cell (within SA_decoded).
switch worldType
    case 'maze'
        minimum_activation = min(min(SA_cells(SA_decoded(:,3))));
    case 'arm'
        minimum_activation = min(min(SA_cells(SA_decoded(:,3))));
end

SA_cells = SA_cells - minimum_activation;

% Get maximum activation that remains.
maximum_activation = max(max(SA_cells));

for cell = 1:numel(SA_cells)
    
    % Check that cell has a sensory and motor conneciton i.e. is within
    % SA_decoded.
    switch worldType
        
        case 'maze'
            if any(ismember(SA_decoded(:,3), cell)) == 1
                
                
                SA_state = SA_decoded(SA_decoded(:,3) == cell, 1);
                direction = SA_decoded(SA_decoded(:,3) == cell,2);
                display{direction}(SA_state) = SA_cells(cell);
                
            end
    end
end

if display_figure == true
    figure()
    switch diagonalActions
        case true
    for i = 1:9
        subplot(3, 3, i)
        imagesc(display{i}, [0 1]);
        title(actions{i})
        colorbar
    end
        case false
            for i = 1:9
                switch i
                    case 1
                        assert(strcmp(actions{i}, 'N'))
                        subplot(3, 3, 2)
                        imagesc(display{i}, [0 1]);
                        title(actions{i})
                    case 2
                        assert(strcmp(actions{i}, 'E'))
                        subplot(3, 3, 6)
                        imagesc(display{i}, [0 1]);
                        title(actions{i})
                        colorbar
                    case 3
                        assert(strcmp(actions{i}, ''))
                        subplot(3, 3, 5)
                        imagesc(display{i}, [0 1]);
                        title(actions{i})
                    case 4
                        assert(strcmp(actions{i}, 'S'))
                        subplot(3, 3, 8)
                        imagesc(display{i}, [0 1]);
                        title(actions{i})
                    case 5
                        assert(strcmp(actions{i}, 'W'))
                        subplot(3, 3, 4)
                        imagesc(display{i}, [0 1]);
                        title(actions{i})
                    otherwise
                end
                
            end
    end
end
end

