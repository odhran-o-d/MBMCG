function idx = xy_sensory2ind(sensory_cells, world)

assert(numel(sensory_cells) == world.worldSize_x + world.worldSize_y)

idx = sub2ind([world.worldSize_x world.worldSize_y], ...
                find(sensory_cells(world.worldSize_x+1:end)), ...
                find(sensory_cells(1:world.worldSize_x)));
            
end