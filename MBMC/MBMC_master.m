function [results, agent, world, switches] = MBMC_master(experiment, dakota, agent, world)

% V1.0

%% Set Path
if isequal(dakota, {})
    ChunkPath();
end

%% Set Experiment
if ~exist('experiment', 'var')
    error('No experiment given.')
end

%% Default Parameters

global martinetExperiment

switches = struct();
switches = setDefaultSwitches(switches);

%% Dakota Integration

if ~isequal(dakota, {})
    switches.main.suppressChecks = true;
    switches.main.suppressFigures = true;
end

%% Experiment Setup

if ~isequal(experiment, '')
    switches = readParams(sprintf('Experiments/%s.txt', experiment), switches, dakota);
    if ~switches.main.suppressChecks; if ~isequal(input(sprintf('Running "%s" experiment. Continue? Y/N: ', experiment), 's'),'Y'); return; end; end
else
    if ~switches.main.suppressChecks; if ~isequal(input('No experiment selected. Continue? Y/N: ', 's'),'Y'); return; end; end
end

%% Parameter Override

%% Dakota Integration II

if ~isequal(dakota, {})
    switches.main.text = 'Low';
    switches.main.agentGoalPositions = 'random';
    if switches.diagnostic.track_SA_FORCE ~= true
        switches.diagnostic.track_SA = false;
    end
end

%% ???

if ~isempty(martinetExperiment) && ~isequal(martinetExperiment, 'None');
    global goalIterations
    switches.main.diagonalActions = false;
    switches.modes.martinetPositions = true;
    switches.modes.randomisedPositions = false;
    switches.learner_sw.learner_steps = 50;
    switches.modes.learn_chunks = false;
    switches.modes.use_chunks = false;
    switches.modes.occupancy_grid = true;
    switches.modes.track_SA = false;
    switches.modes.track_sensory = true;
    switches.modes.Verstynen = false;
    switches.modes.text = 'Low';
    switches.modes.gatechunk_cells = false;
    switches.modes.reduced_SA = false;
    switches.modes.useRandomTrialDist = false;
    switches.modes.randomTrialDist = 0;
else
    goalIterations = 100;
    martinetExperiment = 'None';
end
if switches.experiment.Verstynen == true
    assert(isempty(martinetExperiment) || isequal(martinetExperiment, 'None'))
    assert(isequal(worldType, 'keypress'))
    switches.modes.useProbPropagate = false;
end

if switches.control_sw.useRandomTrialDist == true
    if switches.control_sw.useRandomTrialDist == true && switches.main.randomisedPositions ~= true
        error('A Random Trial Distance cannot be set unless randomisedPositions is turned on')
    end
    assert(switches.params.randomTrialDist > 0)
end

modeCheck('useMaxPropagate', switches.control_sw.useMaxPropagate, switches.main.suppressChecks);

if ~isequal(switches.main.agentGoalPositions, 'martinet')
    if switches.main.runLearner == true
        modeCheck('Accelerated Learning', switches.learner_sw.accelerated_learning, switches.main.suppressChecks);
        modeCheck('Anti-Hebbian Learning Active', switches.learner_sw.antiHebb, switches.main.suppressChecks);
    end
    if switches.main.runController == true
        modeCheck('Stochastic Exploration', switches.control_sw.stochastic_exploration, switches.main.suppressChecks);
        modeCheck('Chunk Learning', switches.control_sw.learn_chunks, switches.main.suppressChecks);
        modeCheck('Probabilistic Propagation', switches.control_sw.useProbPropagate, switches.main.suppressChecks);
        modeCheck('Using Chunks', switches.control_sw.use_chunks, switches.main.suppressChecks);
        modeCheck('SpecifiedTrialDistance', switches.control_sw.useRandomTrialDist, switches.main.suppressChecks);
    end
    modeCheck('Verstynen Experiment', switches.experiment.Verstynen, switches.main.suppressChecks);
    modeCheck('Noisy Propagation', switches.main.propagation_noise, switches.main.suppressChecks);
    modeCheck('Gate-Chunk Cells', switches.main.gatechunk, switches.main.suppressChecks);
    modeCheck('Track Firing', switches.diagnostic.track_firing, switches.main.suppressChecks);
    modeCheck('Reduced Sensory Allocation', switches.main.reduced_SA, switches.main.suppressChecks);
    modeCheck('Diagonal Actions', switches.main.diagonalActions, switches.main.suppressChecks);
    modeFalseCheck('Diagonal Actions', switches.main.diagonalActions, switches.main.suppressChecks);
end

if ~(isequal(switches.main.worldType,'maze') || isequal(switches.main.worldType,'arm') || isequal(switches.worldType,'keypress'))
    error('Invalid World Type')
end

if isequal(world, [])
    world = struct();
    world.worldType = switches.main.worldType;
end

%% Modes Effects
switch switches.main.provide_agent
    case false
        world.worldSize_x = switches.params.worldSize_x;                                                                                                           % Set the x and y size of the simulated 2D world.
        world.worldSize_y = switches.params.worldSize_y;
        
    case 'load'
        world.worldSize_x = switches.params.worldSize_x;                                                                                                           % Set the x and y size of the simulated 2D world.
        world.worldSize_y = switches.params.worldSize_y;
        
    otherwise
        assert(isequal(world.worldSize_x, switches.params.worldSize_x))
        assert(isequal(world.worldSize_y, switches.params.worldSize_y))
        
end

if switches.main.load_walls
    assert(isequal(switches.main.worldType, 'maze'))
    if isfield(world, 'walls')
        if ~switches.main.suppressChecks
            if ~isequal(input('WARNING: Overwrite Map? ', 's'),'Y')
                error('Bad Mode')
            end
        end
    end
    switch switches.params.walls
        case 'SmallOpen'
            tmp_walls = load(fullfile(pwd, 'Walls', 'smallopen_walls.mat'), 'walls');
            world.walls = tmp_walls.walls;
        case 'SmallMaze'
            tmp_walls = load(fullfile(pwd, 'Walls', 'smallmaze_walls.mat'), 'walls');
            world.walls = tmp_walls.walls;
        case 'SmallBisected'
            tmp_walls = load(fullfile(pwd, 'Walls', 'smallbisected_walls.mat'), 'walls');
            world.walls = tmp_walls.walls;
        case 'LargeOpen'
            tmp_walls = load(fullfile(pwd, 'Walls', 'open_walls.mat'), 'walls');
            world.walls = tmp_walls.walls;
        case 'LargeMaze'
            tmp_walls = load(fullfile(pwd, 'Walls', 'maze_walls.mat'), 'walls');
            world.walls = tmp_walls.walls;
        case 'Fakhari1'
            tmp_walls = load(fullfile(pwd, 'Walls', 'Fakhari1_walls.mat'), 'walls');
            world.walls = tmp_walls.walls;
        otherwise
            error('Switch Error')
    end
    assert(switches.main.manual_walls == false)
end

if switches.experiment.Verstynen == true
    world.worldSize_x = 8;
    world.worldSize_y = 100;
elseif ~isempty(martinetExperiment) && ~isequal(martinetExperiment, 'None')
    world.worldSize_x = 10;
    world.worldSize_y = 10;
end

%% Call Chunk_MazeWord

switch switches.main.provide_agent
    case true
        [results, agent, world] = ChunkMaze_World(switches, agent, world);
    case 'load'
        tmp_agent = load(fullfile(pwd, 'Agents', switches.params.agent_to_load), 'agent');
        agent = tmp_agent.agent;
        [results, agent, world] = ChunkMaze_World(switches, agent, world);
    case false
        [results, agent, world] = ChunkMaze_World(switches, [], world);
end

switch switches.diagnostic.IT
    case true
        [~, results.IRs, results.maxinfo] = testSAresponses(agent, world, switches, false);
    case false
    otherwise
        error('Switch Error')
end

end