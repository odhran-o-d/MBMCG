%{
load('161021_results_with_largeopen_chunks.mat')
ratioWithLargeOpen = ratio;
stdratioWithLargeOpen = std(ratioMat);

load('161021_results_with_open_chunks.mat')
ratioWithOpen = ratio;
stdratioWithOpen = std(ratioMat);

load('161021_results_with_gate_chunks.mat')
ratioWithGate = ratio;
stdratioWithGate = std(ratioMat);

load('161021_results_without_largeopen_chunks.mat')
ratioWithoutLargeOpen = ratio;
stdratioWithoutLargeOpen = std(ratioMat);

load('161021_results_without_open_chunks.mat')
ratioWithoutOpen = ratio;
stdratioWithoutOpen = std(ratioMat);

load('161021_results_without_gate_chunks.mat')
ratioWithoutGate = ratio;
stdratioWithoutGate = std(ratioMat);
%}

function RatioWhisker()

load('results_largeopenchunks.mat')
ratioWithLargeOpen = ratioMat(:);

load('results_largemazechunks.mat')
ratioWithLargeMaze = ratioMat(:);

load('results_smallopenchunks.mat')
ratioWithOpen = ratioMat(:);

load('results_smallmazechunks.mat')
ratioWithGate = ratioMat(:);

load('results_largeopen.mat')
ratioWithoutLargeOpen = ratioMat(:);

load('results_largemaze.mat')
ratioWithoutLargeMaze = ratioMat(:);

load('results_smallopen.mat')
ratioWithoutOpen = ratioMat(:);

load('results_smallmaze.mat')
ratioWithoutGate = ratioMat(:);


figure()
boxplot([ratioWithOpen, ratioWithoutOpen, ratioWithGate, ratioWithoutGate, ratioWithLargeOpen, ratioWithoutLargeOpen, ratioWithLargeMaze, ratioWithoutLargeMaze], 'positions', [10, 20, 35, 45, 60, 70 85 95])
ylim([0 inf]);
set(gca, 'XTickLabel', {'Open+' 'Open-' 'Maze+' 'Maze-' 'BigOpen+' 'BigOpen-' 'BigMaze+' 'BigMaze-'})
%set(gca, 'FontSize', 20, 'fontWeight', 'bold'); set(findall(gcf,'type','text'), 'FontSize', 20, 'FontWeight', 'bold')
set(gca, 'FontSize', 20); set(findall(gcf,'type','text'), 'FontSize', 20)
set(findobj(gca, 'type', 'line'),'linew', 1.3)
ylabel('Processing/Steps Ratio')