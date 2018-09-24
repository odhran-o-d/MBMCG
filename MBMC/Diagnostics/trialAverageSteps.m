function [output] = trialAverageSteps(params,results)

dakota = dakotaRead(params);

%------------------------------------------------------------------
% CALL your analysis code to get the function value
%------------------------------------------------------------------

%[f] = rosenbrock(x,alpha);
ChunkPath();
load /Users/localharry/Documents/Repos/MBMC/tmp.mat agent world
[trial_results, ~, ~] = MBMC_master(dakota, agent, world);

if ~isfield(trial_results, 'stepsMat'), error('Function Did Not Output Step Matrix'), end

stepsMat = trial_results.stepsMat;
stepsMat(isnan(stepsMat)) = [];
out = mean(stepsMat);

disp(out)

%------------------------------------------------------------------
% WRITE results.out
%------------------------------------------------------------------

dakotaWrite(results, out);

end