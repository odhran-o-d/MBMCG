function [output] = SAcoverage_dakota(experiment, params,results)

%--------------------------------------------------------------
% Set any fixed/default values needed for your analysis .m code
%--------------------------------------------------------------


%------------------------------------------------------------------
% READ params.in (or params.in.num) from DAKOTA and set Matlab variables
%
% read params.in (no aprepro) -- just one param per line
% continuous design, then U.C. vars
% --> 1st cell of C has values, 2nd cell labels
% --> variables are in rows 2-->?
%------------------------------------------------------------------

dakota = dakotaRead(params);

%------------------------------------------------------------------
% CALL your analysis code to get the function value
%------------------------------------------------------------------

%[f] = rosenbrock(x,alpha);
ChunkPath();
[sim_results, agent, world] = MBMC_master(experiment, dakota, [], []);
out = numel(unique(agent.SA_decoded(:, 3)));
disp(out)
out = -out;

%------------------------------------------------------------------
% WRITE results.out
%------------------------------------------------------------------
dakotaWrite(results, out);

end