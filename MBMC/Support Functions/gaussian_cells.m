function normalised_cells = gaussian_cells(layer_size, decimal_mean, deviation)

% Takes a percentage value (between 0 and 1) and adds it to a layer of
% cells as a gaussian activation.

cells = zeros(1, layer_size);
normal = round( normrnd( decimal_mean*size(cells,2), deviation*size(cells,2), 1, 100*layer_size ));
normal( normal > layer_size ) = 0;

for i = 1:layer_size
    cells(i) = sum(normal == i);
end

normalised_cells = cells/norm(cells,1);

end