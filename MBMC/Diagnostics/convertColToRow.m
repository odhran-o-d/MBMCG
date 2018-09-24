function row_index = convertColToRow(column_index, size)
% square only for now

matrix = zeros(size);
for i = 1:numel(matrix)
matrix(i) = i;
end

transposed_matrix = matrix';
row_index = transposed_matrix(column_index);
