load('161021_results_with_largeopen_chunks.mat')
ratioWithLargeOpen = ratio;
load('161021_results_with_open_chunks.mat')
ratioWithOpen = ratio;
load('161021_results_with_gate_chunks.mat')
ratioWithGate = ratio;
load('161102_results_with_largegate_chunks_werror.mat')
ratioWithLargeGate = ratio;
load('161102_results_without_largeopen_chunks.mat')
ratioWithoutLargeOpen = ratio;
load('161021_results_without_open_chunks.mat')
ratioWithoutOpen = ratio;
load('161021_results_without_gate_chunks.mat')
ratioWithoutGate = ratio;
load('161102_results_without_largegate_chunks.mat')
ratioWithoutLargeGate = ratio;

bar([ratioWithGate, ratioWithoutGate; ratioWithLargeGate, ratioWithoutLargeGate; ratioWithOpen, ratioWithoutOpen; ratioWithLargeOpen, ratioWithoutLargeOpen])
set(gca, 'XTickLabel', {'Gate World'; 'Large Gate World'; 'Open World'; 'Large Open World'})
ylabel('Processing/Steps Ratio')
legend('With Learned Options', 'Without Learned Options')