function fig = armFigure(arm_info, reward_x, reward_y, toSave)

        j1_pos_x = arm_info{3};
        j1_pos_y = arm_info{4};
        j2_pos_x = arm_info{5};
        j2_pos_y = arm_info{6};

    % Record agent position
    fig = figure(); axes('XLim', [-5 5], 'YLim', [-5 5]); line([0, j1_pos_x], [0, j1_pos_y]); line([j1_pos_x, j2_pos_x], [j1_pos_y, j2_pos_y]);
    
    j0_rectangle = annotation('rectangle');
    set(j0_rectangle, 'parent', gca)
    set(j0_rectangle, 'position', [0-0.5 0-0.1 1 0.2])
    
    j1_ellipse = annotation('ellipse');
    set(j1_ellipse, 'parent', gca)
    set(j1_ellipse, 'position', [j1_pos_x-0.1 j1_pos_y-0.1 0.2 0.2])
    
    j2_ellipse = annotation('ellipse');
    set(j2_ellipse, 'parent', gca)
    set(j2_ellipse, 'position', [j2_pos_x-0.1 j2_pos_y-0.1 0.2 0.2])
    
    reward_ellipse = annotation('ellipse');
    set(reward_ellipse, 'parent', gca)
    set(reward_ellipse, 'position', [reward_x-0.1 reward_y-0.1 0.2 0.2])
    
    % save figure
    if toSave == true
    print(gcf, '-dpng', fullfile('/Network/Servers/mac0.cns.ox.ac.uk/Volumes/Data/Users/jordan/Documents/Simulations/Arm', sprintf('ArmExperiment6_%d', time)))
    end
    
    %close gcf
end