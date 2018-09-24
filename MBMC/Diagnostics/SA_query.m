function tmp = SA_query(SA_decoded, field, value)
switch field
    case 'state'
        var = 1;
    case 'action'
        var = 2;
    case 'cell'
        var = 3;
    otherwise
        error('Invalid field')
end
tmp = SA_decoded(SA_decoded(:,var) == value, :);