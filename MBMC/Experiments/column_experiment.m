function column_experiment()

%% Setup
num_col = [5 1 10];
num_e = [1 num_col(3)];
num_ib = [1 1];

e = zeros([num_e]);
ib = zeros(num_ib);

synapses_ce = [];
for i = 1:num_col(3)
    new_col = zeros([prod(num_col) 1]);
    new_col((i-1)*num_col(1)+1:i*num_col(1)) = 1;
    synapses_ce = [synapses_ce new_col];
end
synapses_eib = ones(numel(e), numel(ib));
synapses_ibe = synapses_eib';
synapses_ec = synapses_ce';

%% Experiment
columns = rand(num_col);

pretty_cols = prettyCol(columns, num_col);
disp(pretty_cols); figure(); imagesc(pretty_cols, [0 1]); colormap('gray'); colorbar;
tmp = sum(pretty_cols);
disp(tmp); figure(); plot(tmp);

e = cellPropagate(e, columns, [], [], synapses_ce, [], []);
e = normalise(e, 1, false);
e = WTA_Competition(e);

disp(e); figure(); plot(e); ylim([0 1]);

columns = cellPropagate(columns, e, [], [], synapses_ec, [], []);

tmp = prettyCol(columns, num_col); disp(tmp); 
figure(); imagesc(tmp, [0 1]); colormap('gray'); colorbar
end

function new_col = prettyCol(columns, num_col)

new_col = reshape(columns, [num_col(1), num_col(3)]);

end