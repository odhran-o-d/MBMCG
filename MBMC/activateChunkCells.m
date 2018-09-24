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
        agent.chunk_cells = dot(repmat(agent.SA_cells(:),[1,numel(agent.chunk_cells)]), agent.SAtochunk_synapses);
        agent.chunk_cells = reshape(agent.chunk_cells,agent.num_chunk);
        if ~any(agent.chunk_cells) && setVerbose == true
            disp('No chunk cells activated.')
            return
        end
    case false
    otherwise, error('Switch Error')
end

chunk_save = agent.chunk_cells;

switch chunkCompetitionType
    
    case 'subdiv' % subtractive competition with normalisation
        agent.chunk_cells = agent.chunk_cells - params.chunk_modifier * mean(mean(agent.chunk_cells));
        agent.chunk_cells(agent.chunk_cells < 0) = 0;
        if any(agent.chunk_cells) == 0
            disp('No chunk cells firing after subtractive competition')
        else
            % normalise
            agent.chunk_cells = 1 * (agent.chunk_cells/max(max(agent.chunk_cells)));
        end
        
    case 'WTA'
        
        agent.chunk_cells = WTA_Competition(agent.chunk_cells);
        
    case 'none'
        
    otherwise disp('Chunk Competition not specified. Using "none"')
        
end

if setVerbose == true
    % Display firing cells and traces
    fprintf('SA = %d.\n' , find(agent.SA_cells))
    fprintf('SA (trace) = %s.\n' , num2str(find(agent.SA_trace)'))
    fprintf('Chunk = %s.\n', num2str(find(agent.chunk_cells)))
    fprintf('Chunk (trace) = %s.\n', num2str(find(agent.chunk_trace > 0.09)))
    %fprintf('Super = %s.\n', num2str(find(super_cells > 0.9)))
    %fprintf('Super (trace) = %s.\n', num2str(find(super_trace > 0.09)))
    disp(' ')
end

if learn_chunks == true % this is NOT a switch or a mode, but b/c this function is called twice and only learns on the second time
    
    % Calculate memory trace for all cells.
    switch control_sw.chunk_trace
        case true
            agent.chunk_trace = getTrace(agent.chunk_cells, agent.chunk_trace, params.chunk_eta);
            agent.SA_trace = getTrace(agent.SA_cells, agent.SA_trace, params.chunk_eta);
        case false
        otherwise, error('Switch Error')
    end
    
    % Update synapses to and from chunk cells.
    switch control_sw.chunk_synapse_update
        case true
            agent.chunktoSA_synapses = agent.chunktoSA_synapses + params.chunktoSA_learningRate * agent.chunk_trace(:) * agent.SA_trace(:)';
            agent.SAtochunk_synapses = agent.SAtochunk_synapses + params.SAtochunk_learningRate * agent.SA_cells(:) * agent.chunk_trace(:)';
        case false
        otherwise, error('Switch Error')
    end
    
    % Normalise synapse weights to and from chunk cells.
    switch control_sw.chunk_normalise
        case true
            nan_check = true;
            agent.SAtochunk_synapses = normalise(agent.SAtochunk_synapses, params.chunk_threshold, nan_check);
            %for chunk = 1:numel(agent.chunk_cells)
            agent.SAtochunk_synapses(agent.SAtochunk_synapses < 0.000000001) = 0;
            %end
            %
            assert(all(isfinite(agent.chunktoSA_synapses(:))))
            nan_check = true;
            agent.chunktoSA_synapses = normalise(agent.chunktoSA_synapses', params.chunk_threshold, nan_check);
            agent.chunktoSA_synapses = agent.chunktoSA_synapses';
            assert(all(isfinite(agent.chunktoSA_synapses(:))))
        case false
        otherwise, error('Switch Error')
    end
    
end

end