function modeCheck(modeName, mode, suppress)

if suppress
    return
end

if mode == true
if ~isequal(input(['In ' modeName ' mode. Continue? Y/N: '], 's'),'Y')
        error('Bad Mode')
end
end
end