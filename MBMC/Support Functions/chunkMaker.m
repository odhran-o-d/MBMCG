function SA = chunkMaker(pos, act, SA_decoded)

%% Given a vector of positions and actions
%pos = [45, 55, 65, 75, 85];
%act = [8, 8, 8, 8, 8];

%% Give back the appropriate SA cells
for i = 1:size(pos,2)
SAcol = SA_decoded(SA_decoded(:,1) == pos(i), :);
SA{i} = SAcol(SAcol(:, 2) == act(i), 3);
end

end