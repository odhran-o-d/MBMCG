
function infoAnalysis()

layer = 1;
invarianceFileID = fopen(['firingRate.dat']);
% Read header
[networkDimensions, historyDimensions, neuronOffsets, headerSize] = loadHistoryHeader(invarianceFileID);
numEpochs = historyDimensions.numEpochs;
numRegions = length(networkDimensions);
num_transforms = historyDimensions.numTransforms
num_stimulus = historyDimensions.numObjects

regionActivity = regionHistory(invarianceFileID, historyDimensions, neuronOffsets, networkDimensions, layer+1, depth, numEpochs);

num_cells = networkDimensions(layer+1).dimension;

part1_fr = reshape(regionActivity(historyDimensions.numOutputsPrTransform, :, :, numEpochs, :, :),num_transforms, num_stimulus, num_cells, num_cells); %part1_fr(num_transforms, num_objects, cell_x, cell_y);


fclose(invarianceFileID);


%fileName = 'VNfrates_1d.dat';
%VNfrates_1d= load(fileName);
%num_stimulus = VNfrates_1d(1)
%num_transforms = VNfrates_1d(2)
%num_cells = sqrt(VNfrates_1d(3))

%settings
num_samples = 5;    %num samples from Max-Cells of each stimulus for multi-cell info. analysis
sampleMulti = 4*4;    %default is 1; this is to increase the sampling size to deal with larger layers.
nc_max = 15;%num_samples*num_stimulus;   % max ensemble size for multi-cell info. analysis
IRs_topC = zeros(num_samples*sampleMulti,num_stimulus);  %to store top (num_samples) of cell_no's for each object.


multi_cell_analysis = 0; %1 to run multi-cell info analysis


num_bins =  10;%num_transforms;   %can be adjusted
firingRates = zeros(num_stimulus, num_transforms, num_cells,num_cells);
for i=1:num_stimulus
    firingRates(i,:,:,:) = reshape(part1_fr(:,i,:,:),num_transforms,num_cells,num_cells);
end

binMatrix = zeros(num_cells, num_cells, num_stimulus, num_bins); %number of times when fr is classified into a specific bin within a specific objects's transformations
binMatrixTrans = zeros(num_cells, num_cells, num_stimulus, num_bins, num_transforms);  %TF table to show if a certain cell is classified into a certain bin at a certain transformation

sumPerBin = zeros(num_cells,num_cells,num_bins);
sumPerObj = num_transforms;
sumPerCell = num_transforms*num_stimulus;

IRs = zeros(num_cells,num_cells,num_stimulus);   %I(R,s) single cell information
pq_r = zeros(num_stimulus);  %prob(s') temporally used in the decoing process
Ps = 1/num_stimulus; %Prob(s) 

Iss2_Q_avg = zeros(nc_max); %average quantized info for n cells; I(s,s')
Iss2_P_avg = zeros(nc_max);% average smoothed info for n cells; I(s,s')

n=3;

disp('** Data loading **');
% Read file and bin the firing rates based on the number of transforms
for object = 1:num_stimulus;
    disp([num2str(object) '/' num2str(num_stimulus)]);
    for translation = 1:num_transforms;
        for cell_y = 1:num_cells;
            for cell_x = 1:num_cells;
                %n=n+1;
                %firingRates(object,translation,cell_x,cell_y) = VNfrates_1d(n);
                for bin=1:num_bins
                    if(bin<num_bins)
                        if ((bin-1)*(1/num_bins)<=firingRates(object,translation,cell_x,cell_y))&&(firingRates(object,translation,cell_x,cell_y)<(bin)*(1/num_bins))
                            binMatrix(cell_x,cell_y,object,bin)=binMatrix(cell_x,cell_y,object,bin)+1;
                            binMatrixTrans(cell_x,cell_y,object,bin,translation)=1;
                        end
                    else
                        if ((bin-1)*(1/num_bins)<=firingRates(object,translation,cell_x,cell_y))&&(firingRates(object,translation,cell_x,cell_y)<=(bin)*(1/num_bins))
                            binMatrix(cell_x,cell_y,object,bin)=binMatrix(cell_x,cell_y,object,bin)+1;
                            binMatrixTrans(cell_x,cell_y,object,bin,translation)=1;
                        end
                    end
                end
            end
        end
    end
end

disp('DONE');
disp(['** single-cell information analysis **']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% single-cell information analysis      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Loop through all cells to calculate single cell information
for cell_x=1:num_cells
    for cell_y=1:num_cells
        
        % For each cell, count the number of transforms per bin
        for bin=1:num_bins
            sumPerBin(cell_x,cell_y,bin)=sum(binMatrix(cell_x,cell_y,:,bin));
        end
        
        % Calculate the information for cell_x cell_y per stimulus
        for object=1:num_stimulus
            for bin=1:num_bins
                Pr = sumPerBin(cell_x,cell_y,bin)/sumPerCell;
                Prs = binMatrix(cell_x,cell_y,object,bin)/sumPerObj;
                if(Pr~=0&&Prs~=0)
                    IRs(cell_x,cell_y,object)=IRs(cell_x,cell_y,object)+(Prs*(log2(Prs/Pr)))*((bin-1)/(num_bins-1)); %could be added to weight the degree of firing rates.
                end
            end
        end
        
    end
end

% Order by information content, descending
IRs_tmp = sort(reshape(max(IRs,[],3),1,num_cells*num_cells), 'descend');%find max IRs for each 

fig = figure;
if(multi_cell_analysis == 1)
    subplot(2,2,1);
end

plot(IRs_tmp);
axis([0 num_cells*num_cells -0.1 log2(num_stimulus)+0.1]);



if(multi_cell_analysis == 0)
    dlmwrite([fileName num2str(num_samples*sampleMulti) '_IRs.csv'],IRs_tmp);
    saveas(fig,[fileName '_.png']);
    return;
end



disp('DONE');
disp(['** multiple-cell information analysis **']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% multiple-cell information analysis    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function decode()
        eps = 0.001;
        p_tot =0;
        p_max =0;
		best_s = 0;
        pq_r(1:num_stimulus) = Ps;
        for s2=1:num_stimulus %for each s2, estimate P(r|s2)P(s2)
              %start by writing P(s2) 
            for c = 1:nc;
                if(sd(c,s2)<eps)
                    if(ra(c,s)==ra(c,s2))
                        fact = 1;
                    else
                        fact = eps;
                    end
                else
                    fact = normpdf(ra(c,s),ra(c,s2),sd(c,s2));
                    if(fact<eps)
                        fact = eps;
                    end
                end
                
                
                pq_r(s2) = pq_r(s2) * fact;
            
            end
            p_tot = p_tot+ pq_r(s2);
                      
            noise_fact = 1. + eps * (rand() - 0.5);%to randomly choose one from multiple candidates 
            if (p_max < pq_r(s2) * noise_fact)
                p_max = pq_r(s2) * noise_fact;
                best_s = s2;
            end
        end
        
        if p_tot < eps
            pq_r(1:num_stimulus) = Ps; %if they all died, equal honor to all
            best_s = ceil(num_stimulus * rand());
        else
            pq_r(1:num_stimulus) = pq_r(1:num_stimulus)/ p_tot; % finally normalize to get P(s|r)  */
        end
        
    end

IRs_reshaped = [reshape([1:1:(num_cells*num_cells)],num_cells*num_cells,1) reshape(IRs,num_cells*num_cells,num_stimulus)]; %add index to represent cell_no
for obj=1:num_stimulus %sort the IRs table and build a table of cell_no according to the amount of single cell info.
    IRs_sorted = sortrows(IRs_reshaped,-(obj+1));
    IRs_topC(:,obj) = IRs_sorted(1:num_samples*sampleMulti);
end

IRs_topC_lined = reshape(IRs_topC(:,:),num_samples*sampleMulti*num_stimulus,1);


n_tot = num_stimulus * num_transforms;
%dp = 1 / n_tot;
dp = 1/num_stimulus;
for nc=1:nc_max
    
    disp([num2str(nc) '/' num2str(nc_max)]);
    
    niter = 100*(nc_max - nc + 1);
    Iss2_Q_avg(nc) = 0.;
    Iss2_P_avg(nc) = 0.;
    
    
    testAvgP = zeros(num_stimulus,num_stimulus);
    testAvgQ = zeros(num_stimulus,num_stimulus);
    
    for iter = 1:niter
        e = IRs_topC_lined(randperm(num_samples*sampleMulti*num_stimulus,nc)); %randomly pick nc number of cells which have max IRs
        e2(:).cell_x = mod(e(:)-1,num_cells)+1;
        e2(:).cell_y = floor((e(:)-1)/num_cells)+1;
        
        %reset probability tables and info values
        Iss2_Q = 0.;     %quantized raw info (< frequencies)
        Iss2_P = 0.;  %smoothed raw info (< probabilities)
        
        Pq = zeros(num_stimulus);%mean assigned probability P(s') (smoothed)
        Psq = zeros(num_stimulus,num_stimulus);%probability table P(s,s')
        
        Qq  = zeros(num_stimulus);%frequency of each predicted s Q(s') (extract the best)
        Qsq = zeros(num_stimulus,num_stimulus);%frequency table Q(s,s')
        
        ra = zeros(nc, num_stimulus);%(training set) averages
        %rc = zeros(nc, num_stimulus);%current response
        sd = zeros(nc, num_stimulus);%(training set) variances

        for ss=1:num_stimulus
            ra(:,ss) = reshape(mean(firingRates(ss,:,e(:))),1,nc);%get average firing rates of each cell when exposed to object s at other transforms
            sd(:,ss) = reshape(std(firingRates(ss,:,e(:))),1,nc);%get standard deviations of the fr at other transforms
        end

        
        for s=1:num_stimulus
%            for tt=1:num_transforms
%{
                for ss=1:num_stimulus
%                    rc(:,ss) = reshape(firingRates(ss,tt,e(:)),1,nc);%get currecnt firing rates for each cell when exposed to object s at transform of tt
                    %ra(:,ss) = reshape(mean(firingRates(ss,find([1:num_transforms]~=tt),e(:))),1,nc);%get average firing rates of each cell when exposed to object s at other transforms
                    ra(:,ss) = reshape(mean(firingRates(ss,:,e(:))),1,nc);%get average firing rates of each cell when exposed to object s at other transforms
                    %sd(:,ss) = reshape(std(firingRates(ss,find([1:num_transforms]~=tt),e(:))),1,nc);%get standard deviations of the fr at other transforms
                    sd(:,ss) = reshape(std(firingRates(ss,:,e(:))),1,nc);%get standard deviations of the fr at other transforms
                end
%}
                decode();

                %dp is P(rc(s,t)) = 1 / (num_stimulus * num_transforms)
                %P(s,s')= P(s'|rc(s,t)) * P(rc(s,t))
                
                Psq(s,:) = Psq(s,:)+dp*reshape(pq_r(1:num_stimulus),1,num_stimulus);%probability table
                Pq(:) = Pq(:) + dp * pq_r(:);%mean assigned probability
                Qsq(s,best_s) = Qsq(s,best_s)+dp;%frequency table P(s,s')
                Qq(best_s) = Qq(best_s) + dp;%frequency of each predicted s P(s')
                
%            end   
        end
        
        testAvgP = testAvgP + Psq/niter;
        testAvgQ = testAvgQ + Qsq/niter;
        
        %extract info values from frequencies and probabilities
        
        for s1 = 1:num_stimulus
            nb = 0;
			for s2 = 1:num_stimulus
				q1 = Qsq(s1,s2);
				p1 = Psq(s1,s2);
                
                %to calculate I with the best matching (not smoothed)
                if (q1 > eps)
                    Iss2_Q = Iss2_Q + q1 * log2(q1 / (Qq(s2) * Ps));
                    nb = nb + 1;
                end
                
                %to calculate I by probability (smoothed)
				if (p1 > eps)
                    Iss2_P = Iss2_P + p1 * log2(p1 / (Pq(s2) * Ps));
                end
            end
        end
        Iss2_Q_avg(nc) =Iss2_Q_avg(nc)+ Iss2_Q / niter;
        Iss2_P_avg(nc) =Iss2_P_avg(nc)+ Iss2_P / niter;
    end
    testAvgP
    testAvgQ
end

subplot(2,2,2);
plot([0:1:nc_max],[0 Iss2_Q_avg(1:nc_max)]);
axis([0 nc_max -0.1 log2(num_stimulus)+0.1]);

subplot(2,2,3);
plot([0:1:nc_max],[0 Iss2_P_avg(1:nc_max)]);
axis([0 nc_max -0.1 log2(num_stimulus)+0.1]);

uicontrol('Style','text','Position',[100 5 200 20],'String',['num_samples per stim: ' num2str(num_samples*sampleMulti)])

                                                                              
dlmwrite([fileName num2str(num_samples*sampleMulti) '_IRs.csv'],IRs_tmp);
dlmwrite([fileName num2str(num_samples*sampleMulti) '_Iss2Q.csv'],[[0:1:nc_max];[0 Iss2_Q_avg(1:nc_max)]]);
dlmwrite([fileName num2str(num_samples*sampleMulti) '_Iss2P.csv'],[[0:1:nc_max];[0 Iss2_P_avg(1:nc_max)]]);
saveas(fig,[fileName '_.png']);

disp('DONE');










    function [networkDimensions, historyDimensions, neuronOffsets, headerSize] = loadHistoryHeader(fileID)

        % Import global variables
        SOURCE_PLATFORM_USHORT = 'uint16';
        SOURCE_PLATFORM_USHORT_SIZE = 2;
        SOURCE_PLATFORM_FLOAT_SIZE = 4;

        % Seek to start of file
        frewind(fileID);

        % Read history dimensions & number of regions
        v = fread(fileID, 5, SOURCE_PLATFORM_USHORT);

        historyDimensions.numEpochs = v(1);
        historyDimensions.numObjects = v(2);
        historyDimensions.numTransforms = v(3);
        historyDimensions.numOutputsPrTransform = v(4);

        % Compound stream sizes
        historyDimensions.transformSize = historyDimensions.numOutputsPrTransform;
        historyDimensions.objectSize = historyDimensions.transformSize * historyDimensions.numTransforms;
        historyDimensions.epochSize = historyDimensions.objectSize * historyDimensions.numObjects;
        historyDimensions.streamSize = historyDimensions.epochSize * historyDimensions.numEpochs;

        % Preallocate struct array
        numRegions = v(5);
        networkDimensions(numRegions).dimension = [];
        networkDimensions(numRegions).depth = []; 
        neuronOffsets = cell(numRegions,1); % {1} is left empty because V1 is not included

        % Read dimensions
        for r=1:numRegions,
            dimension = fread(fileID, 1, SOURCE_PLATFORM_USHORT);
            depth = fread(fileID, 1, SOURCE_PLATFORM_USHORT);

            networkDimensions(r).dimension = dimension;
            networkDimensions(r).depth = depth;

            neuronOffsets{r}(dimension, dimension, depth).offset = [];
            neuronOffsets{r}(dimension, dimension, depth).nr = [];
        end

        % We compute the size of header just read
        headerSize = SOURCE_PLATFORM_USHORT_SIZE*(5 + 2 * numRegions);

        % Compute and store the offset of each neuron's datastream in the file, not V1
        offset = headerSize; 
        nrOfNeurons = 1;
        for r=2:numRegions,
            for d=1:networkDimensions(r).depth, % Region depth
                for row=1:networkDimensions(r).dimension, % Region row
                    for col=1:networkDimensions(r).dimension, % Region col

                        neuronOffsets{r}(row, col, d).offset = offset;
                        neuronOffsets{r}(row, col, d).nr = nrOfNeurons;

                        offset = offset + historyDimensions.streamSize * SOURCE_PLATFORM_FLOAT_SIZE;
                        nrOfNeurons = nrOfNeurons + 1;
                    end
                end
            end
        end
    end




    function [activity] = regionHistory(fileID, historyDimensions, neuronOffsets, networkDimensions, region, depth, maxEpoch)

        % Import global variables
        SOURCE_PLATFORM_FLOAT = 'float';

        % Validate input
        validateNeuron('regionHistory.m', networkDimensions, region, depth);

        % Process input
        if nargin < 7,
            maxEpoch = historyDimensions.numEpochs;
        else
            if maxEpoch < 1 || maxEpoch > historyDimensions.numEpochs,
                error([file ' error: epoch ' num2str(maxEpoch) ' does not exist'])
            end
        end

        dimension = networkDimensions(region).dimension;

        % When we are looking for full epoch history, we can get it all in one chunk
        if maxEpoch == historyDimensions.numEpochs,

            % Seek to offset of neuron region.(depth,1,1)'s data stream
            fseek(fileID, neuronOffsets{region}(1, 1, depth).offset, 'bof');

            % Read into buffer
            streamSize = dimension * dimension * maxEpoch * historyDimensions.epochSize;
            [buffer count] = fread(fileID, streamSize, SOURCE_PLATFORM_FLOAT);

            if count ~= streamSize,
                error(['Read ' num2str(count) ' bytes, ' num2str(streamSize) ' expected ']);
            end

            activity = reshape(buffer, [historyDimensions.numOutputsPrTransform historyDimensions.numTransforms historyDimensions.numObjects maxEpoch dimension dimension]);

            % Because file is saved in row major,
            % and reshape fills in buffer in column major,
            % we have to permute the last two dimensions (row,col)
            activity = permute(activity, [1 2 3 4 6 5]);
        else
            %When we are looking for partial epoch history, then we have to
            %seek betweene neurons, so we just use neuronHistory() routine

            activity = zeros(historyDimensions.numOutputsPrTransform, historyDimensions.numTransforms, historyDimensions.numObjects, maxEpoch, dimension, dimension);

            for row=1:dimension,
                for col=1:dimension,
                    activity(:, :, :, :, row, col) = neuronHistory(fileID, networkDimensions, historyDimensions, neuronOffsets, region, depth, row, col, maxEpoch);
                end
            end
        end
    end



    function validateNeuron(file, networkDimensions, region, depth, row, col)

        if nargin > 2 && (region < 1 || region > length(networkDimensions)),
            error([file ' error: region ' num2str(region) ' does not exist'])
        elseif nargin > 3 && (depth < 1 || depth > networkDimensions(region).depth),
            error([file ' error: depth ' num2str(depth) ' does not exist'])
        elseif nargin > 4 && (min(row) < 1 || max(row) > networkDimensions(region).dimension),
            error([file ' error: row ' num2str(row) ' does not exist'])
        elseif nargin > 5 && (min(col) < 1 || max(col) > networkDimensions(region).dimension),
            error([file ' error: col ' num2str(col) ' does not exist'])
        end
    end





end