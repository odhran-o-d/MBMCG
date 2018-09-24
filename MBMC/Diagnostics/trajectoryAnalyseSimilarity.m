function [similarity, normalised_similarity] = trajectoryAnalyseSimilarity(occupancy_array)

occupancy_len = zeros([1 numel(occupancy_array)]);
similarity = occupancy_len;
normalised_similarity = occupancy_len;

for i = 1:numel(occupancy_array)
    
    [tmp_highest, tmp_similarity, tmp_occupancy] = trajectoryOverlap(occupancy_array, i);
    similarity(i) = tmp_similarity;
    normalised_similarity(i) = similarity(i)/numel(find(occupancy_array{i}));
    
end

end