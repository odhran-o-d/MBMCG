#!/bin/csh -f
# Sample simulator to Dakota system call script -- Matlab example
# See User Manual for instructions
#
# bvbw 10/24/01
# Brian M. Adams, 11/17/2005; 5/11/2009

# $argv[1] is params.in.(fn_eval_num) FROM Dakota
# $argv[2] is results.out.(fn_eval_num) returned to Dakota


# Assuming Matlab .m files and any necessary data are in ./
# from which DAKOTA is run

# NOTE: The workdir.* could be eliminated since the matlab wrapper
# accepts parameters file names as input, but is included for example

# ------------------------
# Set up working directory
# ------------------------

# you could simplify this and keep all files in your main directory
# if you are only running one simulation at a time.

# strip function evaluation number for making working directory

echo 'starting shell'
set num = `echo $argv[1] | cut -c 11-`

mkdir workdir

# copy parameters file from DAKOTA into working directory
cp $argv[1] workdir/params.in

# copy any necessary .m files and data files into workdir
echo 'Copying data to workdir'
rsync --exclude="*.mat" ../* workdir/
cp -a ../MBMC_master.m ../setDefaultSwitches.m ../ChunkPath.m ../createAgent.m ../activateChunkCells.m ../ChunkController.m ../ChunkLearner.m ../ChunkMaze_World.m workdir/
#cp -R ../Diagnostics ../"Simulation Functions" ../"Support Functions" workdir/
rsync -a ../Diagnostics ../Experiments ../"Simulation Functions" ../"Support Functions" workdir/ --exclude workdir/ # performs a similar function to "cp" but excludes workdir, preventing recursive loop

# ------------------------------------
# RUN the simulation from workdir.num
# ------------------------------------
# launch Matlab with command mode (-r)
# matlab_rosen_wrapper.m will call the actual analysis file
# rosenbrock.m

alias matlab='/Applications/MATLAB_R2017b.app/bin/matlab'
cd workdir

echo matlab -nojvm -nodesktop -nodisplay -nosplash -r "SAinfo_dakota('params.in', 'results.out'); exit"

matlab -nojvm -nodesktop -nodisplay -nosplash -r "ChunkPath(); SAinfo_dakota('params.in', 'results.out'); exit"

# Note that you can put other matlab commands in the argument to -r, e.g., 
# problem setup commands:
# -r "x=2; y=sin(x); matlab_rosen_wrapper(x,y); exit;"

# *** --> The 'exit' command is crucial so Matlab will exit after running
#         the analysis!


# -------------------------------
# write results.out.X and cleanup
# -------------------------------
mv results.out ../$argv[2] 

cd ..
\rm -rf workdir


