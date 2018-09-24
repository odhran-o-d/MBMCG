function cell_array_flattened = cell_drill(cell_array, drill_level, cell_array_flattened)
% recursive function to extract matrix data from cell array
% extra parameter: drill level. I.e. how much structure to retain.
% If drill level is 1, will extract cells containing raw matrices.
% If drill level is 2, will extract cells containing cells containing raw
% matrices.
% Etc.

if ~exist('cell_array_flattened', 'var')
    cell_array_flattened = {};
end

for i = 1:length(cell_array)
    switch drill_level
        case 1
            try
            tested = cell_array{i}{1};
            catch err
            end
        case 2
            try
            tested = cell_array{i}{1}{1};
            catch err
            end
        case 3
            try
            tested = cell_array{i}{1}{1}{1};
            catch err
            end
        case 4
            try
            tested = cell_array{i}{1}{1}{1}{1};
            catch err
            end
        case 5
            try
            tested = cell_array{i}{1}{1}{1}{1}{1};
            catch err
            end
        otherwise
            error('No valid drill level')
    end
    
    if exist('err', 'var')
        if isequal(err.identifier, 'MATLAB:cellRefFromNonCell')
            cell_array_flattened = cell_array;
            return
        else error(struct(err))
        end
    end
    
    if iscell(tested) == false
        cell_array_flattened = horzcat(cell_array_flattened, cell_array{i});
    else
        cell_array_flattened = horzcat(cell_array_flattened, cell_drill(cell_array{i}, drill_level));
    end
end

end