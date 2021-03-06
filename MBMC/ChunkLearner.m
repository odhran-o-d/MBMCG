function [agent, SA_tracked, gate_tracked, sensory_tracked] = ChunkLearner(agent, world, world_update_function, switches, forced_actions)

% Based on Experiment66_learner_SAFE.

% Input parameter 'steps' is an integer describing the number of
% exploration steps to be made.

% Input parameter 'actions' is a cell array of strings designating certain
% actions, e.g.:
% ['RED_ON', 'RED_OFF', 'GREEN_ON', 'GREEN_OFF']
% ['Forward', 'Backward', 'Left', 'Right']

% Outputs synapse matrices.

% Outputs sensory_tracked, which tracks the various states the model has
% experienced.

% Outputs SA_decoded, which tracks the state/action combination currently
% associated with each neuron.

% Calls a WORLD function to receive sensory input.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Parameters

global martinetExperiment
global modes

learner_sw = switches.learner_sw;
main = switches.main;
params = switches.params;
actions = world.actions;

if numel(forced_actions) > 0
    learner_sw.forced_run = true;
end

% Movement
switch martinetExperiment
    case 'P1'
        load('MartinetWalks');
        learner_sw.forced_run = true;
        forced_actions = P1;
    case 'P2'
        load('MartinetWalks');
        learner_sw.forced_run = true;
        forced_actions = P2;
    case 'P3'
        load('MartinetWalks');
        learner_sw.forced_run = true;
        forced_actions = P3;
end

if switches.experiment.Verstynen == true
    learner_sw.forced_run = true;
    switch world.cue
        case 1
            forced_actions = {'key_1'};
        case 2
            forced_actions = {'key_2'};
        case 3
            forced_actions = {'key_3'};
        case 4
            forced_actions = {'key_4'};
        case 5
            forced_actions = {'key_5'};
        case 6
            forced_actions = {'key_6'};
        case 7
            forced_actions = {'key_7'};
        case 8
            forced_actions = {'key_8'};
    end
end

if learner_sw.forced_run == true
    steps = length(forced_actions)+1;
end

% Analysis
SA_tracked = {};
gate_tracked = {};
sensory_tracked = {};



%% RUN TRIAL
switch main.text
    case 'None'
    case 'Low'
        disp('Learning...')
    otherwise
        
end

%% Timing

tic;
duration = 0;
num_text = 5;
verbose_times = round(linspace(1, learner_sw.steps, num_text+1));

for time = 1:learner_sw.steps
    
    %if mod(time, 500) == 0
    switch main.text
        case 'None'
        case 'Low'
            if ismember(time, verbose_times)
                fprintf('%d/%d \n', time, learner_sw.steps)
            end
        otherwise
            fprintf('%d/%d \n', time, learner_sw.steps)
    end
    
    if mod(time, 100) == 0;
        duration = toc; tic;
        if duration > 30
            fprintf('%.0f min remaining. \n', (((learner_sw.steps-time)/100)*duration)/60)
        end
    end
    
    noNaNsensorytoSA = agent.sensorytoSA_synapses;
    noNaNsensorytoSA(isnan(noNaNsensorytoSA)) = 0;
    
    noNaNmotortoSA = agent.motortoSA_synapses;
    noNaNmotortoSA(isnan(noNaNmotortoSA)) = 0;
    
    noNaNSAtomotor = agent.SAtomotor_synapses;
    noNaNSAtomotor(isnan(noNaNSAtomotor)) = 0;
    
    %% Firing of SA cells and Recruitment of Column
    
    % GET SENSORY DATA FROM WORLD (ONLY 1 CELL ACTIVE AT A TIME)
    switch learner_sw.initial_sensory_update
        case true
            [agent.sensory_cells, ~, ~, world] = world_update_function(agent, world, '', 'yes', switches);
            switch switches.main.text
                case 'Very High'
                    fprintf('State = %s', num2str(find(agent.sensory_cells(:) > 0.1)'))
                    disp(' ')
                otherwise
            end
        case false
        otherwise
            error('Switch Error')
    end
    
    % SA cells fire based on current sensory cells (state).
    switch learner_sw.sensoryonly_SA
        case true
            agent.SA_cells = dot((repmat(agent.sensory_cells(:),[1,numel(agent.SA_cells)])), noNaNsensorytoSA);
            agent.SA_cells = reshape(agent.SA_cells, agent.num_SA);
            switch switches.main.text
                case 'Very High'
                    fprintf('Max SA = %s\n', num2str(max(max(agent.SA_cells))));
            end
        case false
        otherwise
            error('Switch Error')
    end
    
    % TRANSFER FUNCTION
    switch learner_sw.sensoryonly_bandpass
        case true
            agent.SA_cells(agent.SA_cells > params.sensoryonlybandpass_low & agent.SA_cells < params.sensoryonlybandpass_high) = 0;
        case false
        otherwise
            error('Switch Error')
    end
    
    switch learner_sw.SAfiring_check
        case true
            if ~any(agent.SA_cells)
                error('No Firing SA cells.')
            end
        case false
        otherwise error('Switch Error')
    end
    
    switch learner_sw.columnar_WTA
        case true
            % columnar WTA
            [~, idx] = max(sum(agent.SA_cells, 1));
            agent.SA_cells(:) = 0;
            agent.SA_cells(:,:,idx) = 1;
        case false
        otherwise
            error('Switch Error')
    end
    
    % RECORD STATES EXPERIENCED
    sensory_info = find(agent.sensory_cells);
    switch world.worldType
        case 'maze'
            sensory_tracked{time} = world.state;
        case 'keypress'
            sensory_tracked{time} = sensory_info;
    end
    
    switch learner_sw.sensorySA_update
        case true
            % Update sensorytoSA weights.
            nan_check = true;
            if learner_sw.antiHebb == true
                agent.sensorytoSA_synapses = agent.sensorytoSA_synapses + (params.learningRate * (agent.sensory_cells(:) * agent.SA_cells(:)')) ...
                    - (modes.learningRate * modes.antiHebbFactor * (agent.sensory_cells(:) * agent.SA_cells(:)'));
            else
                agent.sensorytoSA_synapses = agent.sensorytoSA_synapses + (params.learningRate * (agent.sensory_cells(:) * agent.SA_cells(:)'));
            end
            agent.sensorytoSA_synapses = normalise(agent.sensorytoSA_synapses, agent.sensory_threshold, nan_check);
            assert(all(isfinite(agent.sensorytoSA_synapses(:))))
            noNaNsensorytoSA = noNaN(agent.sensorytoSA_synapses);
        case false
        otherwise
            error('Switch Error')
    end
    %% TRACE LEARNING: Update connections from ACTIVE COLUMN to PREVIOUS (trace) SA_CELL:
    
    % Update synapses using lr * state firing * trace rule (backwards)
    switch learner_sw.trace_update
        case true
            agent.SAtoSA_synapses = agent.SAtoSA_synapses + (params.trace_learningRate * agent.SA_cells(:) * agent.SA_trace(:)');
        case false
        otherwise
            error('Switch Error')
    end
    
    switch learner_sw.bilateraltrace_update
        case true
            agent.SAtoSA_synapses = agent.SAtoSA_synapses + (params.trace_learningRate * agent.SA_cells(:) * agent.SA_trace(:)');
            agent.SAtoSA_synapses = agent.SAtoSA_synapses + (params.trace_learningRate * agent.SA_trace(:) * agent.SA_cells(:)');
        case false
        otherwise
            error('Switch Error')
    end
    
    switch learner_sw.SASA_Hebb_update
        case true
            %agent.SAtoSA_synapses = agent.SAtoSA_synapses + (params.trace_learningRate * agent.SA_cells(:) * agent.SA_cells(:)');
            agent.SAtoSA_synapses = weightUpdate(agent.SAtoSA_synapses, agent.SA_cells, agent.SA_cells, params.trace_learningRate);
        case false
        otherwise
            error('Switch Error')
    end
    
    % Normalise synapses
    switch learner_sw.trace_normalise
        case true
            nan_check = true;
            agent.SAtoSA_synapses = normalise(agent.SAtoSA_synapses, agent.trace_threshold, nan_check);
            agent.SAtoSA_synapses(isnan(agent.SAtoSA_synapses)) = 0;
        case false
        otherwise
            error('Switch Error')
    end
    
    %% Select an action and activate the appropriate motor cell.
    
    if learner_sw.forced_run == true
        if time > length(forced_actions)
            action = '';
            %return
        else
            action = forced_actions(time);
        end
    elseif learner_sw.accelerated_learning == true
        current_position = find(world.state(:,:,1));
        neighbours = chebyshevDistance(size(world.state, 1), size(world.state, 2), current_position, world.state(:,:,3), 1);
        neighbours(current_position) = 1;
        tmp_walls = world.state(:,:,3);
        neighbours = reshape(tmp_walls(logical(neighbours)), [3 3]);
        neighbours = neighbours == 0;
        neighbours(5) = 0; if modes.diagonalActions == false; neighbours([1 3 7 9]) = 0; end;
        potential_next_states = find(neighbours);
        potential_next_states = potential_next_states(randperm(length(potential_next_states)));
        %potential_next_states = potential_next_states(find(potential_next_states ~= 1 & potential_next_states ~= 3 & potential_next_states ~= 7 & potential_next_states ~= 9));
        switch potential_next_states(1)
            case 1
                action = 'NW';
            case 2
                action = 'W';
            case 3
                action = 'SW';
            case 4
                action = 'N';
            case 5
                action = '';
            case 6
                action = 'S';
            case 7
                action = 'NE';
            case 8
                action = 'E';
            case 9
                action = 'SE';
        end
    else
        action = actions{randi(size(actions,2))};
    end
    
    % UPDATE WORLD FROM ACTION (ONLY 1 CELL ACTIVE AT A TIME)
    [~, ~, ~, world] = world_update_function(agent, world, action, 'no', switches);
    
    %{
    if ~isempty(action)
    assert(ischar(action{:}))
    end
    %}
    
    switch learner_sw.activate_motor
        case true
            [~, idx] = ismember(action, actions);
            agent.motor_cells(idx) = 1;
            switch switches.main.text
                case 'Very High'
                    fprintf('Action = %s', num2str(find(agent.motor_cells > 0.1)'))
                    disp(' ')
                otherwise
            end
        case false
        otherwise
            error('Switch Error')
    end
    
    % Activation of SA cells from sensory and motor cells simulataneously.
    switch learner_sw.sensorymotor_SA
        case true
            agent.SA_cells(:) = 0;
            agent.SA_cells = cellPropagate(agent.SA_cells, agent.motor_cells, agent.sensory_cells, [], noNaNmotortoSA, noNaNsensorytoSA, []);
            agent.SA_cells = reshape(agent.SA_cells, agent.num_SA);
        case false
        otherwise
            error('Switch Error')
    end
    
    switch learner_sw.sensorymotor_bandpass
        case true
            agent.SA_cells(agent.SA_cells > params.sensorymotorbandpass_low & agent.SA_cells < params.sensorymotorbandpass_high) = 0;
        case false
        otherwise
            error('Switch Error')
    end
    
    % WTA:
    switch learner_sw.actionWTA
        case true
            agent.SA_cells = WTA_Competition(agent.SA_cells(:), false);
            agent.SA_cells = reshape(agent.SA_cells, agent.num_SA);
        case 'CREB'
            agent.SA_cells = WTA_Competition(agent.SA_cells(:));
            agent.SA_cells = reshape(agent.SA_cells, agent.num_SA);
            agent.SA_cells = agent.SA_cells + agent.SA_trace;
        case false
        otherwise
            error('Switch Error')
    end
    
    switch main.text
        case 'Very High'
            fprintf('SA = %s', num2str(find(agent.SA_cells > 0.1)'))
            disp(' ')
        otherwise
    end
    
    switch learner_sw.sensorymotor2SA_update
        case 'M2SAonly'
            nan_check = true;
            agent.motortoSA_synapses = agent.motortoSA_synapses + params.learningRate * agent.motor_cells(:) * agent.SA_cells(:)';
            agent.motortoSA_synapses = normalise(agent.motortoSA_synapses, agent.motor_threshold, nan_check);
            agent.sensorytoSA_synapses = agent.sensorytoSA_synapses + (params.learningRate * (agent.sensory_cells(:) * agent.SA_cells(:)'));
            agent.sensorytoSA_synapses = normalise(agent.sensorytoSA_synapses, agent.sensory_threshold, nan_check);
            assert(all(isfinite(agent.sensorytoSA_synapses(:))))
            noNaNsensorytoSA = noNaN(agent.sensorytoSA_synapses);
        case 'reciprocal'
            nan_check = true;
            agent.motortoSA_synapses = agent.motortoSA_synapses + params.learningRate * agent.motor_cells(:) * agent.SA_cells(:)';
            agent.SAtomotor_synapses = agent.SAtomotor_synapses + params.learningRate * agent.SA_cells(:) * agent.motor_cells(:)';
            agent.motortoSA_synapses = normalise(agent.motortoSA_synapses, agent.motor_threshold, nan_check);
            agent.SAtomotor_synapses = normalise(agent.SAtomotor_synapses', agent.motor_threshold, nan_check);
            agent.SAtomotor_synapses = agent.SAtomotor_synapses';
            assert(all(isfinite(agent.SAtomotor_synapses(:))))
            agent.sensorytoSA_synapses = agent.sensorytoSA_synapses + (params.learningRate * (agent.sensory_cells(:) * agent.SA_cells(:)'));
            agent.sensorytoSA_synapses = normalise(agent.sensorytoSA_synapses, agent.sensory_threshold, nan_check);
            assert(all(isfinite(agent.sensorytoSA_synapses(:))))
            noNaNsensorytoSA = noNaN(agent.sensorytoSA_synapses);
        case false
        otherwise
            error('Switch Error')
    end
    
    %% Gating
    
    switch learner_sw.sensory_gate
        case true
            agent.gate_cells = cellPropagate(agent.gate_cells, agent.sensory_cells, [], [], agent.sensorytogate_synapses, [], []);
        case false
        otherwise
            error('Switch Error')
    end
    
    % columnar WTA
    switch learner_sw.columnarWTA_gate
        case true
            [~, idx] = max(sum(agent.gate_cells, 1));
            agent.gate_cells(:) = 0;
            agent.gate_cells(:,:,idx) = 1;
        case false
        otherwise
            error('Switch Error')
    end
    
    %agent.gate_cells(agent.gate_cells == max(max(agent.gate_cells))) = 1;
    %agent.gate_cells(agent.gate_cells ~= max(max(agent.gate_cells))) = 0;
    
    switch learner_sw.sensorygate_update
        case true
            nan_check = true;
            agent.sensorytogate_synapses = agent.sensorytogate_synapses + (params.learningRate * (agent.sensory_cells(:) * agent.gate_cells(:)'));
            agent.sensorytogate_synapses = normalise(agent.sensorytogate_synapses, agent.sensorytogate_threshold, nan_check);
            assert(all(isfinite(agent.sensorytogate_synapses(:))))
        case false
        otherwise
            error('Switch Error')
    end
    
    switch learner_sw.sensorySA_gate
        case true
            agent.gate_cells = cellPropagate(agent.gate_cells, agent.sensory_cells, agent.SA_cells, [], agent.sensorytogate_synapses, agent.SAtogate_synapses, []);
        case false
        otherwise
            error('Switch Error')
    end
    
    switch learner_sw.gate_bandpass
        case true
            agent.gate_cells(agent.gate_cells > params.gatebandpass_low & agent.gate_cells < params.gatebandpass_high) = 0;
        case false
        otherwise, error('Switch Error')
    end
    
    switch learner_sw.gateWTA
        case true
            agent.gate_cells = WTA_Competition(agent.gate_cells, false);
        case false
        otherwise
            error('Switch Error')
    end
    
    switch learner_sw.gate_check
        case true
            if ~any(agent.gate_cells)
                error('No gate cell firing')
            end
        case false
        otherwise
            error('Switch Error')
    end
    
    switch learner_sw.postBand_sensoryGate_update
        case true
            nan_check = true;
            agent.sensorytogate_synapses = agent.sensorytogate_synapses + (params.learningRate * (agent.sensory_cells(:) * agent.gate_cells(:)'));
            agent.sensorytogate_synapses = normalise(agent.sensorytogate_synapses, agent.sensorytogate_threshold, nan_check);
            assert(all(isfinite(agent.sensorytogate_synapses(:))))
        case false
        otherwise
            error('Switch Error')
    end
    
    switch learner_sw.SAgate_update
        case true
            nan_check = true;
            agent.SAtogate_synapses = agent.SAtogate_synapses + params.learningRate * agent.SA_cells(:) * agent.gate_cells(:)';
            agent.SAtogate_synapses = normalise(agent.SAtogate_synapses, agent.SAtogate_threshold, nan_check);
            assert(all(isfinite(agent.SAtogate_synapses(:))))
        case false
        otherwise
            error('Switch Error')
    end
    
    switch learner_sw.gatemotor_update
        case true
            agent.gatetomotor_synapses = agent.gatetomotor_synapses + params.learningRate * agent.gate_cells(:) * agent.motor_cells(:)';
        case false
        otherwise
            error('Switch Error')
    end
    
    switch learner_sw.gatemotor_normalise
        case true
            nan_check = true;
            agent.gatetomotor_synapses = normalise(agent.gatetomotor_synapses', 1, nan_check);
            agent.gatetomotor_synapses = agent.gatetomotor_synapses';
            assert(all(isfinite(agent.gatetomotor_synapses(:))))
        case false
        otherwise
            error('Switch Error')
    end
    
    switch learner_sw.test_motor
        case true
            test_motor = zeros(agent.num_motor);
            test_motor = cellPropagate(test_motor, agent.gate_cells, [], [], agent.gatetomotor_synapses, [], []);
            test_motor = WTA_Competition(test_motor(:));
            %disp([test_motor(:) agent.motor_cells(:)])
            if test_motor(:) ~= agent.motor_cells(:)
                error('Not equal')
            end
            
        case false
        otherwise
            error('Switch Error')
    end
    
    % Weights updated.
    switch learner_sw.motor2SA_update
        case true
            agent.motortoSA_synapses = agent.motortoSA_synapses + params.learningRate * agent.motor_cells(:) * agent.SA_cells(:)';
        case false
        otherwise
            error('Switch Error')
    end
    
    switch learner_sw.SA2motor_update
        case true
            agent.SAtomotor_synapses = agent.SAtomotor_synapses + params.learningRate * agent.SA_cells(:) * agent.motor_cells(:)';
        case false
        otherwise
            error('Switch Error')
    end
    
    % Weights normalised
    switch learner_sw.motorSA_normalise
        case true
            nan_check = true;
            agent.motortoSA_synapses = normalise(agent.motortoSA_synapses, agent.motor_threshold, nan_check);
            agent.SAtomotor_synapses = normalise(agent.SAtomotor_synapses', agent.motor_threshold, nan_check);
            agent.SAtomotor_synapses = agent.SAtomotor_synapses';
            assert(all(isfinite(agent.SAtomotor_synapses(:))))
        case false
        otherwise
            error('Switch Error')
    end
    
    % RECORD STATE/ACTION COMBINATIONS EXPERIENCED
    switch switches.main.xy_sensory
        case true
            SA_info{1} = xy_sensory2ind(agent.sensory_cells, world);
        case false
            SA_info{1} = find(agent.sensory_cells);
        otherwise, error('Switch Error')
    end
    SA_info{2} = find(agent.motor_cells);
    SA_info{3} = find(agent.SA_cells > 0.1)';
    SA_tracked{time} = SA_info;
    
    switch switches.main.xy_sensory
        case true
            gate_info{1} = xy_sensory2ind(agent.sensory_cells, world);
        case false
            gate_info{1} = find(agent.sensory_cells);
        otherwise, error('Switch Error')
    end
    gate_info{2} = find(agent.motor_cells);
    gate_info{3} = find(agent.SA_cells > 0.1);
    gate_info{4} = find(agent.gate_cells);
    gate_tracked{time} = gate_info;
    
    %% Calculate SA trace
    
    % Calculate the trace value for all cells
    switch learner_sw.getSAtrace
        case true
            agent.SA_trace = getTrace(agent.SA_cells, agent.SA_trace, params.eta);
        case 'CREB'
            agent.SA_trace = agent.SA_cells * 0.1;
        case false
        otherwise
            error('Switch Error')
    end
    
    %% Reset Cells and Update parameters
    switch learner_sw.SA_reset
        case true
            agent.SA_cells(:) = 0;
        case 'CREB'
            agent.SA_cells = 0.1 * agent.SA_cells;
        case false
        otherwise
            error('Switch Error')
    end
    switch learner_sw.action_reset
        case true
            agent.sensory_cells(:) = 0;
        case false
        otherwise
            error('Switch Error')
    end
    switch learner_sw.action_reset
        case true
            agent.motor_cells(:) = 0;
        case false
        otherwise
            error('Switch Error')
    end
    
    if learner_sw.forced_run == true
        if time > length(forced_actions)
            return
        end
    end
    
    %% Change Walls if Necessary
    if strcmp(martinetExperiment, 'AGate') == true && find(world.state(:,:,1)) == 37
        martinetExperiment = 'A';
        world_copy = load('MartinetWallsBlockA.mat', 'world');
        world.state(:,:,3) = world_copy.world.state(:,:,3);
        world.walls = world_copy.world.walls;
    end
    if strcmp(martinetExperiment, 'BGate') == true && find(world.state(:,:,1)) == 35
        martinetExperiment = 'B';
        world_copy = load('MartinetWallsBlockB.mat', 'world');
        world.state(:,:,3) = world_copy.world.state(:,:,3);
        world.walls = world_copy.world.walls;
    end
    
end

agent.SA_trace(:) = 0;

switch main.text
    case 'None'
    case 'Low'
    otherwise
        disp('Learning Complete')
end
end















function [trace] = getTrace(postSynaptic_fr, postSynaptic_trace, eta)

trace = ((1-eta)*postSynaptic_fr) + eta*postSynaptic_trace;
end