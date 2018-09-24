function [sensory_cells, reward_cells, intended_state, world] = maze_update(agent, world, action, calculate_sensory, switches)

% The update function. Takes an action string and updates the world, returning sensory feedback as a layer of sensory cells.

% You should be able to ignore the details of this function, as well as the
% 'calculate_sensory' parameter.

% NB Unused parameters are because this function is called as a generic
% update function and other update functions require those parameters.

%% Unpackage World Parameters

if ~isequal(switches.main.worldType,'maze')
    error('Maze Update function called for non-maze world.');
end

% find parameters of world
[size_y, size_x] = size(world.state(:,:,1));

% find the position of the agent within the world
[agent_y, agent_x] = find(world.state(:,:,1) == 1);
[ay_copy, ax_copy] = find(world.state(:,:,1) == 1);

% find position of the reward within the world
[reward_y, reward_x] = find(world.state(:,:,2) == 1);
[ry_copy, rx_copy] = find(world.state(:,:,2) == 1);

%% Action parameters
% NONE

%% Calculate effect of action.

switch action
    case 'W'
        agent_x = agent_x-1;
    case 'SW'
        agent_x = agent_x-1;
        agent_y = agent_y+1;
    case 'S'
        agent_y = agent_y+1;
    case 'SE'
        agent_x = agent_x+1;
        agent_y = agent_y+1;
    case 'E'
        agent_x = agent_x+1;
    case 'NE'
        agent_x = agent_x+1;
        agent_y = agent_y-1;
    case 'N'
        agent_y = agent_y-1;
    case 'NW'
        agent_x = agent_x-1;
        agent_y = agent_y-1;
end

agent_outside_bounds = agent_x == 0 || agent_x > size(world.state,2) || agent_y == 0 || agent_y > size(world.state,1);

intended_state = zeros(size(world.state(:,:,1)));
if ~agent_outside_bounds
    intended_state(agent_y, agent_x, 1) = 1;
    assignin('caller', 'intended_state', intended_state);
end

if agent_outside_bounds
    valid = 0;
    agent_x = ax_copy; agent_y = ay_copy;
end
if world.state(agent_y, agent_x, 3) == 3
    valid = 0;
    agent_x = ax_copy; agent_y = ay_copy;
end

world.state(:,:,1) = 0;
world.state(agent_y,agent_x,1) = 1;


%% Reward
world.state(reward_y,reward_x,2) = 1;

%% Produce distributed sensory representation

switch switches.main.xy_sensory == true
    case true
        sensory_x = zeros([1 world.worldSize_x]); sensory_x(agent_x) = 1;
        sensory_y = zeros([1 world.worldSize_y]); sensory_y(agent_y) = 1;
        sensory_cells = [sensory_x sensory_y];
        reward_cells_x = zeros([1 world.worldSize_x]); reward_cells_x(reward_x) = 1;
        reward_cells_y = zeros([1 world.worldSize_y]); reward_cells_y(reward_y) = 1;
        reward_cells = [reward_cells_x reward_cells_y];
    case false
        sensory_cells = world.state(:,:,1);
        reward_cells = world.state(:,:,2);
    otherwise, error('Switch Error')
end
end