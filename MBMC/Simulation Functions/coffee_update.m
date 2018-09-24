function [sensory_cells, reward_cells, intended_state] = coffee_update(agent, world, action, calculate_sensory, switches)

global world

if hand_empty(world.hand)
    switch(action)
        case 'Pick Up Sugar'
            world.hand = 'sugar';
        case 'Pick Up Coffee'
            world.hand = 'coffee';
        case 'Pick Up Mug'
            world.hand = 'mug';
        case 'Pick Up Milk'
            world.hand = 'milk';
        otherwise
            fail = true;
            return;
    end
    
else
    switch(action)
        case 'Pick Up Sugar'
            fail = true;
        case 'Pick Up Coffee'
            fail = true;
        case 'Pick Up Mug'
            fail = true;
        case 'Pick Up Milk'
            fail = true;
        case 'Put Down'
            world.hand = 'empty';
        case 'Tear'
            switch held_object(hand)
                case 'sugar'
                    world.sugar = 'open';
                case 'coffee'
                    world.coffee = 'open';
                case 'milk'
                    world.milk = 'open';
                otherwise
                    fail = true;
            end
        case 'Pour'
            switch held_object(hand)
                case 'sugar'
                    if strcmp(world.sugar, 'open')
                        mug = add_mug(mug, 'sugar');
                    end
                case 'coffee'
                    if strcmp(world.coffee, 'open')
                        mug = add_mug(mug, 'coffee');
                    end
                case 'milk'
                    if strcmp(world.milk, 'open')
                        mug = add_mug(mug, 'milk');
                    end
                otherwise
                    fail = true;
            end
        case 'Drink'
            if strcmp(world.mug, 'mksg_coffee')
                world.success = true;
            else
                fail = true;
            end
    end
end

if calculate_sensory == true
    
    agent.sensory_cells.sugar = world.sugar;
    agent.sensory_cells.coffee = world.coffee;
    agent.sensory_cells.mug = world.mug;
    agent.sensory_cells.milk = world.milk;
    agent.sensory_cells.hand = world.hand;
    
end
end

function empty_bool = hand_empty(hand)


if hand == [1 0 0 0 0]
    empty_bool = true;
else
    empty_bool = false;
end
end

function object = held_object(hand)

assert(numel(sensory_cells.hand) == 5);
assert(sum(hand(:)) == 1);

object_int = find(hand)

switch object_int
    case 1
        object = 'empty';
    case 2
        object = 'sugar';
    case 3
        object = 'coffee';
    case 4
        object = 'mug';
    case 5
        object = 'milk';
    otherwise
        error()
end
end

function mug_str = mug_condition(mug)

mug_int = find(mug);

switch mug_int
    case 1
        mug_str = 'water';
    case 2
        mug_str = 'coffee';
    case 3
        mug_str = 'mk_coffee';
    case 4
        mug_str = 'sg_coffee';
    case 5
        mug_str = 'mksg_coffee';
    case 6
        mug_str = 'milk';
    case 7
        mug_str = 'sugar';
    otherwise
        error();
end
end

function mug = add_mug(mug, added)

switch mug
    case 'water'
        switch added
            case 'sugar'
                mug = 'sugar';
            case 'coffee'
                mug = 'coffee';
            case 'milk'
                mug = 'milk';
        end
    case 'coffee'
        switch added
            case 'sugar'
                mug = 'sg_coffee';
            case 'coffee'
                mug = 'coffee';
            case 'milk'
                mug = 'milk';
        end
    case 'mk_coffee'
        switch added
            case 'sugar'
                mug = 'mksg_coffee';
            case 'coffee'
                mug = 'coffee';
            case 'milk'
                mug = 'mk_coffee';
        end
    case 'sg_coffee'
        switch added
            case 'sugar'
                mug = 'sg_coffee';
            case 'coffee'
                mug = 'coffee';
            case 'milk'
                mug = 'mksg_coffee';
        end
    case 'mksg_coffee'
        switch added
            case 'sugar'
                mug = 'sg_coffee';
            case 'coffee'
                mug = 'coffee';
            case 'milk'
                mug = 'mk_coffee';
        end
    case 'milk'
        switch added
            case 'sugar'
                mug = 'sugar';
            case 'coffee'
                mug = 'mk_coffee';
            case 'milk'
                mug = 'milk';
        end
    case 'sugar'
        switch added
            case 'sugar'
                mug = 'sugar';
            case 'coffee'
                mug = 'sg_coffee';
            case 'milk'
                mug = 'mksg_coffee';
        end
end

end

function reset_coffee()
world.sugar = [0 1]; % [open, closed]
world.coffee = [0 1]; % [open, closed]
world.mug = [1 0 0 0 0 0 0]; % [water, coffee, milky coffee, sugary coffee, milky&sugar coffee, milk, sugar]
world.milk = [0 1]; % [open, closed]
world.hand = [1 0 0 0 0 0]; % [empty, sugar, coffee, mug, milk];
end