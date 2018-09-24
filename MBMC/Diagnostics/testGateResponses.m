function [tmp_GateDecoded, IRs, maxinfo] = testGateResponses(agent, world, switches, create_figures)

assert(isequal(switches.main.worldType, 'maze'))

switch switches.main.worldType
    case 'maze'
        world_update_function = @maze_update;                                                                                       % Sets the maze_update function (see below) as a function handle that can be given to the learner and controller functions as arguments.
    case 'arm'
        world_update_function = @arm_update;
    case 'keypress'
        world_update_function = @keypress_update;
end

free_states = find(world.state(:,:,3) == 0);
num_states = numel(free_states);
num_SA = prod(agent.num_SA);
tmp_GateDecoded={};
tmp_fr = {};

for i = free_states'
    
    %agent.sensory_cells(:) = 0; agent.sensory_cells(i) = 1;
    world.state(:,:,1) = 0; world.state(i) = 1;
    [agent.sensory_cells, ~, ~, world] = world_update_function(agent, world, '', 'yes', switches);
    tmp_GateDecoded(end+1, 1:num_SA) = cell(1);
    tmp_fr(end+1, 1:num_SA) = cell(1);
    
    for j = 1:num_SA
        
        agent.SA_cells(:) = 0; agent.SA_cells(j) = 1;
        agent.gate_cells = cellPropagate(agent.gate_cells, agent.sensory_cells, agent.SA_cells, [], agent.sensorytogate_synapses, agent.SAtogate_synapses, []);
        agent.gate_cells(agent.gate_cells <= 0.5) = 0;
        %agent.gate_cells = agent.gate_cells/max(agent.gate_cells(:));
        firing_gate = find(agent.gate_cells > 0.90);
        tmp_GateDecoded{end, j} = firing_gate';
        tmp_fr{end, j} = agent.gate_cells(:);
        
    end
    
end

for i = 1:size(tmp_fr, 1)
for j = 1:size(tmp_fr, 2)
mat_fr(i, j, :) = cell2mat(tmp_fr(i, j));
end
end

IRs = analysis_singleCell(numel(agent.SA_cells(:)), (num_states * num_SA), 1, mat_fr, 1, create_figures, false);
maxinfo = log2(num_states*num_SA);

end