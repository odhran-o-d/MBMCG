function gate_analyseSyn(gate_idx, agent)

%% Gate cell
fprintf('Gate Cell = %d', gate_idx)
disp(' ')

%% Check SA cell influence
[gate_SA_syn, gate_SA_idx] = max(agent.SAtogate_synapses(:, gate_idx));
fprintf('Maximum SA synapse: %d %d %d', agent.SAtogate_synapses(gate_SA_idx, gate_idx));
disp(' ')
fprintf('Attached SA cell: %d %d %d', agent.SA_decoded(agent.SA_decoded(:,3) == gate_SA_idx, :));
disp(' ')
fprintf('Attached SA weight = %d', gate_SA_syn)
disp(' ')

%% Check sensory cell influence
[gate_sensory_weight, gate_sensory_idx] = max(agent.sensorytogate_synapses(:, gate_idx));
fprintf('Attached sensory cell: %d', gate_sensory_idx);
disp(' ')
fprintf('Attached sensory weight: %d', gate_sensory_weight)
disp(' ')

end