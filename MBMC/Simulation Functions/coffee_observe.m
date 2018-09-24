function sensory_vector = coffee_observe(sensory_cells)

assert(numel(sensory_cells.sugar) == 2);
assert(numel(sensory_cells.coffee) == 2);
assert(numel(sensory_cells.mug) == 7);
assert(numel(sensory_cells.milk) == 2);
assert(numel(sensory_cells.hand) == 5);

sensory_vector = horzcat(sensory_cells.sugar, ...
    sensory_cells.coffee, ...
    sensory_cells.mug, ...
    sensory_cells.milk, ...
    sensory_cells.hand);

end