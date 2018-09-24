function [vals, utility] = chunkUtility()

vals = {'0.05', '0.1', '0.2', '0.3', '0.4', '0.5', '0.6', '0.7', '0.8', '0.9', '1'};
num_vals = numel(vals);
utility = {};

% Learn agent
[~, agent, world, switches] = MBMC_master('GatingColWTA', {}, [], []);

for i = 1:num_vals
    % Learn Chunks
    [~, tmp_agent, tmp_world, switches] = MBMC_master('LearningChunks', {str2double(vals{i})}, agent, world);
    
    % Test Chunks
    tmp_results = chunkTrials(tmp_agent, tmp_world, true);
    tmp_results = valueSort(tmp_results);
    utility{i} = tmp_results;
end

scatterfig(vals, utility)

end

