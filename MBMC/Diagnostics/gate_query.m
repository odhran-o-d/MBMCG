function tmp = gate_query(gate_decoded, field, value)

switch field
    case 'state'
        fieldVar = 1;
    case 'action'
        fieldVar = 2;
    case 'SA'
        fieldVar = 3;
    case 'gate'
        fieldVar = 4;
    otherwise
        error('Invalid field')
end
        tmp = gate_decoded(gate_decoded(:, fieldVar) == value, :);
end