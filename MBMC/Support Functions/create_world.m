    function [world] = create_world( agent_x, agent_y, reward_x, reward_y )
%CREATE_WORLD creates a world for the agent to inhabit

%   Creates a 10x10x2 matrix
world = zeros(10,10,2);

% Adds the agent into the world (1st layer)

world(agent_y, agent_x, 1) = 1;

% Adds the reward into the world (2nd layer)

world(reward_y, reward_x, 2) = 2;

end