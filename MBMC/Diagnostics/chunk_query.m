function idx = chunk_query(agent, field, value)
switch field
    case 'chunk' % gives efferent SA cells (chunk output)
        idx = find(agent.chunktoSA_synapses(value,:));
    case 'SA' % gives afferent SA cells (chunk input) REMEMBER NOT ALL ARE AFFERENT
        idx = find(agent.SAtochunk_synapses(value, :));
    otherwise
        error('Invalid field')
end