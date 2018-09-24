function output = chunkCompare()

% Small Open
[~, agent, world, ~] = MBMC_master('GatingColWTA', {"SmallOpen", 10, 10}, [], []);
[~, agent, world, ~] = MBMC_master('LearningChunks', {}, agent, world);
chunks = chunkTrials(agent, world, true);
nochunks = chunkTrials(agent, world, false);
so_chunk_sorted = valueSort(chunks);
so_nochunk_sorted = valueSort(nochunks);

% Small Maze
[~, agent, world, ~] = MBMC_master('GatingColWTA', {"SmallMaze", 10, 10}, [], []);
[~, agent, world, ~] = MBMC_master('LearningChunks', {}, agent, world);
chunks = chunkTrials(agent, world, true);
nochunks = chunkTrials(agent, world, false);
sm_chunk_sorted = valueSort(chunks);
sm_nochunk_sorted = valueSort(nochunks);

% Large Open
[~, agent, world, ~] = MBMC_master('GatingColWTA', {"LargeOpen", 20, 20}, [], []);
[~, agent, world, ~] = MBMC_master('LearningChunks', {}, agent, world);
chunks = chunkTrials(agent, world, true);
nochunks = chunkTrials(agent, world, false);
lo_chunk_sorted = valueSort(chunks);
lo_nochunk_sorted = valueSort(nochunks);

% Large Maze
[~, agent, world, ~] = MBMC_master('GatingColWTA', {"LargeMaze", 20, 20}, [], []);
[~, agent, world, ~] = MBMC_master('LearningChunks', {}, agent, world);
chunks = chunkTrials(agent, world, true);
nochunks = chunkTrials(agent, world, false);
lm_chunk_sorted = valueSort(chunks);
lm_nochunk_sorted = valueSort(nochunks);

output = struct();
output.so_chunk = so_chunk_sorted;
output.sm_chunk = sm_chunk_sorted;
output.lo_chunk = lo_chunk_sorted;
output.lm_chunk = lm_chunk_sorted;
output.so_nochunk = so_nochunk_sorted;
output.sm_nochunk = sm_nochunk_sorted;
output.lo_nochunk = lo_nochunk_sorted;
output.lm_nochunk = lm_nochunk_sorted;

%{
figure();
hold on
plot(output.so_chunk(:,1), output.so_chunk(:,2), '--');
plot(output.sm_chunk(:,1), output.sm_chunk(:,2), '--');
plot(output.lo_chunk(:,1), output.lo_chunk(:,2), '--');
plot(output.lm_chunk(:,1), output.lm_chunk(:,2), '--');
plot(output.so_nochunk(:,1), output.so_nochunk(:,2));
plot(output.sm_nochunk(:,1), output.sm_nochunk(:,2));
plot(output.lo_nochunk(:,1), output.lo_nochunk(:,2));
plot(output.lm_nochunk(:,1), output.lm_nochunk(:,2));
hold off
legend;
%}

comparisonFigure(output)

end