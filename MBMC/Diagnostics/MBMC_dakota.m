function [output] = MBMC_dakota(params,results)

%--------------------------------------------------------------
% Set any fixed/default values needed for your analysis .m code
%--------------------------------------------------------------

%{
addpath('~/Documents/Repos/projectcalvin/Walls')
switch dakotaMode
    case 'E10'
        addpath('~/Documents/Repos/projectcalvin/Support Functions')
        addpath('~/Documents/Repos/projectcalvin/13_Thesis')
        addpath('~/Documents/Repos/projectcalvin/Diagnostics')
    case 'E62'
        addpath('~/Documents/Repos/projectcalvin/Support Functions')
        addpath('~/Documents/Repos/projectcalvin/13_Thesis')
        addpath('~/Documents/Repos/projectcalvin/Diagnostics')
    case 'FGM'
        addpath('~/Documents/Repos/projectcalvin/13_Thesis/Final Gradient Model/Support Functions')
        addpath('~/Documents/Repos/projectcalvin/13_Thesis/Final Gradient Model/')
        addpath('~/Documents/Repos/projectcalvin/13_Thesis/Final Gradient Model/Diagnostics')
    case 'E61'
        addpath('~/Documents/Repos/projectcalvin/Support Functions')
        addpath('~/Documents/Repos/projectcalvin/13_Thesis')
        addpath('~/Documents/Repos/projectcalvin/Diagnostics')
    otherwise
        error('Invalid Experiment Specified by Dakota')
end
%}

%------------------------------------------------------------------
% READ params.in (or params.in.num) from DAKOTA and set Matlab variables
%
% read params.in (no aprepro) -- just one param per line
% continuous design, then U.C. vars
% --> 1st cell of C has values, 2nd cell labels
% --> variables are in rows 2-->?
%------------------------------------------------------------------

fid = fopen(params,'r');
C = textscan(fid,'%n%s');
fclose(fid);

num_vars = C{1}(1);
disp(num_vars)


% set design variables -- could use vector notation
% rosenbrock x1, x2

for i = 1:num_vars
    x(i) = C{1}(i+1);
end

disp(datetime)
disp(x)
dakota = x;

%------------------------------------------------------------------
% CALL your analysis code to get the function value
%------------------------------------------------------------------

%[f] = rosenbrock(x,alpha);
ChunkPath();
[total_steps, totalProcessing, agent, walls] = MBMC_master(dakota);
out = [];

%------------------------------------------------------------------
% WRITE results.out
%------------------------------------------------------------------
fprintf('%20.10e     f\n', out);
fid = fopen(results,'w');
fprintf(fid,'%20.10e     f\n', out);
%fprintf(fid,'%20.10e     params\n', C{1}(2:5));

fclose(fid);

end