% function y = normalise(matrix)
%
% % Normalise matrix so that each column's sum approaches 1. Ignores NaN.
%
% %get number of rows and columns in matrix
%
% [rows, columns] = size(matrix);
%
% % sum each column
% summed = nansum(matrix);
%     for column = 1:columns
%     %divide each row in that column by that sum
%         for row = 1:rows
%             matrix(row,column) = (matrix(row,column)/summed(column));
%         end
%     end
% y = matrix;
%{
function matrix = normalise(matrix, threshold)

if any(isnan(matrix(:)))
    
    [rows, columns] = size(matrix);
    
    % sum each column
    summed = nansum(matrix);
    for column = 1:columns
        %divide each row in that column by that sum
        for row = 1:rows
            matrix(row,column) = (matrix(row,column)/(1/threshold * summed(column)));
        end
    end
    y = matrix;
    
else

matrix = matrix ./ ( (1/threshold) * repmat( sum(matrix), size(matrix, 1), 1));

end
%}

function matrix = normalise(matrix, threshold, nan_check)

if nan_check == true
    
    if any(isnan(matrix(:))) || any(sum(matrix) == 0)
        
        [rows, columns] = size(matrix);
        
        % sum each column
        summed = nansum(matrix);
        for column = 1:columns
            if summed(column) == 0
                continue
            else
                %divide each row in that column by that sum
                for row = 1:rows
                    matrix(row,column) = (matrix(row,column)/(1/threshold * summed(column)));
                end
            end
        end
        return
    end
end

matrix = matrix ./ ( (1/threshold) * repmat( sum(matrix), size(matrix, 1), 1));

end