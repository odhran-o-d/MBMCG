function [sensory_cells, reward_cells, intended_state, world] = arm_update(agent, world, action, calculate_sensory, switches)

% 2-link arm with 2 DOF.
% ==@==@

arm = world.arm;

%% Convert action to joint angles.

size_action = 20;
switch action
    case 'j1_inc'
        arm.j1_angle = arm.j1_angle + size_action;
    case 'j1_dec'
        arm.j1_angle = arm.j1_angle - size_action;
    case 'j2_inc'
        arm.j2_angle = arm.j2_angle + size_action;
    case 'j2_dec'
        arm.j2_angle = arm.j2_angle - size_action;
    case 'j1_inc_j2_inc'
        arm.j1_angle = arm.j1_angle + size_action;
        arm.j2_angle = arm.j2_angle + size_action;
    case 'j1_inc_j2_dec'
        arm.j1_angle = arm.j1_angle + size_action;
        arm.j2_angle = arm.j2_angle - size_action;
    case 'j1_dec_j2_inc'
        arm.j1_angle = arm.j1_angle - size_action;
        arm.j2_angle = arm.j2_angle + size_action;
    case 'j1_dec_j2_dec'
        arm.j1_angle = arm.j1_angle - size_action;
        arm.j2_angle = arm.j2_angle - size_action;
end

%% Calculate position of middle joint and end joint (end-effector)
[arm.j1_pos_x, arm.j1_pos_y, arm.j2_pos_x, arm.j2_pos_y] = forward_arm(arm.j1_angle, arm.j2_angle);

%% Produce distributed sensory representation
gauss_deviation = 0.005; %0.01;

if strcmp(calculate_sensory,'yes') == 1
    
    position_cells = position_gauss(arm.j2_pos_x, arm.j2_pos_y, gauss_deviation);
    angle_cells = angles_gauss(arm.j1_angle, arm.j2_angle, gauss_deviation);
    
    % WTA
    position_cells{1} = WTA_Competition(position_cells{1});
    position_cells{2} = WTA_Competition(position_cells{2});
    angle_cells{1} = WTA_Competition(angle_cells{1});
    angle_cells{2} = WTA_Competition(angle_cells{2});
    
    sensory_cells = [position_cells{1}, position_cells{2}, angle_cells{1}, angle_cells{2}];
    
else
    
    sensory_cells = [];
    
end


reward_pos = position_gauss(world.reward_x, world.reward_y, gauss_deviation); % Takes in reward coordinators and converts those to position_cell representations.
reward_pos{1} = WTA_Competition(reward_pos{1}); reward_pos{2} = WTA_Competition(reward_pos{2});
num_reward_blank = [1 numel(cell2mat(angles_gauss(0, 0, 0)))];
reward_cells = [reward_pos{:}, zeros(num_reward_blank)];

world.arm = arm;

intended_state = [];

%% Show figure
%figure(); axes('XLim', [-5 5], 'YLim', [-5 5]); line([0, j1_pos_x], [0, j1_pos_y]); line([j1_pos_x, j2_pos_x], [j1_pos_y, j2_pos_y]);
%{
j0_rectangle = annotation('rectangle');
set(j0_rectangle, 'parent', gca)
set(j0_rectangle, 'position', [0-0.5 0-0.1 1 0.2])

%j1_ellipse = annotation('ellipse');
%set(j1_ellipse, 'parent', gca)
%set(j1_ellipse, 'position', [j1_pos_x-0.1 j1_pos_y-0.1 0.2 0.2])

j2_ellipse = annotation('ellipse');
set(j2_ellipse, 'parent', gca)
set(j2_ellipse, 'position', [j2_pos_x-0.1 j2_pos_y-0.1 0.2 0.2])
%}


    function [position_cells] = position_gauss(j2_pos_x, j2_pos_y, gauss_deviation)
        
        %Gives position of manipulator as a set to sensory 'position cells'
        
        %% Parameters
        
        learningRate = 9000;
        round_value = 0.25;
        norm_threshold = 1;
        num_positioncells = 100; %200;
        
        %% Activate Sensory Representations
        
        % Position is on a scale of -5 to +5.
        % Position converted to scale of 0 to 1.
        
        % Make positive
        j2_pos_x = j2_pos_x + 5;
        
        % Divide by 10.
        j2_pos_x = j2_pos_x / 10;
        
        % Produce gaussian layer
        jpx_cells = gaussian_cells(num_positioncells, j2_pos_x, gauss_deviation);
        
        j2_pos_y = j2_pos_y + 5;
        j2_pos_y = j2_pos_y / 10;
        jpy_cells = gaussian_cells(num_positioncells, j2_pos_y, gauss_deviation);
        
        %{
%% No NaN Synapses
noNaNj1 = noNaN(jpx_synapses);
noNaNj2 = noNaN(jpy_synapses);


%% Activate Combo Representations
combo_cells = dot([repmat(jpx_cells(:),[1,numel(combo_cells)]); repmat(jpy_cells(:),[1,numel(combo_cells)])], [noNaNj1; noNaNj2]);

combo_cells = WTA_Competition(combo_cells);

%% Learn Synapses
jpx_synapses = jpx_synapses + (learningRate * jpx_cells(:) * combo_cells(:)');
jpy_synapses = jpy_synapses + (learningRate * jpy_cells(:) * combo_cells(:)');

%% Normalise Synapses
jpx_synapses = normalise(jpx_synapses, norm_threshold);
jpy_synapses = normalise(jpy_synapses, norm_threshold);
        %}
        
        %% Package Synapses
        position_cells = {jpx_cells, jpy_cells};
    end



    function [angle_cells] = angles_gauss(j1_angle, j2_angle, gauss_deviation)
        
        %Turns angle signal into a gaussian activation on a layer of cells. Size of
        %layer and standard deviation can be altered.
        
        %% Parameters
        
        learningRate = 9000;
        round_value = 20;
        norm_threshold = 1;
        num_anglecells = 100; %200;
        
        
        %% Activate Sensory Representations
        
        % Scale to within 360 degrees.
        j1_angle = mod(j1_angle, 360);
        
        % Convert to scale of 0 to 1.
        j1_angle = j1_angle/360;
        
        % Create gaussian cell layer
        ja1_cells = gaussian_cells(num_anglecells, j1_angle, gauss_deviation);
        
        
        j2_angle = mod(j2_angle, 360);
        j2_angle = j2_angle/360;
        ja2_cells = gaussian_cells(num_anglecells, j2_angle, gauss_deviation);
        
        %% Package Cells
        angle_cells = {ja1_cells, ja2_cells};
    end

end