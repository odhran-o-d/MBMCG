function [firingRates] = WTA_Competition(firingRates)

% Implements WTA competition. No cell will not fire if no firing cells
% originally.

if ~any(firingRates(:))
    return
end

[~, idx]=nanmax(firingRates(:));

firingRates(:) = 0;
firingRates(idx) = 1;
end
