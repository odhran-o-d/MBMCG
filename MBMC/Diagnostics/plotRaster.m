function [] = plotRaster(spikeMat, tVec, spikeBin, tBin, onset)
figure(); sp1 = subplot(2, 1, 1);
hold all;
for trialCount = 1:size(spikeMat,1)
    spikePos = tVec(spikeMat(trialCount, :));
    for spikeCount = 1:length(spikePos)
        plot([spikePos(spikeCount) spikePos(spikeCount)], ...
            [trialCount-0.4 trialCount+0.4], 'k');
    end
end

ylim([0 size(spikeMat, 1)+1]);

hold all;
plot([onset onset], [0 size(spikeMat, 1)+1]);

% label the axes
%xlabel('Time (s)');
ylabel('Trial number');

sp2 = subplot(2, 1, 2);

bgraph = bar(tBin, spikeBin, 1);

tmp = get(sp1, 'XLim');
set(sp2, 'XLim', tmp);

set(bgraph, 'FaceColor', 'black')
xlabel('Time (s)');
ylabel('Summed Spikes');

hold all;
max_y = get(sp2, 'YLim');
plot([onset onset], [0 max_y(2)]);

%H = labelEdgeSubPlots('Time (s)','string',0)