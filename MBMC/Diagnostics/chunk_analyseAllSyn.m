function chunk_analyseAllSyn(agent, actions, sample_size, threshold, sort_chunks)

if sort_chunks == true
    [~,  sorted_idx] = sort(sum(agent.chunktoSA_synapses'), 'descend');
    idx = sorted_idx(1:sample_size);
else
    idx = [];
    while numel(idx) < sample_size
        idx = randperm(numel(agent.chunk_cells), sample_size);
        for i = 1:numel(idx)
            if ~any(agent.chunktoSA_synapses(idx(i), :) > threshold)
                idx(i) = [];
            end
        end
        idx = [idx randperm(numel(agent.chunk_cells), sample_size-numel(idx))];
    end
end

for i = idx
    chunk_analyseSyn(10, actions, agent, false, true, true, i);
end

end