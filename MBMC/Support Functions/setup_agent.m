function [ recursive_weights, sensory_weights, motor_weights, reward_weights  ] = setup_agent( comp_size )
% Creates the weights of the sensory, motor, competitive, reward networks
%   Detailed explanation goes here

% set up comp--comp connections

recursive_weights = GenerateWeights(comp_size,comp_size,0);

% set up sensory--motor connections

sensory_weights = GenerateWeights(comp_size,(10*10),0.2);

% set up comp--motor connections (activated by dilute comp)

motor_weights = GenerateWeights(comp_size,8*10,0.1);

% set up reward--comp connections

reward_weights = zeros(comp_size,1,1);

end

