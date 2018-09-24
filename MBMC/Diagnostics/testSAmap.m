function [map_results] = testSAmap(agent, world, switches, create_figures)

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
actions = world.actions;
num_actions = numel(actions);
transitionMat = zeros(numel(world.state(:,:,1)), numel(agent.motor_cells), numel(world.state(:,:,1)));
filtered_synapses = agent.SAtoSA_synapses > 0.01;
decoded_transitions = zeros(numel(world.state(:,:,1)), numel(agent.motor_cells), numel(world.state(:,:,1)));
tmp_SAdecoded= cell(numel(world.state(:,:,1)), num_actions);

for i = 1:numel(world.state(:,:,1))
    
    if ~ismember(i, free_states)
        continue
    end
    
    world.state(:,:,1) = 0; world.state(i) = 1;
    [agent.sensory_cells, ~, ~, world] = world_update_function(agent, world, '', 'yes', switches);
    
    %tmp_fr(end+1, 1:num_actions) = cell(1);
    
    for j = 1:num_actions
        
        agent.motor_cells(:) = 0; agent.motor_cells(j) = 1;
        agent.SA_cells = cellPropagate(agent.SA_cells, agent.sensory_cells, agent.motor_cells, [], agent.sensorytoSA_synapses, agent.motortoSA_synapses, []);
        agent.SA_cells = agent.SA_cells/max(agent.SA_cells(:));
        firing_SA = find(agent.SA_cells > 0.99);
        tmp_SAdecoded{i, j} = firing_SA';
        %tmp_fr{end, j} = agent.SA_cells(:);
        
        action = actions{j};
        [new_sensory, ~, intended_state, ~] = maze_update(agent, world, action, false, switches);
        switch switches.main.xy_sensory
            case true
                new_state = xy_sensory2ind(new_sensory, world);
            case false
        new_state = find(new_sensory);
            otherwise, error('Switch Error')
        end
        transitionMat(i, j, new_state) = 1;
        
    end
    
end



%{
for i = 1:size(tmp_fr, 1)
for j = 1:size(tmp_fr, 2)
mat_fr(i, j, :) = cell2mat(tmp_fr(i, j));
end
end

IRs = analysis_singleCell(numel(agent.SA_cells(:)), (num_states * num_actions), 1, mat_fr, 1, create_figures, false);
maxinfo = log2(num_states*num_actions);
%}

state_counter = 0;
for i = 1:numel(world.state(:,:,1))
    
    if ~ismember(i, free_states)
        continue
    end
    
    state_counter = state_counter+1;
    state = free_states(state_counter);
    
    for j = 1:num_actions
        
        % BACKWARDS model (I think)
        tmp_transitions = agent.SAtoSA_synapses(:, tmp_SAdecoded{i, j}) > 0.01;
        
        for k = find(tmp_transitions)'
            isTransition = cellfun(@(x)isequal(x,k),tmp_SAdecoded);
            [row,col] = find(isTransition);
            %[x, y] = find(cell2mat(tmp_SAdecoded) == k);
            decoded_transitions(i,j,row) = 1;
        end
        
    end
    
end

true_positive = numel(find((decoded_transitions == 1) & transitionMat == 1));
true_negative = numel(find((decoded_transitions ~= 1) & transitionMat~= 1));
false_positive = numel(find((decoded_transitions == 1) & transitionMat ~= 1));
false_negative = numel(find((decoded_transitions ~= 1) & transitionMat == 1));

precision = true_positive / (true_positive + false_positive);
recall = true_positive / (true_positive + false_negative);

map_results = struct();
map_results.tp = true_positive;
map_results.fp = false_positive;
map_results.tn = true_negative;
map_results.fn = false_negative;

map_results.precision = precision;
map_results.recall = recall;

end