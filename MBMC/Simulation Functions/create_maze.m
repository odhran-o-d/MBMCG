function [reward_x, reward_y, world] = create_maze(world, switches, walls)

% Creates the world as described above. Again, you should be able to ignore
% this function.

%   Creates an x by y by 3 matrix
world.state = zeros(world.worldSize_y, world.worldSize_x,3);

% Define bounding walls


if exist('walls', 'var') == 1
    
    assert(~any(walls > (world.worldSize_y * world.worldSize_x)))
    
    % add pre-existing walls
    world.state(walls + numel(world.state(:,:,1:2))) = 3;
    
    if switches.main.manual_walls == true
        user_walls = figure(); imagesc(world.state(:,:,3)); title('Walls: Click to Add, Click to Remove');
        while ishandle(user_walls) == 1;
            try
                [x, y] = ginput(1);
                x=round(x); y=round(y);
                if world.state(y,x,3) == 3;
                    world.state(y,x,3) = 0;
                else
                    world.state(y,x,3) = 3;
                end
                imagesc(world.state(:,:,3));
            end
        end
        
        walls = find(world.state(:,:,3) == 3);
    end
    
else
    
    % ask for wall input
    walls = [];
    
    top_wall = [];
    top_wall = [top_wall, 1:world.worldSize_y:world.worldSize_x*world.worldSize_y];
    
    walls = [walls top_wall];
    
    bottom_wall = [];
    bottom_wall = [bottom_wall, world.worldSize_y-1+1:world.worldSize_y:world.worldSize_y*world.worldSize_x];
    
    walls = [walls bottom_wall];
    
    left_wall = 1:world.worldSize_y;
    right_wall = world.worldSize_y*(world.worldSize_x-1)+1:world.worldSize_y*world.worldSize_x;
    
    walls = [walls left_wall];
    walls = [walls right_wall];
    
    % add walls into world
    walls = unique(walls);
    world.state(walls + numel(world.state(:,:,1:2))) = 3;
    
    % user interface to create maze
    if switches.main.manual_walls == true
        user_walls = figure(); imagesc(world.state(:,:,3)); title('Walls: Click to Add, Click to Remove');
        while ishandle(user_walls) == 1;
            try
                [x, y] = ginput(1);
                x=round(x); y=round(y);
                if world.state(y,x,3) == 3;
                    world.state(y,x,3) = 0;
                else
                    world.state(y,x,3) = 3;
                end
                imagesc(world.state(:,:,3));
            end
        end
    end
    
    walls = find(world.state(:,:,3) == 3);
    
end

switch switches.main.agentGoalPositions
    case 'random'
        % Generate positions that are in the world and not in the wall and are
        % not each other
        validAll = false;
        while validAll == false
            
            if switches.control_sw.useRandomTrialDist == true
                if switches.control_sw.randomTrialDist >= worldSize_x-2 || switches.control_sw.randomTrialDist >= worldSize_y-2
                    error('Trial Dist larger than world.')
                end
                [agent_x, agent_y] = makePositions(world.worldSize_x, world.worldSize_y);
                [reward_x, reward_y] = makePositions(world.worldSize_x, world.worldSize_y);
                while chebyshevDistance(world.worldSize_x, world.worldSize_y, [agent_x, agent_y], [reward_x, reward_y]) ~= switches.control_sw.randomTrialDist
                    [agent_x, agent_y] = makePositions(world.worldSize_x, world.worldSize_y);
                    [reward_x, reward_y] = makePositions(world.worldSize_x, world.worldSize_y);
                end
            else
                [agent_x, agent_y] = makePositions(world.worldSize_x, world.worldSize_y);
                [reward_x, reward_y] = makePositions(world.worldSize_x, world.worldSize_y);
            end
            if world.state(agent_y, agent_x, 3) ~= 3 && world.state(reward_y, reward_x, 3) ~= 3 && agent_y ~= reward_y && agent_x ~= reward_x
                validAll = true;
            end
        end
        
    case 'martinet'
        if ~(world.worldSize_x == 10 && world.worldSize_y == 10)
            error('Martinet Positions only calculated for world of size 10 x 10')
        end
        
        agent_x = 4; agent_y = 9;
        reward_x = 4; reward_y = 2;
        
    case 'manual'
        % place agent
        fig = figure(); imagesc(world.state(:,:,3)); title('Please select starting position.');
        [x, y] = ginput(1);
        x=round(x); y=round(y);
        agent_x = x; agent_y = y;
        close(fig)
        
        % place reward
        fig = figure(); imagesc(world.state(:,:,3)); title('Please select goal position.');
        [x, y] = ginput(1);
        x=round(x); y=round(y);
        reward_x = x; reward_y = y;
        close(fig)
        
    case 'set'
        agent_x = switches.params.startPosition_x;
        agent_y = switches.params.startPosition_y;
        reward_x = switches.params.goalPosition_x;
        reward_y = switches.params.goalPosition_y;
        
    otherwise
        error('Switch Error')
end

%{
if ~(switches.main.randomisedPositions + switches.main.martinetPositions + switches.main.manualPositions ...
        + switches.main.setPositions == 1)
    error('More or less than one means of generating agent/goal positions selected.')
end
%}

world.state(agent_y,agent_x,1) = 1;
world.state(reward_y,reward_x,2) = 1;
world.walls = walls;

end