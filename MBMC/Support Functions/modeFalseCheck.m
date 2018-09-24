function modeFalseCheck(modeName, mode, suppress)

if suppress
    return
end

if mode == false
if ~isequal(input([modeName ' mode inactive. Continue? Y/N: '], 's'),'Y')
        error('Bad Mode')
end
end
end