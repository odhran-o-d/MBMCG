function [world] = create_world2( size_x, size_y, agent_x, agent_y, reward_x, reward_y )
%CREATE_WORLD creates a world for the agent to inhabit

%   Creates an x by y by 2 matrix
world = zeros(size_y,size_x,2);

% Adds the agent into the world (1st layer)

world(agent_y, agent_x, 1) = 1;

% Adds the reward into the world (2nd layer)

world(reward_y, reward_x, 2) = 2;

end