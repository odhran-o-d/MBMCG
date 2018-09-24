function agent = resetAgent(agent)

agent.chunk_cells(:) = 0;
agent.chunk_trace(:) = 0;
agent.motor_cells(:) = 0;
agent.SA_cells(:) = 0;
agent.SA_trace(:) = 0;
agent.sensory_cells(:) = 0;
agent.gate_cells(:) = 0;
end