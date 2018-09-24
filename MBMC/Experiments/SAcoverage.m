function coverage = SAcoverage()

trials = [10; 20; 30; 40; 50; 60; 70; 80; 90; 100; ...
    200; 300; 400; 500; 600; 700; 800; 900; 1000; ...
    2000; 2250; 2500; 2750; 3000; 3500; 4000; 4500; 5000];

coverage = zeros(numel(trials), 2);

for i = 1:numel(trials)
[~, agent, ~, switches] = MBMC_master(trials(i), [], []);
coverage(i,:) = [switches.learner_sw.steps, size(unique(agent.SA_decoded(:,3)), 1)];
end

end