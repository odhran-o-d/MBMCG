function [x, y] = cellCompass(cells, chosen_cell, criterion, normalise_criterion, worldSize, diagonal_actions)

%% Produce XY Data
% Take Cells That Are Linked to A State, and assign them to the appropriate
% direction.

if normalise_criterion
    max_criterion = max(criterion(:));
    criterion = criterion ./ max_criterion;
end

if diagonal_actions == false
    cmp_data = struct('W', 0, 'N', 0, 'S', 0, 'E', 0);
    for i = 1:size(cells, 1)
        if ~any(chosen_cell)
            magnitude = criterion(cells(i, end));
        elseif any(chosen_cell)
            magnitude = criterion(chosen_cell, cells(i, end));
        else
            error('!!!')
        end
        switch cells(i, 2)
            case 1
                cmp_data.N = magnitude;
            case 2
                cmp_data.E = magnitude;
            case 3
                error()
            case 4
                cmp_data.S = magnitude;
            case 5
                cmp_data.S = magnitude;
            otherwise
                error()
        end
    end
    [x, y] = pol2cart(deg2rad([90, 0, 270, 180]), [cmp_data.N, cmp_data.E, cmp_data.S, cmp_data.W]);
else
    cmp_data = struct('NW', 0, 'W', 0, 'SW', 0, 'N', 0, 'S', 0, 'NE', 0, 'E', 0, 'SE', 0);
    for i = 1:size(cells, 1)
        if ~any(chosen_cell)
            magnitude = criterion(cells(i, end));
        elseif any(chosen_cell)
            magnitude = criterion(chosen_cell, cells(i, end));
        else
            error('!!!')
        end
        switch cells(i, 2)
            case 1
                cmp_data.NW = magnitude;
            case 2
                cmp_data.W = magnitude;
            case 3
                cmp_data.SW = magnitude;
            case 4
                cmp_data.N = magnitude;
            case 5
                
            case 6
                cmp_data.S = magnitude;
            case 7
                cmp_data.NE = magnitude;
            case 8
                cmp_data.E = magnitude;
            case 9
                cmp_data.SE = magnitude;
            otherwise
                error()
        end
    end
    [x, y] = pol2cart(deg2rad([0, 45, 90, 135, 180, 225, 270, 315]), ...
        [cmp_data.E, cmp_data.NE, cmp_data.N, cmp_data.NW, cmp_data.W, cmp_data.SW, cmp_data.S, cmp_data.SE]);
end

end