function parameterGraph(param1, param1_name, param1_bounds, param2, param2_name, param2_bounds, obj_fun, obj_bounds, resolution)

% Create Boundaries
if isequal(param1_bounds, [])
    param1_bounds = [min(param1) max(param1)];
end

if isequal(param2_bounds, [])
    param2_bounds = [min(param2) max(param2)];
end

% NaN Check
idx = isnan(param1); if any(idx), param1(idx) = []; param2(idx) = []; obj_fun(idx) = []; end
idx = isnan(param2); if any(idx), param1(idx) = []; param2(idx) = []; obj_fun(idx) = []; end
idx = isnan(obj_fun); if any(idx), param1(idx) = []; param2(idx) = []; obj_fun(idx) = []; end

%Plot
x = param1; y = param2; z = obj_fun;

unique_xy = unique([x y], 'rows');
all_vals = [x y z];
for i = 1:size(unique_xy, 1)
max_vals(i,:) = max(all_vals(ismember(all_vals(:,1:2), unique_xy(i,:), 'rows'),:));
end

unique_x = max_vals(:,1); unique_y = max_vals(:,2); max_z = max_vals(:,3);

%[xq, yq] = meshgrid(param1_bounds(1):resolution:param1_bounds(2), param2_bounds(1):resolution:param2_bounds(2));
[xq, yq] = meshgrid(linspace(param1_bounds(1), param1_bounds(2), resolution), linspace(param2_bounds(1),param2_bounds(2), resolution));
vq = griddata(unique_x, unique_y, max_z, xq, yq);
%figure(); mesh(xq, yq, vq);

% Mesh graph
figure(); mesh(xq, yq, vq); xlim(param1_bounds); ylim(param2_bounds); zlim(obj_bounds);
xlabel(param1_name); ylabel(param2_name); zlabel('objective function');

% Heatmap graph
figure(); imagesc(vq); 
tks = get(gca, 'XTick'); xticks([0 tks]); xticklabels(round(linspace(param1_bounds(1), param1_bounds(2), 11), 2,'significant'));
tks = get(gca, 'YTick'); yticks([0 tks]); yticklabels(round(linspace(param2_bounds(1), param2_bounds(2), 11), 2,'significant'));
xlabel(param1_name); ylabel(param2_name);
colorbar

end