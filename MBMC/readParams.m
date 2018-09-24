function switches = readParams(file, switches, dakota)

params = readParamFile(file);

num_params = size(params{1}, 1);

if ~(numel(params{1}) == numel(unique(params{1}))) % Check that all parameters are unique
    findRepeatParam(file);
    error('Repeated parameter definitions in experiment file.');
end

for i = 1:num_params
    
    try
        % process variable fields
        fld = sscanf(params{1}{i}, '%s');
        fld = strsplit(fld,'.');
        fld(strcmp(fld, 'switches')) = [];
        
        % process variable value
        val = params{2}{i};
        val(val == ';') = [];
        switch val
            case 'true'
                val = true;
            case 'false'
                val = false;
            otherwise
                if contains(val, 'dakota')
                    if isequal(dakota, {}), error('Dakota Values Requested But Not Supplied')
                    elseif contains(val, '(')
                        error('Dakota Values Must Be In Cell Array')
                    end
                    val = strsplit(val,'{');
                    val = val{2}; % discard the open bracket and everything before
                    val = regexprep(val, "}", ""); % discard closing bracket
                    val = str2double(val);
                    val = dakota{val};
                    
                elseif any(ismember(val, '['))
                    val(val == ':') = ';'
                    val = str2num(val);
                    
                elseif all(ismember(val, '0123456789+-.eEdD^'))
                    if any(ismember(val, '^')) % deal with powers
                        val = strsplit(val,'^');
                        assert(numel(val) == 2)
                        val = str2double(val{1})^str2double(val{2});
                    else
                        val = str2double(val);
                    end
                    if isnan(val); error('Failed Numerical Conversion'); end
                else
                    val = regexprep(val, "'", ""); % remove quotes from string
                end
        end
        
        % assign
        fld_num = size(fld,2);
        switch fld_num
            case 1
                if ~isfield(switches, fld{1}); error('Invalid Field Name: %s', fld{1}); end
                switches.(fld{1}) = val;
            case 2
                if ~isfield(switches.(fld{1}), fld{2}); error('Invalid Field Name: %s.%s', fld{1}, fld{2}); end
                switches.(fld{1}).(fld{2}) = val;
            case 3
                if ~isfield(switches.(fld{1}).(fld{2}), fld{3}); error('Invalid Field Name: %s.%s.%s', fld{1}, fld{2}, fld{3}); end
                switches.(fld{1}).(fld{2}).(fld{3}) = val;
            otherwise
                error('Too many fields in parameter name')
        end
        
    catch err
        
        disp(fld)
        disp(val)
        error(err.message)
    end
end


end