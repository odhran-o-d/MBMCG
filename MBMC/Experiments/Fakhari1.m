function Fakhari1()

% 9 blocks, with 20 trials

for block = 1:9
    
    for trial = 1:20
        
        % View grid world. Random starting point. Random goal.
        
        % One cell (21) has deterministic punishment: if you enter then you
        % lose -45
        
        % Two cells (15, 16) have stochastic punishments. 
        % 15: 80% -75, 20% - 1 (standard) 
        % 16: 80% -3, 20% - 1 (standard)
        % I.e. 80% chance of extra punishment beyond the standard regular
        
        
        % 30000D3   % XX 05 09 13 17 21 XX
        % 3030303   % XX 06 XX XX XX 22 XX
        % 000S000   % 03 07 11 15 19 23 27
        % 300S033   % XX 08 12 16 20 XX XX
        
        % Cannot move between 11 and 12 or 15 and 16. 
        
    end
    
end


end