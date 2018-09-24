function ratioMat = chunkTrials(agent, world, use_chunks)

all_stepsMat = [];
all_processingMat = [];
all_ratioMat = [];
    
    [results, ~, ~, switches] = MBMC_master('HardwiredHierarchy', {use_chunks}, agent, world);

    if numel(results.stepsMat) < 1 || numel(results.processingMat) < 1
        error('No tracking info being returned.')
    end
    
    all_stepsMat = [all_stepsMat results.stepsMat];
    all_processingMat = [all_processingMat results.processingMat];

ratioMat = [all_stepsMat' all_processingMat'];

end