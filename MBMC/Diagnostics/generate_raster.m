function tmp_mat = generate_raster(firing, cell, onset_timestep)

% firing is activation value between 0 and 1

spikeMat = [];
tVec = [];
tSim = 0.5; % length of simulated time for each timestep
generated_trains = 20;
dt = 1/1000; % slicing of time in seconds

mapped_firing = remap(firing(:, cell), [0 1], [2 50]);

%% Generate Spike Trains

for i = 1:length(mapped_firing)
[spikeMat_tmp, tVec_tmp] = poissonSpikeGen(mapped_firing(i), dt, tSim, generated_trains);
tVec_tmp = tVec_tmp;
%tVec_tmp = (tVec_tmp - tVec_tmp(end))*1000 - 1;
if any(tVec)
tVec_tmp = tVec_tmp + tVec(end);
end

spikeMat = [spikeMat spikeMat_tmp];
tVec = [tVec tVec_tmp];

end

spikeMat = logical(spikeMat);

%% Generate Histogram Data
binWidth = 40/1000; % bin width in seconds
binInd = binWidth / dt;
spikeBin = [];
% bin spike data
i = 1;
while i*binInd < size(spikeMat, 2)
    spikeBin(i) = sum(sum(spikeMat(:, ((i-1)*binInd) + 1 : i*binInd)));
    i = i + 1;
end

tBin = 0.5*binWidth : binWidth : (i-1)*binWidth;

%% plot the raster and mark stimulus onset
onset = onset_timestep * tSim ;
plotRaster(spikeMat, tVec, spikeBin, tBin, onset);

end

%{
tmp_mat = zeros(size(firing, 1) * 1000, 1);
for i = 1:size(firing, 1)
    tmp_mat(1000*(i-1)+1:1000*i) = poissrnd(firing(i, cell), 1, 1000);
end
    figure(); plot(tmp_mat);
end
%}