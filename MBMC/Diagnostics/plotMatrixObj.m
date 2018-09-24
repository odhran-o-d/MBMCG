function plotMatrixObj(parameterMat, labelCell, obj_fn, limMin, limMax, objLim)

% takes labels = {'label1', 'label2', etc.}
% takes parameters = [param1 param2 etc.]
% takes limMin = [min1 min2] limMax = [max1 max2]

plotmatrix(parameterMat, obj_fn, 'x');

axes = get(gca, 'UserData');

for i = 1:length(axes)
    
    xlabel(axes(i), labelCell(i))
    
    
    if exist('limMin', 'var') && exist('limMax', 'var')
        
        xlim(axes(i), [limMin(i) limMax(i)]);
        
    elseif exist('limMin', 'var')
        
        xlim(axes(i), [limMin(i) inf]);
        
    elseif exist('limMax', 'var')
        
        xlim(axes(i), [0 limMax(i)]);
        
    end
    
    ylim(objLim);
end

end