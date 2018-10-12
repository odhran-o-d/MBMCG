function agent = createAgent(world, switches, world_update_function)

disp('Setting up...')

global modes

params = switches.params;
agent = struct();

% Cells
switch func2str(world_update_function)
    case 'keypress_update'
        agent.sensory_cells = zeros([1 (5*8)+2]);
    case 'coffee update'
        agent.sensory_cells = struct();
        agent.sensory_cells.sugar = [0 1]; % [open, closed]
        agent.sensory_cells.coffee = [0 1]; % [open, closed]
        agent.sensory_cells.mug = [1 0 0 0 0 0 0]; % [water, coffee, milky coffee, sugary coffee, milky&sugar coffee, milk, sugar]
        agent.sensory_cells.milk = [0 1]; % [open, closed]
        agent.sensory_cells.hand = [1 0 0 0 0 0]; % [empty, sugar, coffee, mug, milk];
    otherwise
        [agent.sensory_cells, ~, ~, world] = world_update_function(agent, world, '', 'yes', switches);
end
agent.num_sensory = [size(agent.sensory_cells)];                                                            % Get layer size of sensory (state) cells.
agent.num_motor = [1 size(world.actions, 2)];                                                               % Set layer size of motor (action) cells as [1 * number of possible actions].
%                                                                  % Set the number of columns in the SA (state-action) layer as equal to the size of the state layer.
if switches.main.reduced_SA == true
    agent.num_SAcol = 200;
else
    switch func2str(world_update_function)
        case 'maze_update'
            agent.num_SAcol = numel(world.state(:,:,1));
        case 'arm_update'
            agent.num_SAcol = 900;
        case 'keypress_update'
            agent.num_SAcol = prod(agent.num_sensory);
        case 'coffee_update'
            agent.num_SAcol = 1120;
        otherwise
            error('Bad Update Function');
    end
end
agent.num_SAcellsinCol = prod(agent.num_motor);                                                             % Set the number of cells in each SA column as equal to the number of possible actions.
agent.num_SA = [agent.num_SAcellsinCol 1 agent.num_SAcol];                                                        % Set layer size of SA cells as [number of cells in column * 1 * number of columns]. This is important for competition in CONTROLLER function.
agent.num_chunk = [1 round(prod(agent.num_SA)/5)];                                                          % Set layer size of chunk cells equal to a third of SA cells
agent.num_gate = agent.num_SA;
agent.num_gatechunk = agent.num_chunk;
agent.num_motor_sequence_cells = [1 8];

agent.normalisation_threshold = params.normalisation_threshold;
agent.sensory_threshold = params.sensory_threshold; % Necessary to adjust these to compensate for different
agent.motor_threshold = params.motor_threshold; % numbers of synapses to sensory and motor cells.
agent.trace_threshold = params.trace_threshold; %0.01
agent.sensorytogate_threshold = params.sensorytogate_threshold;
agent.SAtogate_threshold = params.SAtogate_threshold;
agent.gatetogatechunk_threshold = params.gatetogatechunk_threshold;
agent.gatechunktogate_threshold = params.gatechunktogate_threshold;

% Make networks of sensory, motor and SA neurons.
agent.motor_cells = zeros(agent.num_motor); assert(numel(agent.motor_cells)>0);
agent.SA_cells = zeros(agent.num_SA); assert(numel(agent.SA_cells)>0);
agent.SA_trace = zeros(agent.num_SA); assert(numel(agent.SA_cells)>0);
agent.chunk_cells = zeros(agent.num_chunk);
agent.chunk_trace = zeros(agent.num_chunk);
agent.gate_cells = zeros(agent.num_gate);
agent.gatechunk_cells = zeros(agent.num_gatechunk);
agent.gatechunk_trace = zeros(agent.num_gatechunk);
agent.motor_sequence_cells = zeros(agent.num_motor_sequence_cells);

% Create synapse weights between SA cells and motor<=>SA.
agent.SAtoSA_synapses = GenerateZeroWeights(numel(agent.SA_cells), numel(agent.SA_cells), 1);
agent.motortoSA_synapses = Generate_Diluted_Weights(agent.motor_cells, agent.SA_cells, params.motortoSA_dilution, 1);
agent.SAtomotor_synapses = Generate_Diluted_Weights(agent.SA_cells, agent.motor_cells, params.SAtomotor_dilution, 1);
agent.SArewardtoSA_synapses = zeros(size(agent.SAtoSA_synapses));
agent.SArewardtoSA_synapses(logical(eye(size(agent.SArewardtoSA_synapses)))) = 1;
agent.SArewardtoSA_synapses = reshape(agent.SArewardtoSA_synapses, size(agent.SArewardtoSA_synapses));
agent.sensorytogate_synapses = Generate_Diluted_Weights(agent.sensory_cells, agent.gate_cells, params.sensorytogate_dilution, 1);
agent.SAtogate_synapses = Generate_Diluted_Weights(agent.SA_cells, agent.gate_cells, params.SAtogate_dilution, 1);
agent.gatetomotor_synapses = Generate_Diluted_Weights(agent.gate_cells, agent.motor_cells, params.gatetomotor_dilution, 1);
agent.sensorytoSA_synapses = Generate_Diluted_Weights(agent.sensory_cells, agent.SA_cells, params.sensorytoSA_dilution, 1);

%{
% Create sensory => SA synapses that are identical for all cells in a
% column.
agent.sensorytoSA_synapses = [];
for column = 1:agent.num_SAcol
    agent.sensorytoSA_synapses = [agent.sensorytoSA_synapses repmat(Generate_Diluted_Weights(agent.sensory_cells, 1, sensorytoSA_dilution, 1), [1 size(actions,2)])];
end
%}

%{
% Create sensory => gate synapses that are identical for all cells in a
% column.
agent.sensorytogate_synapses = [];
for column = 1:agent.num_gate(3)
    agent.sensorytogate_synapses = [agent.sensorytogate_synapses repmat(Generate_Diluted_Weights(agent.sensory_cells, 1, sensorytogate_dilution, 1), [1 size(actions,2)])];
end
%}

% Create chunk >--< SA synapses
agent.SAtochunk_synapses = Generate_Diluted_Weights(zeros(agent.num_SA), zeros(agent.num_chunk), params.chunk_dilution, params.chunk_weights);
agent.chunktoSA_synapses = zeros(numel(agent.chunk_cells), numel(agent.SA_cells));
agent.gatetogatechunk_synapses = Generate_Diluted_Weights(zeros(agent.num_gate), zeros(agent.num_gatechunk), params.chunk_dilution, params.chunk_weights);
agent.gatechunktogate_synapses = zeros(numel(agent.gatechunk_cells), numel(agent.gate_cells));

% Create Motor sequence neurons

agent.MotortoMotorSequence_synapses = Generate_Diluted_Weights(zeros(agent.num_motor), zeros(agent.num_motor_sequence_cells), params.chunk_dilution, params.chunk_weights);
agent.MotorSequencetoMotor_synapses = zeros(numel(agent.motor_cells), numel(agent.motor_sequence_cells));

% Normalise synapses
nan_check = true;
agent.sensorytoSA_synapses = normalise(agent.sensorytoSA_synapses, agent.sensory_threshold, nan_check);
agent.motortoSA_synapses = normalise(agent.motortoSA_synapses, agent.motor_threshold, nan_check);
agent.SAtomotor_synapses = normalise(agent.SAtomotor_synapses', agent.motor_threshold, nan_check);
agent.SAtomotor_synapses = agent.SAtomotor_synapses';
agent.sensorytogate_synapses = normalise(agent.sensorytogate_synapses, 0.5, nan_check);
agent.SAtogate_synapses = normalise(agent.SAtogate_synapses, 0.5, nan_check);

disp('...Setup Complete.')

end