function [results, agent, world_copy] = ChunkMaze_World(switches, agent, world)
% Runs one full navigational experiment:

global martinetExperiment

%% Define Sensory Information and Starting Point                                                                                                         % Sets the world as a global variable, available to the learner, controller and update functions without being explictly called as an argument.
switch switches.main.worldType
    case 'maze'
        
        if  isfield(world, 'walls')
            [~, ~, world] = create_maze(world, switches, world.walls);
        else
            [~, ~, world] = create_maze(world, switches);
        end
        
    case 'arm'
        world.worldSize_x = 10;
        world.worldSize_y = 10;
        world.walls = [];
        world.arm.j1_angle = 0;
        world.arm.j2_angle = 0;
        world.reward_x = 0;
        world.reward_y = 0;
        
    case 'keypress'
        world.cue = 0;
        world.correct_action = [];
        world.trialTypes = {'Random', 'Sequence'};
        world.rolling_num = 5;
        world.state = zeros([world.rolling_num 8]);
        
    case 'coffee'
        world.sugar = [0 1]; % [open, closed]
        world.coffee = [0 1]; % [open, closed]
        world.mug = [1 0 0 0 0 0 0]; % [water, coffee, milky coffee, sugary coffee, milky&sugar coffee, milk, sugar]
        world.milk = [0 1]; % [open, closed]
        world.hand = [1 0 0 0 0 0]; % [empty, sugar, coffee, mug, milk];
        
end

if switches.diagnostic.clear_firing == true && ~(~isempty(martinetExperiment) && ~isequal(martinetExperiment, 'None'))
    clearvars -global firing
end

global firing
if switches.diagnostic.track_firing && isempty(firing)
    firing = struct();
    firing.SA = [];
    firing.sensory = [];
    firing.gate = [];
    firing.motor = [];
    firing.chunk = [];
    firing.all = [];
end

if switches.diagnostic.occupancy_grid == true
    occupancy_A = {};
    occupancy_B = {};
    occupancy_Open = {};
    occupancy_Array = {};
    sensory_tracked2 = {};
end

%% Define Actions
switch switches.main.worldType
    case 'maze'
        if switches.main.diagonalActions == true
            world.actions = {'NW' 'W' 'SW' 'N' '' 'S' 'NE' 'E' 'SE'};                                                                         % The actions available to the agent, represented as a set of strings.
        else
            world.actions = {'N', 'E', '', 'S', 'W'};
        end
    case 'arm'
        world.actions = {'j1_inc', 'j1_dec', 'j2_inc', 'j2_dec', '', 'j1_inc_j2_dec', 'j1_inc_j2_inc', 'j1_dec_j2_inc', 'j1_dec_j2_dec'};
    case 'keypress'
        world.actions = {'key_1', 'key_2', 'key_3', 'key_4', 'key_5', 'key_6', 'key_7', 'key_8', ''};
end

%% Define World Functions
switch switches.main.worldType
    case 'maze'
        world_update_function = @maze_update;                                                                                       % Sets the maze_update function (see below) as a function handle that can be given to the learner and controller functions as arguments.
    case 'arm'
        world_update_function = @arm_update;
    case 'keypress'
        world_update_function = @keypress_update;
end

%% Define Results Function
results = struct();

%% Setup Agent and Call Learner function
switch switches.main.runLearner == true
    case true
        
        if switches.main.provide_agent == false
            assert(isequal(agent, []))
            switch switches.main.worldType
                case 'maze'
                    agent = createAgent(world, switches, @maze_update);
                    if agent.num_SAcol < numel(find(world.state(:,:,3) ~= 3))
                        error('Too Few SA Columns for World')
                    end
                case 'arm'
                    agent = createAgent(world, switches, @arm_update);
                case 'keypress'
                    agent = createAgent(world, switches, @keypress_update);
                otherwise
                    error('No suitable worldType given, unable to create agent.')
            end
        end
        
        if numel(agent.SAtoSA_synapses) >= 120000000 %16000000
            error('Synapse matrices too large. Please reduce world size.')
        end
        
        if switches.experiment.Verstynen
            sensory_tracked = {};
            gate_tracked = {};
            SA_tracked = {};
            for i = 1:2000
                world.cue = randi([1 8]);
                world.state(world.rolling_num, world.cue) = 1;
                [agent, SA_tracked_tmp, gate_tracked_tmp, sensory_tracked_tmp] = ChunkLearner(agent, world.actions, world_update_function, switches, {});
                agent.SA_trace(:) = 0;
                sensory_tracked = horzcat(sensory_tracked, sensory_tracked_tmp);
                gate_tracked = horzcat(gate_tracked, gate_tracked_tmp);
                SA_tracked = horzcat(SA_tracked, SA_tracked_tmp);
            end
        else
            [agent, SA_tracked, gate_tracked, sensory_tracked] = ChunkLearner(agent, world, world_update_function, switches, {});
        end
        
        %% Analyse and Save Data
        switch world.worldType
            case 'maze'
                sensory_tracked_matrix = [];
                for time = 1:size(sensory_tracked,2)
                    sensory_tracked_matrix(:,:,:,time) = sensory_tracked{time};
                end
        end
        
        % Decode SA information
        
        if isfield(agent, 'gate_decoded') && ~isempty(agent.gate_decoded)
            gate_decoded_save = agent.gate_decoded;
        end
        
        switch world.worldType
            case 'keypress'
                for time = 1:size(sensory_tracked,2)
                    for i = 1:size(SA_tracked{time}{1},2)
                        if SA_tracked{time}{1}(i) ~= 41 && SA_tracked{time}{1}(i) ~= 42
                            [~, SA_tracked{time}{1}(i)] = ind2sub([world.rolling_num; 8], SA_tracked{time}{1}(i));
                        end
                    end
                    while size(SA_tracked{time}{1},2) < world.rolling_num
                        SA_tracked{time}{1} = horzcat(0, SA_tracked{time}{1});
                    end
                end
                for time = 1:size(sensory_tracked,2)
                    for i = 1:size(gate_tracked{time}{1},2)
                        if gate_tracked{time}{1}(i) ~= 41 && gate_tracked{time}{1}(i) ~= 42
                            [~, gate_tracked{time}{1}(i)] = ind2sub([world.rolling_num 8], gate_tracked{time}{1}(i));
                        end
                    end
                    while size(gate_tracked{time}{1},2) < world.rolling_num
                        gate_tracked{time}{1} = horzcat(0, gate_tracked{time}{1});
                    end
                end
        end
        
        if switches.diagnostic.decodeSA
            if isfield(agent, 'SA_decoded') && ~isempty(agent.SA_decoded)
                agent.SA_decoded = decode_representations(SA_tracked, agent.SA_decoded, switches);
            else
                agent.SA_decoded = decode_representations(SA_tracked, [], switches);
            end
        end
        
        if switches.diagnostic.decodegate
            if isfield(agent, 'gate_decoded') && ~isempty(agent.gate_decoded)
                agent.gate_decoded = decode_representations(gate_tracked, agent.gate_decoded, switches);
            else
                agent.gate_decoded = decode_representations(gate_tracked, [], switches);
            end
        end
        
        
    case false
        if ~exist('agent', 'var') == 1
            error('Agent must be provided if learning skipped.')
        end
    otherwise
        error('Switch Error')
end

%% Goal Loop for Chunk Learning
switch switches.diagnostic.total_steps
    case true
        results.total_steps = 0;
    case false
    otherwise, error('Switch Error')
end
switch switches.diagnostic.total_processing
    case true
        results.total_processing = 0;
    case false
    otherwise, error('Switch Error')
end
switch switches.diagnostic.stepsByResult
    case true
        stepsByResult = {};
    case false
    otherwise, error('Switch Error')
end

switch switches.main.runController == true
    case true
        
        switch switches.main.worldType
            case 'keypress'
                rand_num = randi([1 2]);
                world.trialType = world.trialTypes{rand_num};
                switch world.trialType
                    case 'Random'
                        world.cueString = randi([1 8], [1 32*5]);
                    case 'Sequence'
                        world.cueString = repmat(randi([1 8], [1 32]), [1 5]);
                end
                goalIterations = numel(world.cueString);
        end
        
        switch switches.diagnostic.resultMat
            case true
                resultMat = zeros([1 switches.control_sw.goalIterations]);
            case false
            otherwise, error('Switch Error')
        end
        
        for gI = 1:switches.control_sw.goalIterations
            
            fprintf('%d/%d \n', gI, switches.control_sw.goalIterations)
            
            %% Create Random Agent/Goal Positions
            switch switches.main.worldType
                case 'maze'
                    [reward_x, reward_y, world] = create_maze(world, switches, world.walls);
                    
                case 'arm'
                    reward_cells = zeros([1 400]); reward_cells([1 2]) =1;
                    while ~ismember(find(reward_cells>0.1), agent.SA_decoded(:,[1 2]), 'rows')
                        world.reward_j1 = randi([0 35])*10; world.reward_j2 = randi([0 35])*10;
                        [~, ~, world.arm.reward_x, world.arm.reward_y] = forward_arm(world.reward_j1, world.reward_j2);
                        [~, reward_cells] = world_update_function('', 'yes');
                    end
                    
                case 'keypress'
                    world.cue = world.cueString(gI);
                    world.state(world.rolling_num, world.cue) = 1;
            end
            
            
            %% Call Goal Function
            switch switches.main.reset_agent
                case true
                    [sensory_tracked, SA_gradient_mat, result, ~] = ChunkController(agent, world, switches, world_update_function);
                case false
                    [sensory_tracked, SA_gradient_mat, result, agent] = ChunkController(agent, world, switches, world_update_function);
                otherwise
                    error('Switch Error')
            end
            
            %% Analyse and Save Data
            if result == 'N'
                learner_steps = NaN;
            elseif switches.diagnostic.track_sensory == false
                learner_steps = NaN;
            else
                learner_steps = size(sensory_tracked,2);
            end
            
            if result == 'N'
                tmp_steps = size(sensory_tracked,2); % To give penalty for failure
            else
                tmp_steps = size(sensory_tracked,2);
            end
            
            if switches.diagnostic.total_steps == true
                results.total_steps = results.total_steps + learner_steps;
            end
            
            if result == 'N'
                processingSteps = 0;
            elseif switches.diagnostic.track_SA == false
                processingSteps = NaN;
            else
                processingSteps = size(SA_gradient_mat, 2);
            end
            
            if switches.diagnostic.total_processing == true
                results.total_processing = results.total_processing + processingSteps;
            end
            
            % Track processing time for different numbers of steps
            %processingByStep(gI, :) = [first_processing tmp_steps];
            
            % Track results
            %stepsByResult{gI} = {tmp_steps, result};
            switch switches.diagnostic.resultMat
                case true
                    results.resultMat(gI) = result;
                case false
                otherwise, error('Switch Error')
            end
            
            switch switches.diagnostic.stepsMat
                case true
                    results.stepsMat(gI) = tmp_steps;
                case false
                otherwise, error('Switch Error')
            end
            
            switch switches.diagnostic.processingMat
                case true
                    results.processingMat(gI) = processingSteps;
                case false
                otherwise, error('Switch Error')
            end
            
            switch world.worldType
                case 'maze'
                    sensory_tracked_matrix = [];
                    for time = 1:length(sensory_tracked)
                        sensory_tracked_matrix(:,:,:,time) = sensory_tracked{time};
                    end
            end
            
            if switches.diagnostic.track_sensory == true
                switch world.worldType
                    case 'maze'
                        results.sensory_tracked{gI} = sensory_tracked;
                        world_tracked = {};
                        for time = 1:length(sensory_tracked)
                            world_tracked{time} = sensory_tracked_matrix(:,:,1,time) + sensory_tracked_matrix(:,:,3,time);
                        end
                end
            end
            
            switch switches.diagnostic.track_SA
                case true
                    results.SA_tracked{gI} = SA_gradient_mat;
                case false
                otherwise, error('Switch Error')
            end
            
            
            if switches.diagnostic.occupancy_grid == true
                assert(isequal(world.worldType, 'maze'))
                occupancy_data = squeeze(sensory_tracked_matrix(:,:,1,:));
                occupancy_grid_tmp = zeros(size(occupancy_data(:,:,1)));
                for occupancy_i = 1:size(occupancy_data, 3)
                    occupancy_mini = occupancy_data(:,:,occupancy_i);
                    for occupancy_j = 1:numel(occupancy_mini)
                        if occupancy_mini(occupancy_j) == 1
                            occupancy_grid_tmp(occupancy_j) = 1;
                        end
                    end
                end
                if strcmp(martinetExperiment, 'A') || strcmp(martinetExperiment, 'AGate')
                    occupancy_A{end + 1} = occupancy_grid_tmp;
                elseif strcmp(martinetExperiment, 'B') || strcmp(martinetExperiment, 'BGate')
                    occupancy_B{end + 1} = occupancy_grid_tmp;
                elseif strcmp(martinetExperiment, 'Open') || strcmp(martinetExperiment, 'OpenGate')
                    occupancy_Open{end + 1} = occupancy_grid_tmp;
                else
                    occupancy_Array{end + 1} = occupancy_grid_tmp;
                end
                sensory_tracked2{end + 1} = sensory_tracked;
            end
            
            %% Reset Agent
            switch world.worldType
                case 'keypress'
                    tmp_sensory = agent.sensory_cells;
                    agent = resetAgent(agent);
                    agent.sensory_cells = tmp_sensory;
                otherwise
                    agent = resetAgent(agent);
            end
            
            %slider_display(world_tracked, [(reward_x - 0.5), (reward_y - 0.5), 1, 1]);
            %}
            
            %% Reset Experiment if Necessary
            switch martinetExperiment
                case 'A'
                    martinetExperiment = 'AGate';
                    load('MartinetWallsBlockAGate.mat');
                case 'B'
                    martinetExperiment = 'BGate';
                    load('MartinetWallsBlockBGate.mat');
            end
            
        end
        
        if switches.diagnostic.total_steps == true
            disp(results.total_steps);
        end
        
    case false
    otherwise
        error('Switch Error')
        
end

if switches.main.runController == true
    %assignin('base', 'resultsMat', resultMat)
    assignin('base', 'controller_steps', switches.control_sw.controller_steps)
end

if switches.diagnostic.occupancy_grid == true
    if ~isempty(martinetExperiment) && ~isequal(martinetExperiment, 'None')
        assignin('caller', 'occupancy_A_tmp', occupancy_A)
        assignin('caller', 'occupancy_B_tmp', occupancy_B)
        assignin('caller', 'occupancy_Open_tmp', occupancy_Open)
        assignin('caller', 'sensory_tracked_tmp', sensory_tracked2)
    else
        results.occupancy = occupancy_Array;
    end
end

switch world.worldType
    case 'maze'
        walls = world.walls;
    otherwise
        walls = [];
end

world_copy = world;

end