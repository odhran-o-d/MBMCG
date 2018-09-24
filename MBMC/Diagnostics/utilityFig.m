function utilityFig(vals, utility)
figure()
num_vals = numel(vals);
x = linspace(0,1,num_vals);
first_col = [0 0 1];
last_col = [1 0 0];
col_array = first_col' + x.*(last_col' - first_col');
col_array = col_array';
hold on
for j = 1:num_vals
    scatter(utility{j}(:,1), utility{j}(:,2), utility{j}(:,3)*10, col_array(j,:), 'd', 'filled');
end
hold off
xlabel('Route Length (steps)'); ylabel('Total Planning Time (timesteps)');
set(gca, 'FontSize', 30);
legend(vals)
end