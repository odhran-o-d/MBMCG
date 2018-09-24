function sorted_mat = valueSort(matrix)

[row, col] = find(isnan(matrix));
if ~isempty(row) || ~isempty(col)
    matrix(row,:) = [];
end

uq_val = unique(matrix(:,1));
sorted_mat = zeros(numel(uq_val), 3);
for i = 1:numel(uq_val)
    [idx, ~] = find(matrix(:, 1) == uq_val(i));
    sorted_mat(i, :) = [uq_val(i) mean(matrix(idx,2)) numel(idx)];
end