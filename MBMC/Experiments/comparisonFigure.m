function comparisonFigure(output)
figure(); 

subplot(2,2,1);
scatterfig(output.so_chunk, output.so_nochunk); title('Small Open')
subplot(2,2,2); 
scatterfig(output.sm_chunk, output.sm_nochunk); title('Small Maze')
subplot(2,2,3); 
scatterfig(output.lo_chunk, output.lo_nochunk); title('Large Open')
subplot(2,2,4); 
scatterfig(output.lm_chunk, output.lm_nochunk); title('Large Maze')
end

function scatterfig(chunk, nochunk)
hold on
scatter(chunk(:,1), chunk(:,2), chunk(:,3)*10, 'filled');
ax_tmp = scatter(nochunk(:,1), nochunk(:,2), nochunk(:,3)*10, 'd', 'filled');
xlabel('Route Length (steps)'); ylabel('Total Planning Time (timesteps)');
set(gca, 'FontSize', 30);
hold off
end