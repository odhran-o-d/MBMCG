for i = 1:size(chunks,2)
    agent.SAtochunk_synapses(chunks{i}{end}, i+8) = 1;
    agent.chunktoSA_synapses(i+8, [chunks{i}{:}]) = 1;
end