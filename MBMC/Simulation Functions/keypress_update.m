function [sensory_cells, reward_cells] = keypress_update(agent, action, calculate_sensory)

% cue = 0 means no cue, used for setup

global world
rolling_num = world.rolling_num;

%{
    sensory_cells = agent.sensory_cells;
    sensory_cells(1:rolling_num) = [];
    sensory_cells(end-1:end) = [];
    sensory_cells_newstate = zeros([1 rolling_num]);
    sensory_cells_success = zeros([1 2]);
%}

% reset cells
reward_cells = zeros(size(agent.sensory_cells));

% check for setup
if world.cue == 0
    return
end

% activate reward cells
reward_cells(rolling_num*8+2) = 1;

% check if this is a pre-action timestep or a post-action timestep
% if post-action, check if keypress is correct and update state accordingly

%% Update World
if iscell(action)
    action = action{:};
end
if ~isempty(action)
    assert(ismember(action, world.actions))
    int_action = str2double(action(end));
    if int_action == world.cue
        world.correct_action = true;
    else
        world.correct_action = false;
    end
    
    world.state(1,:) = [];
    world.state = [world.state; zeros([1 8])];
end

%% Calculate Sensory Cells
if isequal(calculate_sensory,'yes')
    sensory_cells = zeros(agent.num_sensory);
    if ~isempty(world.correct_action)
        switch world.correct_action
            case false
                sensory_cells(end-1) = 1;
            case true
                sensory_cells(end) = 1;
        end
        world.correct_action = [];
    else
        sensory_cells(1:rolling_num*8) = world.state(:)';
    end
end
end