% Coordinates in (angle, amount). Need converting into cartesian coords to
% use compass plot
[x,y] = pol2cart(deg2rad([0 90 180 270]), [0.2 1 1 0.2]);

% Compass plot
compass(x,y)

% still don't know how this worka
figure(); quiver([0], [0], [1], [1]); xlim([0 10]); ylim([0 10])