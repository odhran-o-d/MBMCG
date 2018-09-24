function firing = activation_from_neighbours(postSynaptic_cells, synaptic_weights)

firing = zeros(1, numel(postSynaptic_cells));
rows = size(postSynaptic_cells,1);
col = size(postSynaptic_cells,2);

for postSynaptic_cell = 1:numel(postSynaptic_cells)
    
    w = postSynaptic_cell-rows; n = postSynaptic_cell-1; s = postSynaptic_cell+1; e = postSynaptic_cell+rows;
    nw = w-1; sw = w+1; ne = e-1; se = e+1;
    
    test = [n e s w nw ne se sw];
    idx = find(test <= 0);
    test(idx) = test(idx) + rows*col;
    idx = find(test > rows*col);
    test(idx) = test(idx) - rows*col;
    
    n = test(1); e = test(2); s = test(3); w = test(4); nw = test(5); ne = test(6); se = test(7); sw = test(8);
    
    n_weight = synaptic_weights(n, postSynaptic_cell); e_weight = synaptic_weights(e, postSynaptic_cell); s_weight = synaptic_weights(s, postSynaptic_cell); w_weight = synaptic_weights(w, postSynaptic_cell);
    nw_weight = synaptic_weights(nw, postSynaptic_cell); sw_weight = synaptic_weights(sw, postSynaptic_cell); ne_weight = synaptic_weights(ne, postSynaptic_cell); se_weight = synaptic_weights(se, postSynaptic_cell);
    
    activation = postSynaptic_cells(n)*n_weight + postSynaptic_cells(e)*e_weight + postSynaptic_cells(s)*s_weight + postSynaptic_cells(w)*w_weight + ...
        postSynaptic_cells(nw)*nw_weight + postSynaptic_cells(sw)*sw_weight + postSynaptic_cells(ne)*ne_weight + postSynaptic_cells(se)*se_weight;
    
    firing(postSynaptic_cell) = activation;
    
end

end