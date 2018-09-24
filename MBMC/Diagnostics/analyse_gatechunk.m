function analyse_gatechunk(agent, display_index, chosen_cell)

% find out what gate cells are connected to what gatechunk cells, and what
% they encode
mapping_threshold = 0.002;

if ~exist('display_index','var');
    display_index = input('Do you want to see available cells? Y/N: ', 's');
end

idx = [];
indices = agent.gatechunktogate_synapses < mapping_threshold;
thresholded = agent.gatechunktogate_synapses;
thresholded(indices) = 0;
thresholded(isnan(thresholded)) = 0;

for cell = 1:size(agent.gatechunktogate_synapses,1);
    if any(thresholded(cell,:))
        idx = [idx cell];
    end
end

switch display_index
    case 'Y'
        disp(idx);
end

if ~exist('chosen_cell','var')
    chosen_cell = input('Enter the cell whose synapses you wish to view: ');
end

gate = find(agent.gatechunktogate_synapses(chosen_cell, :));

    for gate_i = gate
        
        disp(gate_query(agent.gate_decoded, 'gate', gate_i))
        
    end
   

end