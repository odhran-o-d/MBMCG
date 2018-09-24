function [sensory_tracked, SA_gradient_mat, result, agent] = ChunkController(agent, world, switches, world_update_function)

global martinetExperiment

control_sw = switches.control_sw;

if switches.diagnostic.track_firing == true
    global firing
end
first_action = true;

params = switches.params;

%{
if use_chunks == true && learn_chunks == true
    error('Cannot currently learn and use chunks at the same time.')
end
%}

% Analysis
sensory_tracked = {};
SA_tracked = {};
SA_gradient_cell = {};
SA_gradient_mat = {};
agent_position_x = {};
agent_position_y = {};
scaleDisplay = true;

%% RUN TRIAL
%for time = 1:steps
time = 0;
while true
    time = time + 1;
    
    %% Set Up Reward Gradient
    % Place reward.
    % GET REWARD POSITION
    switch control_sw.initial_sensory_firing
        case true
            [agent.sensory_cells, reward_cells, ~, world] = world_update_function(agent, world, '', 'yes', switches);
        case false
        otherwise
            error('Switch Error')
    end
    
    % SA cells fire based on current sensory cells (agent position), current reward cells (reward position), and current SA cells.
    switch control_sw.sensoryreward2SA
        case true
            if switches.main.propagation_noise == true
                SA_reward = noisePropagate(params.propagation_noise, agent.SA_cells, reward_cells, [], [], agent.sensorytoSA_synapses, [], []);
            else
                SA_reward = cellPropagate(agent.SA_cells, reward_cells, [], [], agent.sensorytoSA_synapses, [], []);
            end
        case false
        otherwise, error('Switch Error')
    end
    
    % filter/transfer SA_reward function MAKE GENERAL LATER!!!!!!!!!!!!
    switch control_sw.SAreward_bandpass
        case true
            SA_reward(SA_reward <= 0.51) = 0; % = 0.5?
        case false
        otherwise, error('Switch Error')
    end
    
    switch control_sw.SAreward_check
        case 'fatal'
            if ~any(SA_reward(:))
                error('No SA_reward');
            end
        case 'nonfatal'
            if ~any(SA_reward(:))
                result = 'E';
                disp(result)
                total_steps = NaN;
                break
            end
        case false
        otherwise, error('Switch Error')
    end
    
    switch control_sw.use_chunks
        case true
            agent = activateChunkCells(switches, 'none', false, agent, false);
        case false
        otherwise, error('Switch Error')
    end
    
    % final SA update
    switch control_sw.propagation
        
        case 'probabilistic'
            assert(switches.main.propagation_noise == false)
            if control_sw.use_chunks == true
                agent.SA_cells = probPropagate(agent.SA_cells, SA_reward, agent.SA_cells, agent.chunk_cells, agent.SArewardtoSA_synapses, agent.SAtoSA_synapses, agent.chunktoSA_synapses);
            else
                agent.SA_cells = probPropagate(agent.SA_cells, SA_reward, agent.SA_cells, [], agent.SArewardtoSA_synapses, agent.SAtoSA_synapses, []);
            end
            
        case 'deterministic'
            agent = deterministicSA(agent, SA_reward, switches);
            
        case 'simple'
            assert(switches.control_sw.use_chunks == false)
            assert(switches.main.propagation_noise == false)
            agent.SA_cells = cellPropagate(agent.SA_cells, reward_cells, agent.SA_cells, [], agent.sensorytoSA_synapses, agent.SAtoSA_synapses, []);
            
        case false
            
        otherwise, error('Switch Error')
    end
    
    switch control_sw.inhibit_states
        case true
            assert(numel(params.inhibited_state) == 1)
            inhib_idx = SA_query(agent.SA_decoded, 'state', params.inhibited_state);
            inhib_idx = inhib_idx(:,3);
            agent.SA_cells(inhib_idx) = 0;
        case false
    end
    
    switch control_sw.SAthreshold
        case 'Top'
            agent.SA_cells(agent.SA_cells > params.SAthresholdTop) = params.SAthresholdTop;
        case 'TopAndBottom'
            agent.SA_cells(agent.SA_cells > params.SAthresholdTop) = params.SAthresholdTop;
            agent.SA_cells(agent.SA_cells < params.SAthresholdBottom) = 0;
        case false
        otherwise, error('Switch Error')
    end
    
    switch control_sw.EIbalance
        case true
            agent.SA_cells = agent.SA_cells - params.propagation_noise;
            agent.SA_cells(agent.SA_cells < 0) = 0;
        case false
        otherwise, error('Switch Error')
    end
    
    % Divisive competition in SA cells:
    switch control_sw.SAdivisive
        case true
            nan_check = false;
            for col = 1:size(agent.SA_cells,3)
                if any(agent.SA_cells(:,:,col) > params.divisive_threshold)
                    agent.SA_cells(:,:,col) = normalise(agent.SA_cells(:,:,col), 1, nan_check);
                end
            end
            %agent.SA_cells(:) = normalise(agent.SA_cells(:), 1);
            agent.SA_cells = reshape(agent.SA_cells,agent.num_SA);
        case false
        otherwise, error('Switch Error')
    end
    
    switch switches.diagnostic.track_SA
        case true
            switch world.worldType
                case 'maze'
                    [agent_position_x{end+1}, agent_position_y{end+1}] = ind2sub(size(world.state(:,:,1)), find(world.state(:,:,1)));
                    SA_gradient_cell{end+1} = SA_analyseAct('maze', world.worldSize_x, world.actions, agent.SA_cells, agent.SA_decoded, false, scaleDisplay);
                    SA_gradient_mat{end+1} = cell2mat(SA_gradient_cell{end});
                case 'arm'
                    agent_position_x{end+1} = world.arm.j2_pos_x; agent_position_y{end+1} = world.arm.j2_pos_y;
                    SA_gradient_cell{end+1} = SA_analyseAct('arm', world.worldSize_x, world.actions, agent.SA_cells, agent.SA_decoded, false, scaleDisplay);
                    SA_gradient_mat{end+1} = cell2mat(SA_gradient_cell{end});
            end
        case false
        otherwise, error('Switch Error')
    end
    
    % Fire gate cells from sensory and SA input
    switch control_sw.gate_update
        case true
            switch switches.main.propagation_noise
                case true
                    agent.gate_cells = noisePropagate(params.propagation_noise, agent.gate_cells, agent.sensory_cells, agent.SA_cells, [], agent.sensorytogate_synapses, agent.SAtogate_synapses, []);
                case false
                    agent.gate_cells = cellPropagate(agent.gate_cells, agent.sensory_cells, agent.SA_cells, [], agent.sensorytogate_synapses, agent.SAtogate_synapses, []);
                otherwise, error('Switch Error')
            end
        case false
        otherwise, error('Switch Error')
    end
    
    % Gate competition - threshold function
    switch control_sw.gate_threshold
        case true
            agent.gate_cells(agent.gate_cells <= params.gate_inhibition) = 0;
        case false
        otherwise, error('Switch Error')
    end
    
    % This is where gatechunk cells should be activated and learned
    switch switches.main.gatechunk
        case true
            nan_check = true;
            eta = 0.2;
            agent.gatechunk_cells = probPropagate(agent.gatechunk_cells, agent.gate_cells, [], [], agent.gatetogatechunk_synapses, [], []);
            
            agent.gatetogatechunk_synapses = agent.gatetogatechunk_synapses + (params.gatechunk_learningRate * (agent.gate_cells(:) * agent.gatechunk_trace(:)'));
            agent.gatechunktogate_synapses = agent.gatechunktogate_synapses + (params.gatechunk_learningRate * (agent.gatechunk_trace(:) * agent.gate_cells(:)'));
            agent.gatetogatechunk_synapses = normalise(agent.gatetogatechunk_synapses, agent.gatetogatechunk_threshold, nan_check);
            agent.gatechunktogate_synapses = normalise(agent.gatechunktogate_synapses, agent.gatechunktogate_threshold, nan_check);
            assert(all(isfinite(agent.gatetogatechunk_synapses(:))))
            assert(all(isfinite(agent.gatechunktogate_synapses(:))))
            agent.gatechunk_trace = getTrace(agent.gatechunk_cells, agent.gatechunk_trace, eta);
            agent.gatechunk_cells(:) = 0;
            %agent.gate_cells = cellPropagate(agent.gate_cells, agent.gatechunk_cells, [], [], agent.gatechunktogate_synapses, [], []);
        case false
        otherwise, error('Switch Error')
    end
    
    % Calculate activation to motor cells
    switch control_sw.motor_activate
        case true
            agent.motor_cells = zeros(agent.num_motor);
            if switches.main.propagation_noise == true
                agent.motor_cells = noisePropagate(params.propagation_noise, agent.motor_cells, agent.gate_cells, [], [], agent.gatetomotor_synapses, [], []);
            else
                agent.motor_cells = cellPropagate(agent.motor_cells, agent.gate_cells, [], [], agent.gatetomotor_synapses, [], []);
            end
            if switches.main.propagation_noise == false
                agent.motor_cells = WTA_Competition(agent.motor_cells(:));
            end
    end
    
    % Move agent.
    agent.motor_cells(agent.motor_cells <= params.motor_inhibition) = 0;
    if any(agent.motor_cells)
        if switches.main.propagation_noise == true
            agent.motor_cells = WTA_Competition(agent.motor_cells(:));
        end
        if first_action == true
            assignin('caller', 'first_processing', size(SA_gradient_mat, 2))
            first_action = false;
        end
        action = world.actions{find(agent.motor_cells == max(agent.motor_cells))};
        switch switches.main.text
            case 'Low'
            otherwise
                disp(action)
                disp(time)
        end
        %disp(find(world.state(:,:,1)))
        
        if strcmp(world.worldType, 'maze') == true
            saved_state = world.state(:,:,1);
        end
        
        [~, ~, ~, world] = world_update_function(agent, world, action, 'no', switches);
        
        if strcmp(world.worldType, 'maze') == true
            switch control_sw.surprise
                case 'hardwired'
                    if world.state(:,:,1) == saved_state
                        % Nociception: Martinet may have something like this too: see
                        % S1 state connectivity learning
                        bad_SA = agent.SA_decoded(agent.SA_decoded(:, 1) == find(saved_state) & agent.SA_decoded(:, 2) == find(agent.motor_cells), 3);
                        intended_SA = agent.SA_decoded(agent.SA_decoded(:, 1) == find(intended_state), 3);
                        agent.SAtoSA_synapses(intended_SA, bad_SA) = 0.1 * agent.SAtoSA_synapses(intended_SA, bad_SA);
                        if control_sw.learn_chunks == true && control_sw.use_chunks == true
                            agent.chunktoSA_synapses = (1 - repmat(agent.chunk_cells',[1 numel(agent.SA_cells)])) .* agent.chunktoSA_synapses;
                            agent.SAtochunk_synapses = (1 - repmat(agent.chunk_cells, [numel(agent.SA_cells) 1])) .* agent.SAtochunk_synapses;
                        end
                    else
                        bad_SA = agent.SA_decoded(agent.SA_decoded(:, 1) == find(saved_state) & agent.SA_decoded(:, 2) == find(agent.motor_cells), 3);
                        intended_SA = agent.SA_decoded(agent.SA_decoded(:, 1) == find(intended_state), 3);
                    end
                case 'learning'
                    if world.state(:,:,1) == saved_state
                        agent.sensory_cells(:) = 0;
                        reward_cells(:) = 0;
                        agent.SA_cells(:) = 0;
                        agent.motor_cells(:) = 0;
                        agent.chunk_cells(:) = 0;
                        agent.gate_cells(:) = 0;
                        forced_actions = action;
                        tmp_switch = switches.learner_sw.steps;
                        switches.learner_sw.steps = 2;
                        [agent, ~, ~, sensory_tmp] = ChunkLearner(agent, world, world_update_function, switches, forced_actions);
                        switches.learner_sw.steps = tmp_switch;
                        agent.sensory_cells(:) = 0;
                        reward_cells(:) = 0;
                        agent.SA_cells(:) = 0;
                        agent.motor_cells(:) = 0;
                        agent.chunk_cells(:) = 0;
                        agent.gate_cells(:) = 0;
                        sensory_tracked = horzcat(sensory_tracked, sensory_tmp);
                        time = time + length(sensory_tmp);
                    else
                    end
                case false
                otherwise
                    error('Switch Error')
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
        
        %% Record agent position and SA cell firing
        if switches.diagnostic.track_SA == true
            switch world.worldType
                case 'maze'
                    SA_tracked{end+1} = cell2mat(SA_analyseAct('maze', size(world.state,1), world.actions, agent.SA_cells, agent.SA_decoded, false, scaleDisplay));
                case 'arm'
                    SA_tracked{end+1} = cell2mat(SA_analyseAct('arm', world.worldSize_x, world.actions, agent.SA_cells, agent.SA_decoded, false, scaleDisplay));
                case 'keypress'
            end
        end
        if switches.diagnostic.track_sensory == true
            switch world.worldType
                case 'maze'
                    sensory_info = world.state;
                case 'arm'
                    sensory_info = world.arm;
                case 'keypress'
                    sensory_info = find(agent.sensory_cells);
            end
            sensory_tracked{end+1} = sensory_info;
        end
        
        %% TEMPORARY: activate SA cell and learn chunks
        %currentSA = agent.SA_decoded((agent.SA_decoded(:,1) == find(agent.sensory_cells)) & (agent.SA_decoded(:,2) == find(agent.motor_cells)), 3);
        %agent.SA_cells(:) = 0; agent.SA_cells(currentSA) = 1;
        switch control_sw.postAction_SA_WTA
            case true
                if switches.main.propagation_noise
                    agent.SA_cells = noisePropagate(params.propagation_noise, agent.SA_cells, agent.sensory_cells, agent.motor_cells, agent.SA_cells, agent.sensorytoSA_synapses, agent.motortoSA_synapses, agent.SAtoSA_synapses);
                else
                    agent.SA_cells = cellPropagate(agent.SA_cells, agent.sensory_cells, agent.motor_cells, agent.SA_cells, agent.sensorytoSA_synapses, agent.motortoSA_synapses, agent.SAtoSA_synapses);
                end
                agent.SA_cells = WTA_Competition(agent.SA_cells);
                agent.SA_trace = agent.SA_cells;
            case false
            otherwise, error('Switch Error')
        end
        
        switch control_sw.learn_chunks
            case true
                agent.chunk_cells(:) = 0;
                agent = activateChunkCells(switches, 'WTA', true, agent, false);
                if any(agent.chunk_cells > 0.1)
                    fprintf('Chunk: %d \n', find(agent.chunk_cells>0.1))
                end
            case false
            otherwise, error('Switch Error')
        end
        
        %% Check for Completion
        % ALTER FOR GENERALISATION, OR JUST CALL PART OF THE SIMULATION
        %if max(abs(current_state - reward_location)) < 0.5
        % If all nonzero elements of the reward representation are also
        % represented in the sensory cells, then end.
        switch world.worldType
            case 'keypress'
                if world.correct_action == true
                    result = 'Y';
                elseif time == control_sw.controller_steps
                    result = 'N';
                end
            otherwise
                [agent.sensory_cells, ~] = world_update_function(agent, world, '', 'yes', switches);
                if ~any(~ismember(find(reward_cells), find(agent.sensory_cells)))
                    result = 'Y';
                elseif time == control_sw.controller_steps
                    result = 'N';
                end
        end
        if exist('result', 'var')
            switch result
                case 'Y'
                    disp(time)
                    disp(result)
                    total_steps = time;
                    break
                case 'N'
                    disp(result)
                    total_steps = NaN;
                    break
            end
        end
        
        %% Clear Cells & Get Trace
        switch control_sw.reset_sensory
            case true
                agent.sensory_cells(:) = 0;
            case false
            otherwise, error('Switch Error')
        end
        switch control_sw.reset_reward
            case true
                reward_cells(:) = 0;
            case false
            otherwise, error('Switch Error')
        end
        switch control_sw.reset_SA
            case true
                agent.SA_cells(:) = 0;
            case false
            otherwise, error('Switch Error')
        end
        switch control_sw.reset_motor
            case true
                agent.motor_cells(:) = 0;
            case false
            otherwise, error('Switch Error')
        end
        switch control_sw.reset_chunk
            case true
                agent.chunk_cells(:) = 0;
            case false
            otherwise, error('Switch Error')
        end
        switch control_sw.reset_gate
            case true
                agent.gate_cells(:) = 0;
            case false
            otherwise, error('Switch Error')
        end
        switch control_sw.reset_SAtrace
            case true
                agent.SA_trace(:) = 0;
            case false
            otherwise, error('Switch Error')
        end
        
    else % End of if(motor) statement
        action = '';
    end
    
    % Temporary
    if control_sw.stochastic_exploration == true
        if mod(time, 200) == 0
            %if rand(1) < 0.02
            agent.sensory_cells(:) = 0;
            reward_cells(:) = 0;
            agent.SA_cells(:) = 0;
            agent.motor_cells(:) = 0;
            agent.chunk_cells(:) = 0;
            agent.gate_cells(:) = 0;
            [agent, ~, ~, sensory_tmp] = ChunkLearner(20, agent, actions, world_update_function);
            agent.sensory_cells(:) = 0;
            reward_cells(:) = 0;
            agent.SA_cells(:) = 0;
            agent.motor_cells(:) = 0;
            agent.chunk_cells(:) = 0;
            agent.gate_cells(:) = 0;
            sensory_tracked = horzcat(sensory_tracked, sensory_tmp);
            time = time + length(sensory_tmp);
        end
    end
    
    if time == control_sw.controller_steps
        result = 'N';
    end
    if exist('result', 'var')
        switch result
            case 'Y'
                disp(time)
                disp(result)
                total_steps = time;
                break
            case 'N'
                disp(result)
                total_steps = NaN;
                break
        end
    end
    
    % save firing
    if switches.diagnostic.track_firing == true
        firing.SA(end+1, :) = agent.SA_cells(:);
        firing.gate(end+1, :) = agent.gate_cells(:);
        firing.sensory(end+1, :) = agent.sensory_cells(:);
        firing.motor(end+1, :) = agent.motor_cells(:);
        firing.all(end+1, :) = [firing.SA(end, :) firing.gate(end, :) firing.sensory(end, :) firing.motor(end, :)];
        firing.chunk(end+1, :) = agent.chunk_cells(:);
    end
    
end




end