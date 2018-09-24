function decoded = decode_representations(tracked, saved, switches)

for time = 1:size(tracked,2)
    decoded(time,:) = cell2mat(tracked{time}(:)');
end

if saved ~= []
    decoded = [decoded; saved];
end

decoded = unique(decoded,'rows');
switch switches.main.worldType
    case 'maze'
        decoded = sortrows(decoded, 3);
    case 'arm'
        decoded = sortrows(decoded, 6);
    case 'keypress'
        decoded = sortrows(decoded, 7);
    otherwise
        error('Invalid world type')
end

end