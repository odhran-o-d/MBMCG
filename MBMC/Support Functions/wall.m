
% top
while top_thick > 0
    internal_synapses(:,top_thick:rows:col*rows) = NaN;
    top_thick = top_thick - 1;
end

% bottom
while bottom_thick > 0
    internal_synapses(:,rows-bottom_thick+1:rows:rows*col) = NaN;
    bottom_thick = bottom_thick - 1;
end

% left
internal_synapses(:,1:rows*left_thick) = NaN;

% right
internal_synapses(:, rows*(col-right_thick)+1:rows*col) = NaN;