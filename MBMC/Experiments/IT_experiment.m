full_results = [];
for i = 1:100
[results, agent, world, switches] = MBMC_master('SAcellsBandpass', {}, [], []);
full_results(i,:) = results.IRs;
end

figure(); 
hold on; 
for i = 1:100; 
    plot(full_results(i,:), 'Color', [0.8 0.8 0.8],'LineWidth',0.1); 
end;
plot(mean(full_results), 'k', 'LineWidth', 4);
maxinfo = line([0 900], [log2(576) log2(576)]);
maxcells = line([576 576], [-0.1 log2(576)]);
maxinfo.LineStyle = '--'; maxcells.LineStyle = '--';