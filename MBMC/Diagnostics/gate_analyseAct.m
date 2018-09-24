function gate_analyseAct(gate_cells, agent)

if ~any(gate_cells)
    error('No firing cells.')
end

max_gate_idx = find(gate_cells == max(gate_cells(:)));
fprintf('Max. Gate Cell: %d', max_gate_idx);
disp(' ')

%% Gate cell firing
fprintf('Max. Gate Cell Firing = %d', gate_cells(max_gate_idx))
disp(' ')

%% Check SA cell influence
[gate_SA_firing, gate_SA_idx] = max(agent.SAtogate_synapses(:, max_gate_idx));
fprintf('Maximum SA synapse: %d %d %d', agent.SAtogate_synapses(gate_SA_idx, max_gate_idx));
disp(' ')
fprintf('Attached SA cell: %d %d %d', agent.SA_decoded(agent.SA_decoded(:,3) == gate_SA_idx, :));
disp(' ')
fprintf('Attached SA activity = %d', gate_SA_firing)
disp(' ')

%% Check sensory cell influence
gate_sensory_idx = find(agent.sensorytogate_synapses(:, max_gate_idx) == max(agent.sensorytogate_synapses(:, max_gate_idx)));
fprintf('Attached sensory cell: %d', gate_sensory_idx);
disp(' ')
fprintf('Attached sensory firing: %d', agent.sensory_cells(gate_sensory_idx))
disp(' ')

end