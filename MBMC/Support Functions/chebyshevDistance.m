function out = chebyshevDistance(worldSize_x, worldSize_y, location1, location2, boolDistance)

if ~(size(location1, 1) == 1 || size(location2, 1) == 1)
    error('At least one location must be an index or vector of indices.')
end

if worldSize_x ~= worldSize_y
    error('worldSize_x & worldSize_y must be the same size. Not technically for this function but for the function it was created to work in. Here untested.')
end

% if both locations are indexes or co-ords
if isvector(location1) && isvector(location2)
    % if location is given as a single index value, convert to co-ords
    if isscalar(location1)==1
        [x1, y1] = ind2sub([worldSize_x, worldSize_y], location1);
    else
        x1 = location1(1);
        y1 = location1(2);
    end
    
    if isscalar(location2)==1
        [x2, y2] = ind2sub([worldSize_x, worldSize_y], location2);
    else
        x2 = location2(1);
        y2 = location2(2);
    end
    
    % calculate Chebyshev distance between them
    distance = max(abs(x1-x2), abs(y1-y2));
    out = distance;
    
else
    
    if ndims(location1) > 2 || ndims(location2) > 2 %#ok<ISMAT>
        error('Only 1D or 2D matrices permitted.')
    end
    
    % find which location is the index/coordinate reference point
    % for each index of the other, calculate the chebyshev using the above
    % code
    
    if isvector(location1)
        reference = location1;
        matrix = location2;
    elseif isvector(location2)
        reference = location2;
        matrix = location1;
    else
        error('"If" error.')
    end
    
    boolMatrix = zeros(size(matrix));
    
    for row = 1:size(matrix,1)
        for col = 1:size(matrix,2)
            tmpDist = chebyshevDistance(worldSize_x, worldSize_y, reference, [row col]);
            if tmpDist == boolDistance
                boolMatrix(row,col) = 1;
            end
        end
    end
    
    out = boolMatrix;
    
end
end