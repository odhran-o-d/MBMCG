function [idx, max_similarity, overlap] = trajectoryOverlap(occupancy_array, trajectoryID)

max_similarity = 0;
idx = NaN;
for i = 1:numel(occupancy_array)
    if i ~= trajectoryID
        similarity = numel(find(occupancy_array{trajectoryID} & occupancy_array{i}));
        if similarity > max_similarity
            max_similarity = similarity;
            idx = i;
        end
    end
end

if ~isnan(idx)
overlap = occupancy_array{trajectoryID} & occupancy_array{idx};
else
    overlap = zeros(size(occupancy_array{trajectoryID}));
end
end