function [ world ] = update_world3( world, motor, toroidal )
%UPDATE_WORLD Updates world and can be set to reject toroidal movements.
% find parameters of world
[size_y, size_x] = size(world(:,:,1));

% find the position of the agent within the world
[agent_y, agent_x] = find(world(:,:,1) == 1);

% find position of the reward within the world
[reward_y, reward_x] = find(world(:,:,2) == 2);

% check the performed action and calculate the agent's new position
if strcmp(motor, 'W')
    agent_x = agent_x-1;
elseif strcmp(motor, 'SW') == 1
    agent_x = agent_x-1;
    agent_y = agent_y+1;
elseif strcmp(motor, 'S') == 1
    agent_y = agent_y+1;
elseif strcmp(motor, 'SE') == 1
    agent_x = agent_x+1;
    agent_y = agent_y+1;
elseif strcmp(motor, 'E') == 1
    agent_x = agent_x+1;
elseif strcmp(motor, 'NE') == 1
    agent_x = agent_x+1;
    agent_y = agent_y-1;
elseif strcmp(motor, 'N') == 1
    agent_y = agent_y-1;
elseif strcmp(motor, 'NW') == 1
    agent_x = agent_x-1;
    agent_y = agent_y-1;
else
    disp('invalid motor command')
end

if toroidal == 1
    
    if agent_x == 0
        agent_x = agent_x + size(world,2);
    elseif agent_x > size(world,2)
        agent_x = 1;
    end
    
    if agent_y == 0
        agent_y = agent_y + size(world,1);
    elseif agent_y > size(world,1)
        agent_y = 1;
    end
    
else
    
    if agent_x == 0 || agent_x > size(world,2) || agent_y == 0 || agent_y > size(world,1)
        %disp('Motor Command was outside world.')
        [agent_y, agent_x] = find(world(:,:,1) == 1);
    end
    
end

% redraw world
world = create_world2(size_x, size_y, agent_x, agent_y, reward_x, reward_y);

end

