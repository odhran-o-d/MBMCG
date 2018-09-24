load('161031_large_gate3_chunks.mat')
chunkTrials
ratio = mean(ratioMat); stdratio = std(ratioMat);
save('161102_results_with_largegate_chunks.mat')
clear all
close all

load('161009_large_chunks.mat')
chunkTrials
ratio = mean(ratioMat); stdratio = std(ratioMat);
save('161102_results_with_largeopen_chunks.mat')
clear all
close all

count_P1 = {};
count_P2 = {};
count_P3 = {};

for i = 1:length(occupancy_A)
    for j = 1:length(occupancy_B)
        if occupancy_A{i}{j}(35) == 1
            count_P2{i} = count_P2{i} + 1;
        elseif occupancy_A{i}{j}(43) == 1
            count_P3{i} = count_P3{i} + 1;
        elseif occupancy_A{i}{j}(36) == 1
            count_P1{i} = count_P1{i} + 1;
        end
    end
end