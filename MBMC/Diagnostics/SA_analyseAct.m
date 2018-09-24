function [display] = SA_analyseAct(worldType, worldSize, actions, SA_cells, SA_decoded, display_figure, scaleDisplay)

%% Import Arrows
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

% Make an array to display the arrows in.
switch worldType
    case 'maze'
        display = repmat({uint8(zeros(16))}, [worldSize*3 worldSize*3]);
    case 'arm'
        worldSize = 100;
        display = repmat({uint8(zeros(16))}, [worldSize*3 worldSize*3]);
end

%% Retrieve the SA layer's activation and display
% Thresholding by the least active SA cell (within SA_decoded).
switch worldType
    case 'maze'
        minimum_activation = min(min(SA_cells(SA_decoded(:,3))));
    case 'arm'
        minimum_activation = min(min(SA_cells(SA_decoded(:,6))));
end

SA_cells = SA_cells - minimum_activation;

% Get maximum activation that remains.
maximum_activation = max(max(SA_cells));

for cell = 1:numel(SA_cells)
    
    % Check that cell has a sensory and motor conneciton i.e. is within
    % SA_decoded.
    switch worldType
        
        case 'maze'
            %if any(ismember(SA_decoded(:,3), cell))
            if any(SA_decoded(:,3) == cell) 
            
                [y, x] = ind2sub([worldSize worldSize], SA_decoded(find(SA_decoded(:,3) == cell),1));
                SA_state = (y * 3 - 1) + ((worldSize*3) + (worldSize*3) * 3 * (x-1));
                display{SA_state}(:) = 255;
                
                direction = SA_decoded(find(SA_decoded(:,3) == cell),2);
                direction = actions{direction};
                
                updateDisplay(direction, scaleDisplay);
                
            end
            
        case 'arm'
            if any(ismember(SA_decoded(:,6), cell))
                cell_SA = SA_decoded(SA_decoded(:,6) == cell,:);
                j1_angle_firing = cell_SA(3); j2_angle_firing = cell_SA(4);
                y = j1_angle_firing-200; x = j2_angle_firing-300;
                SA_state = (y * 3 - 1) + ((worldSize*3) + (worldSize*3) * 3 * (x-1));
                display{SA_state}(:) = 255;
                
                direction = SA_decoded(find(SA_decoded(:,6) == cell),5);
                
                updateDisplay(direction, scaleDisplay);
                
            end
            
    end
end

if display_figure == true
    try
        figure(); image(cell2mat(display)); colormap(copper); title('Activation (adjusted) in SA layer')
    catch err
        disp(err.message)
    end
end



    function updateDisplay(var, scale)
        switch var
            case 'NW'
                if scale == true
                    display{SA_state - worldSize*3 - 1} = arrows{1} * (SA_cells(cell) / maximum_activation);
                else
                    display{SA_state - worldSize*3 - 1} = arrows{1};
                end
            case 'W'
                if scale == true
                    display{SA_state - worldSize*3} = arrows{2} * (SA_cells(cell) / maximum_activation);
                else
                    display{SA_state - worldSize*3} = arrows{2};
                end
            case 'SW'
                if scale == true
                    display{SA_state - worldSize*3 + 1} = arrows{3} * (SA_cells(cell) / maximum_activation);
                else
                    display{SA_state - worldSize*3 + 1} = arrows{3};
                end
            case 'N'
                if scale == true
                    display{SA_state - 1} = arrows{4} * (SA_cells(cell) / maximum_activation);
                else
                    display{SA_state - 1} = arrows{4};
                end
            case 'S'
                if scale == true
                    display{SA_state + 1} = arrows{6} * (SA_cells(cell) / maximum_activation);
                else
                    display{SA_state + 1} = arrows{6};
                end
            case 'NE'
                if scale == true
                    display{SA_state + worldSize*3 - 1} = arrows{7} * (SA_cells(cell) / maximum_activation);
                else
                    display{SA_state + worldSize*3 - 1} = arrows{7};
                end
            case 'E'
                if scale == true
                    display{SA_state + worldSize*3} = arrows{8} * (SA_cells(cell) / maximum_activation);
                else
                    display{SA_state + worldSize*3} = arrows{8};
                end
            case 'SE'
                if scale == true
                    display{SA_state + worldSize*3 + 1} = arrows{9} * (SA_cells(cell) / maximum_activation);
                else
                    display{SA_state - worldSize*3 + 1} = arrows{9};
                end
        end
    end



end

