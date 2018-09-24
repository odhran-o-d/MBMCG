function super_analysis(num_state, num_chunk, super_cells, noNaNchunktostate, noNaNchunktosuper, noNaNsupertochunk)
find(super_cells > 0.5)

[~, idx] = max(super_cells);
%super_cells(:) = 0;
%super_cells(idx) = 1;

chunk_cells = zeros(num_chunk);
chunk_cells = dot([repmat(super_cells(:),[1,numel(chunk_cells)])], [noNaNsupertochunk]);
chunk_cells = reshape(chunk_cells,num_chunk);

% divisive
%chunk_cells = (chunk_cells/max(max(chunk_cells)));

figure(); plot(sort(chunk_cells)); title('Total Number of Chunk Cells Activated by Super-Chunk cells');

state_cells = zeros(num_state);
state_cells = dot([repmat(chunk_cells(:),[1,numel(state_cells)])], [noNaNchunktostate]);
state_cells = reshape(state_cells,num_state);

figure(); imagesc(state_cells); colorbar; title('Activation from currently firing Super-Chunk cells');

[~, idx] = max(super_cells);
figure(); plot(noNaNsupertochunk(:,idx)), title('Max Super => Chunk');
figure(); plot(noNaNchunktosuper(idx,:)), title('Max Chunk => Super');

end