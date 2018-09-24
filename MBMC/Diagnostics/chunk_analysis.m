state_save
state_cells

% Make matrix to store cumulative chunk effect
chunk_effect_c2s = zeros(10);
chunk_effect_s2c = zeros(10);

[~, idx] = find(agent.chunk_cells);
for count = 1:numel(idx)
chunk_effect_c2s = chunk_effect_c2s + agent.chunk_cells(idx(count)) * reshape(agent.chunktoSA_synapses(idx(count),:), [10 10]);
chunk_effect_s2c = chunk_effect_s2c + agent.chunk_cells(idx(count)) * reshape(agent.SAtochunk_synapses(:,idx(count)), [10 10]);
end
figure(); imagesc(chunk_effect_c2s); colorbar; title('Chunk => State')
figure(); imagesc(chunk_effect_s2c); colorbar; title('State => Chunk')




figure(); imagesc(state_cells - state_save); colorbar; title('Current Firing Rates vs. Original State Activation')

[~, idx] = max(agent.chunk_cells);
figure(); imagesc(reshape(statetochunk_synapses(:,idx), [20 20])); colorbar; title('Max State => Chunk')
figure(); imagesc(reshape(chunktostate_synapses(idx,:), [20 20])); colorbar; title('Max Chunk => State')