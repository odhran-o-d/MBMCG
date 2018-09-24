function [x, y] = makePositions(worldSize_x, worldSize_y)

%% This function creates an X,Y position that is in the world

validX = false;
validY = false;

while validX == false
    % Create random x position
    x = randi(worldSize_x, 1);
    
    % Is X in the world?
    if x > 0 || x <= worldSize_x
        validX = true;
    end
end

% Do the same for y position
while validY == false
    y = randi(worldSize_y, 1);
    if y > 0 || y <= worldSize_x
        validY = true;
    end
end

end