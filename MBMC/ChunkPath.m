project_root = fileparts(which(mfilename));
cd(project_root)
path(pathdef);
addpath(project_root)
addpath(fullfile(project_root, 'Support Functions'))
addpath(fullfile(project_root, 'Simulation Functions'))
addpath(fullfile(project_root, 'Diagnostics'))
addpath(fullfile(project_root, 'Experiments'))
addpath(fullfile(project_root, 'Walls'))
addpath(fullfile(project_root, 'Agents'))