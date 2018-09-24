function martinetPathAnalysis(sensory_tracked)

count_P1 = zeros([1 length(sensory_tracked)]);
count_P2 = zeros([1 length(sensory_tracked)]);
count_P3 = zeros([1 length(sensory_tracked)]);
count_Awkward = zeros([1 length(sensory_tracked)]);

% get down to the level of actual sensory_tracked data and for each matrix
% count
drill_level = 2;
for i = 1:length(sensory_tracked)
    sensory_drilled = cell_drill(sensory_tracked{i}, drill_level);
    for j = 1:length(sensory_drilled)
        for k = 0:length(sensory_drilled{j}) - 1
            if find(sensory_drilled{j}{end-k}(:,:,1)) == 25
                count_P2(i) = count_P2(i) + 1;
                break
            elseif find(sensory_drilled{j}{end-k}(:,:,1)) == 43
                count_P3(i) = count_P3(i) + 1;
                break
            elseif find(sensory_drilled{j}{end-k}(:,:,1)) == 36
                count_P1(i) = count_P1(i) + 1;
                break
            end
        end
    end
end

sum_trials = sum([count_P1; count_P2; count_P3]);

prob_P1 = count_P1 ./ sum_trials;
prob_P2 = count_P2 ./ sum_trials;
prob_P3 = count_P3 ./ sum_trials;

perc_P1 = prob_P1 * 100;
perc_P2 = prob_P2 * 100;
perc_P3 = prob_P3 * 100;

figure(); boxplot([perc_P1', perc_P2', perc_P3'])
%ylim([0 1.1]);
set(gca, 'XTickLabel', {'P1' 'P2' 'P3'})

end

%{
     0     0     0     0     0     0     0     0     0     0
     0     0     0     1     0     0     0     0     0     0
     0     0     0     1     X     1     1     1     1     0
     0     0     0     0     0     0     0     0     1     0
     0     1     X     1     0     0     0     0     1     0
     0     1     0     X     0     0     0     0     1     0
     0     1     0     1     0     0     0     0     1     0
     0     1     1     1     1     1     0     1     1     0
     0     0     0     1     0     0     0     0     0     0
     0     0     0     0     0     0     0     0     0     0
%}