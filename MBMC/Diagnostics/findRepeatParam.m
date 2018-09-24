function repeats = findRepeatParam(file)

params = readParamFile(file);

if size(params, 2) > 1
    params = params{1};
end

repeats = {};
params_unique = unique(params);

params = sort(params);
params_unique = sort(params_unique);

while ~isequal(numel(params), numel(params_unique))
for i = 1:numel(params)
    
    if i > numel(params_unique)
        disp(params{i})
        params(i) = [];
        repeats(end+1) = params(i);
        break
    end
    
    if ~isequal(params{i}, params_unique{i})

        disp(params{i})
        params(i) = [];
        repeats(end+1) = params(i);
        break
        
    end
    
end
end

end