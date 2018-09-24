function [tmp_SAdecoded, IRs, maxinfo] = testSAresponses(agent, world, switches, create_figures)

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
num_actions = numel(world.actions);
tmp_SAdecoded={};
tmp_fr = {};

for i = free_states'
    
    %agent.sensory_cells(:) = 0; agent.sensory_cells(i) = 1;
    world.state(:,:,1) = 0; world.state(i) = 1;
    [agent.sensory_cells, ~, ~, world] = world_update_function(agent, world, '', 'yes', switches);
    tmp_SAdecoded(end+1, 1:num_actions) = cell(1);
    tmp_fr(end+1, 1:num_actions) = cell(1);
    
    for j = 1:num_actions
        
        agent.motor_cells(:) = 0; agent.motor_cells(j) = 1;
        agent.SA_cells = cellPropagate(agent.SA_cells, agent.sensory_cells, agent.motor_cells, [], agent.sensorytoSA_synapses, agent.motortoSA_synapses, []);
        agent.SA_cells = agent.SA_cells/max(agent.SA_cells(:));
        firing_SA = find(agent.SA_cells > 0.99);
        tmp_SAdecoded{end, j} = firing_SA';
        tmp_fr{end, j} = agent.SA_cells(:);
        
    end
    
end

for i = 1:size(tmp_fr, 1)
for j = 1:size(tmp_fr, 2)
mat_fr(i, j, :) = cell2mat(tmp_fr(i, j));
end
end

IRs = analysis_singleCell(numel(agent.SA_cells(:)), (num_states * num_actions), 1, mat_fr, 1, create_figures, false);
maxinfo = log2(num_states*num_actions);

end