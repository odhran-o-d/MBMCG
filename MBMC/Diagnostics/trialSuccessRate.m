function [output] = trialSuccessRate(params,results)

dakota = dakotaRead(params);
experiment = 'GridWorldsNoise';
%------------------------------------------------------------------
% CALL your analysis code to get the function value
%------------------------------------------------------------------

%[f] = rosenbrock(x,alpha);
ChunkPath_dakota();
load ../../tmp.mat agent world
[trial_results, ~, ~, switches] = MBMC_master(experiment, dakota, agent, world);

out = trialsAnalyse(trial_results.resultMat, 'resultMat', false);
disp(out)
out = out(1); % percentage success only

%------------------------------------------------------------------
% WRITE results.out
%------------------------------------------------------------------

dakotaWrite(results, out);

end