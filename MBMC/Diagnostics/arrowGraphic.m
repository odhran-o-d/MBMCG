function display = arrowGraphic(display, arrows, state, direction, strength, maximum, worldSize, scaleDisplay)

% given arrows as colourmaps, a direction, and the relevant strength, will return the appropriate
% arrow with the appropriate opacity

switch direction
    case 'NW'
        if scaleDisplay == true
            display{state - worldSize*3 - 1} = arrows{1} * (strength / maximum);
        else
            display{state - worldSize*3 - 1} = arrows{1};
        end
    case 'W'
        if scaleDisplay == true
            display{state - worldSize*3} = arrows{2} * (strength / maximum);
        else
            display{state - worldSize*3} = arrows{2};
        end
    case 'SW'
        if scaleDisplay == true
            display{state - worldSize*3 + 1} = arrows{3} * (strength / maximum);
        else
            display{state - worldSize*3 + 1} = arrows{3};
        end
    case 'N'
        if scaleDisplay == true
            display{state - 1} = arrows{4} * (strength / maximum);
        else
            display{state - 1} = arrows{4};
        end
    case 'S'
        if scaleDisplay == true
            display{state + 1} = arrows{6} * (strength / maximum);
        else
            display{state + 1} = arrows{6};
        end
    case 'NE'
        if scaleDisplay == true
            display{state + worldSize*3 - 1} = arrows{7} * (strength / maximum);
        else
            display{state + worldSize*3 - 1} = arrows{7};
        end
    case 'E'
        if scaleDisplay == true
            display{state + worldSize*3} = arrows{8} * (strength / maximum);
        else
            display{state + worldSize*3} = arrows{8};
        end
    case 'SE'
        if scaleDisplay == true
            display{state + worldSize*3 + 1} = arrows{9} * (strength / maximum);
        else
            display{state + worldSize*3 + 1} = arrows{9};
        end
end

end