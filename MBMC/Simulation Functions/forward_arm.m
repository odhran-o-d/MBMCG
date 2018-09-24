function [j1_pos_x, j1_pos_y, j2_pos_x, j2_pos_y] = forward_arm(j1_angle, j2_angle)

% Parameters of linkage lengths.
link1 = 2;
link2 = 3;

% Calculate positions of each joint based on the given angles.
j1_pos_x = cos(j1_angle*pi/180)*link1;
j1_pos_y = sin(j1_angle*pi/180)*link1;

j2_pos_x = cos((j2_angle+j1_angle)*pi/180)*link2+j1_pos_x;
j2_pos_y = sin((j2_angle+j1_angle)*pi/180)*link2+j1_pos_y;

end