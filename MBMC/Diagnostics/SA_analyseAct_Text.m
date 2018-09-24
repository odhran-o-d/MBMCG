function SA_analyseAct_Text(agent)

idx = find(agent.SA_cells);

if numel(idx) > 10
    fprintf('Too many SA cells (>10)')
    return
end

for i = 1:numel(idx)
fprintf('SA Cell = %d', idx(i))
disp(' ')
fprintf('Activation of %d = %d', idx(i), agent.SA_cells(idx(i)));
disp(' ')
end

end