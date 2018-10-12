function [firingRates] = WTA_Competition(firingRates)

% Implements WTA competition. No cell will not fire if no firing cells
% originally.

if ~any(firingRates(:))
    return
end

assert(all(isfinite(firingRates(:))));
assert(all(~isnan(firingRates(:))))

max_firing = find(firingRates == max(firingRates));
idx = max_firing(randi(numel(max_firing)));
%[~, idx] = nanmax(firingRates(:));

firingRates(:) = 0;
firingRates(idx) = 1;
end
