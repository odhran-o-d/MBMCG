function weights = weightUpdate(weights, presynaptic_cells, postsynaptic_cells, learningRate)

weights = weights + (learningRate * presynaptic_cells(:) * postsynaptic_cells(:)');

end