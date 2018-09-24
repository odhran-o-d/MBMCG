function agent = deterministicSA(agent, SA_reward, switches)

control_sw = switches.control_sw;
params = switches.params;

if switches.main.propagation_noise == true
    if control_sw.use_chunks == true
        agent.SA_cells = noisePropagate(params.propagation_noise, agent.SA_cells, SA_reward, agent.SA_cells, agent.chunk_cells, agent.SArewardtoSA_synapses, agent.SAtoSA_synapses, agent.chunktoSA_synapses);
    else
        agent.SA_cells = noisePropagate(params.propagation_noise, agent.SA_cells, SA_reward, agent.SA_cells, [], agent.SArewardtoSA_synapses, agent.SAtoSA_synapses, []);
    end
    agent.SA_cells = reshape(agent.SA_cells, agent.num_SA);
else
    if control_sw.use_chunks == true
        agent.SA_cells = cellPropagate(agent.SA_cells, SA_reward, agent.SA_cells, agent.chunk_cells, agent.SArewardtoSA_synapses, agent.SAtoSA_synapses, agent.chunktoSA_synapses);
    else
        agent.SA_cells = cellPropagate(agent.SA_cells, SA_reward, agent.SA_cells, [], agent.SArewardtoSA_synapses, agent.SAtoSA_synapses, []);
    end
    agent.SA_cells = reshape(agent.SA_cells, agent.num_SA);
end
end