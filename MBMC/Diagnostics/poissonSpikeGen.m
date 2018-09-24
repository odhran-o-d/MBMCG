function [spikeMat, tVec] = poissonSpikeGen(fr, dt, tSim, nTrials)

% produces spike matrix "spikeMat" and vector "tVec" containing timestamps
% of each spike

% fr = firing rate in Hz
% tSim = length of simulation (in s?)
% nTrials = number of simulations

nBins = floor(tSim/dt);
spikeMat = rand(nTrials, nBins) < fr*dt;
tVec = 0:dt:tSim-dt;