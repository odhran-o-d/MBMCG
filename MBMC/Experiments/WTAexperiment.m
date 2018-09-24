function WTAexperiment()

%% Setup
num_e = [1 2];
num_i = [1 1];

e = zeros(num_e);
i = zeros(num_i);

synapses_ei = ones(numel(e), numel(i));
synapses_ie = ones(numel(i), numel(e)) * -1;

%% Experiment
e = rand(num_e);
disp(e)

i = cellPropagate(i, e, [], [], synapses_ei, [], []);
disp(i)

e = cellPropagate(e, i, [], [], synapses_ie, [], []);
disp(e)

end
