function agent = activateChunkCells(switches, chunkCompetitionType, learn_chunks, agent, setVerbose)


%% Parameters
params = switches.params;
control_sw = switches.control_sw;

%% Feed Activity to Chunk Cells

% Uses a full trace rule -- preSynaptic_trace *
% postSynaptic_trace

% Calculate activation of chunk cells from SA cells
switch control_sw.chunk_activation
    case true
        agent.motor_sequence_cells = cellPropagate(agent.motor_sequence_cells, agent.motor_cells, [], [], agent.MotortoMotorSequence_synapses, [], []);
        agent.motor_sequence_cells = reshape(agent.motor_sequence_cells,agent.num_motor_sequence_cells);
        if ~any(agent.motor_sequence_cells) && setVerbose == true
            disp('No chunk cells activated.')
            return
        end
    case false
    otherwise, error('Switch Error')
end

chunk_save = agent.motor_sequence_cells;

switch chunkCompetitionType
    
    case 'subdiv' % subtractive competition with normalisation
        agent.motor_sequence_cells = agent.motor_sequence_cells - params.chunk_modifier * mean(mean(agent.motor_sequence_cells));
        agent.motor_sequence_cells(agent.motor_sequence_cells < 0) = 0;
        if any(agent.motor_sequence_cells) == 0
            disp('No chunk cells firing after subtractive competition')
        else
            % normalise
            agent.motor_sequence_cells = 1 * (agent.motor_sequence_cells/max(max(agent.motor_sequence_cells)));
        end
        
    case 'WTA'
        
        agent.motor_sequence_cells = WTA_Competition(agent.motor_sequence_cells, true);
        
    case 'none'
        
    otherwise disp('Chunk Competition not specified. Using "none"')
        
end

if setVerbose == true
    % Display firing cells and traces
    fprintf('SA = %d.\n' , find(agent.motor_cells))
    fprintf('SA (trace) = %s.\n' , num2str(find(agent.SA_trace)'))
    fprintf('Chunk = %s.\n', num2str(find(agent.motor_sequence_cells)))
    fprintf('Chunk (trace) = %s.\n', num2str(find(agent.motseq_trace > 0.09)))
    %fprintf('Super = %s.\n', num2str(find(super_cells > 0.9)))
    %fprintf('Super (trace) = %s.\n', num2str(find(super_trace > 0.09)))
    disp(' ')
end

if learn_chunks == true % this is NOT a switch or a mode, but b/c this function is called twice and only learns on the second time
    
    % Calculate memory trace for all cells.
    switch control_sw.chunk_trace
        case true
            agent.motseq_trace = getTrace(agent.motor_sequence_cells, agent.motseq_trace, params.chunk_eta);
            agent.SA_trace = getTrace(agent.motor_cells, agent.SA_trace, params.chunk_eta);
        case false
        otherwise, error('Switch Error')
    end
    
    % Update synapses to and from chunk cells.
    switch control_sw.chunk_synapse_update
        case true
            %agent.MotortoMotorSequence_synapses = agent.MotortoMotorSequence_synapses + params.chunktoSA_learningRate * agent.motseq_trace(:) * agent.SA_trace(:)';
            agent.MotortoMotorSequence_synapses = agent.MotortoMotorSequence_synapses + params.SAtochunk_learningRate * agent.motor_cells(:) * agent.motseq_trace(:)';
        case false
        otherwise, error('Switch Error')
    end
    
    % Normalise synapse weights to and from chunk cells.
    switch control_sw.chunk_normalise
        case true
            nan_check = true;
            agent.MotortoMotorSequence_synapses = normalise(agent.MotortoMotorSequence_synapses, params.chunk_threshold, nan_check);
            %for chunk = 1:numel(agent.motor_sequence_cells)
            agent.MotortoMotorSequence_synapses(agent.MotortoMotorSequence_synapses < 0.000000001) = 0;
            %end
            %
            assert(all(isfinite(agent.MotortoMotorSequence_synapses(:))))
            nan_check = true;
            agent.MotortoMotorSequence_synapses = normalise(agent.MotortoMotorSequence_synapses', params.chunk_threshold, nan_check);
            agent.MotortoMotorSequence_synapses = agent.MotortoMotorSequence_synapses';
            assert(all(isfinite(agent.MotortoMotorSequence_synapses(:))))
        case false
        otherwise, error('Switch Error')
    end
    
end

end