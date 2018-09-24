function SA_analyseSyn_Text(SA_idx, agent)

%% Gate cell
fprintf('SA Cell = %d', SA_idx)
disp(' ')
fprintf('Current Activation = %d', agent.SA_cells(SA_idx));
disp(' ')

%% Check Sensory cell influence
[sens_syn, sens_idx] = max(agent.sensorytoSA_synapses(:, SA_idx));
fprintf('Attached sensory cell: %d', sens_idx);
disp(' ')
fprintf('Attached sensory weight = %d', sens_syn)
disp(' ')

%% Check action cell influence
[act_weight, act_idx] = max(agent.motortoSA_synapses(:, SA_idx));
fprintf('Attached motor cell: %d', act_idx);
disp(' ')
fprintf('Attached motor weight: %d', act_weight)
disp(' ')

end