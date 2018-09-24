function IRs_tmp = analysis_singleCell(num_cells, num_stimulus, num_transforms, recallRates, timescalled, create_figures, save_figures)

% bins are discrete blocks within the range of firing rates.

% stimuli are objects. For me, these would be grip categories.

% transforms are transformations of those objects. For me, these would be
% the number of different visPatterns that have the same grip i.e. 3.

% P(r) is the probabiliy that a cell will fire. Calculated via dividing
% sumPerBin (number of transforms per bin for each cell) by sumPerCell (number of
% transforms * number of grips).

% P(s) is the probability that any given stimulus was shown (object for
% Eguchi)

% P(r|s) is the probability that r will occur after stimulus. This is calculated via dividing the binMatrix (number of times when the firing rate is classified into a specific
% bin) by the sumPerObj (represents the number of transforms).

% have altered program b/c I have only 1D layer of cells not 2D.

multi_cell_analysis = 0;

%% Declare variables

% get desired folder
global desiredFolder

num_bins = 10; % can be adjusted?
%firingRates = zeros(num_gripCategories, num_transforms, num_cells);
firingRates = reshape(recallRates, num_stimulus, num_transforms, num_cells);
num_samples = 5;    %num samples from Max-Cells of each stimulus for multi-cell info. analysis
sampleMulti = 4*4;    %default is 1; this is to increase the sampling size to deal with larger layers.
nc_max = 15;%num_samples*num_stimulus;   % max ensemble size for multi-cell info. analysis
IRs_topC = zeros(num_samples*sampleMulti,num_stimulus);  %to store top (num_samples) of cell_no's for each object.

binMatrix = zeros(num_cells, num_stimulus, num_bins); %number of times when fr is classified into a specific bin within a specific objects's transformations
binMatrixTrans = zeros(num_cells, num_stimulus, num_bins, num_transforms);  %TF table to show if a certain cell is classified into a certain bin at a certain transformation

sumPerBin = zeros(num_cells, num_bins);    % transforms per bin for each cell
sumPerGrip = num_transforms;                        % number of transforms for each grip
sumPerCell = num_transforms*num_stimulus;              % total (visual) inputs to a cell

IRs = zeros(num_cells,num_stimulus);   %I(R,s) single cell information i.e. the goal of this function
%pq_r = zeros(num_stimulus);  %prob(s') temporally used in the decoing process
% pq_r is not used in single cell analysis and has been commented out because it
% creates large matrices
Ps = 1/num_stimulus; %Prob(s)

Iss2_Q_avg = zeros(nc_max); %average quantized info for n cells; I(s,s')
Iss2_P_avg = zeros(nc_max);% average smoothed info for n cells; I(s,s')

n=3;

%disp('** Data loading **');
%% Read file and bin the firing rates based on the number of transforms
for stimulus = 1:num_stimulus
    %disp([num2str(grip) '/' num2str(num_gripCategories)]);
    for transform = 1:num_transforms
        for cell = 1:num_cells
            for bin=1:num_bins
                if(bin<num_bins)
                    if ((bin-1)*(1/num_bins)<=firingRates(stimulus,transform,cell))&&(firingRates(stimulus,transform,cell)<(bin)*(1/num_bins)) % have switched permutation and grip around
                        binMatrix(cell,stimulus,bin)=binMatrix(cell,stimulus,bin)+1;
                        binMatrixTrans(cell,stimulus,bin,transform)=1;
                    end
                else
                    if ((bin-1)*(1/num_bins)<=firingRates(stimulus,transform,cell))&&(firingRates(stimulus,transform,cell)<=(bin)*(1/num_bins))
                        binMatrix(cell,stimulus,bin)=binMatrix(cell,stimulus,bin)+1;
                        binMatrixTrans(cell,stimulus,bin,transform)=1;
                    end
                end
            end
        end
    end
end

%disp('DONE');
%disp(['** single-cell information analysis **']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% single-cell information analysis      %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Loop through all cells to calculate single cell information

for cell=1:num_cells
    
    % For each cell, count the number of transforms per bin
    for bin=1:num_bins
        sumPerBin(cell,bin)=sum(binMatrix(cell,:,bin));
    end
    
    % Calculate the information for cell_x cell_y per stimulus
    for stimulus=1:num_stimulus
        for bin=1:num_bins
            Pr = sumPerBin(cell,bin)/sumPerCell;
            Prs = binMatrix(cell,stimulus,bin)/sumPerGrip;
            if(Pr~=0&&Prs~=0)
                IRs(cell,stimulus)=IRs(cell,stimulus)+(Prs*(log2(Prs/Pr)))*((bin-1)/(num_bins-1)); %could be added to weight the degree of firing rates.
            end
        end
    end
end

% Order by information content, descending
IRs_tmp = sort(reshape(max(IRs,[],2),1,num_cells), 'descend');%find max IRs for each

% plot and save results
if create_figures
    h = figure();
    plot(IRs_tmp)
    axis([0 num_cells -0.1 log2(num_stimulus)+0.1])
    maxinfo = line([0 num_cells], [log2(num_stimulus) log2(num_stimulus)]);
    maxcells = line([num_stimulus num_stimulus], [-0.1 log2(num_stimulus)]);
    maxinfo.LineStyle = '--'; maxcells.LineStyle = '--';
end

% save and close figure
if save_figures == 1
    formatSpec = 'InfoAnalysis%d.fig';
    A1 = timescalled;
    str = sprintf(formatSpec, A1);
    saveas(h, fullfile(desiredFolder, str), 'fig')
    close(h)
end


%{
    if(multi_cell_analysis == 0)
        dlmwrite([fileName num2str(num_samples*sampleMulti) '_IRs.csv'],IRs_tmp);
        saveas(fig,[fileName '_.png']);
        return;
    end
%}


%disp('DONE');

%{
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

IRs_reshaped = [reshape([1:1:(num_cells)],num_cells,1) reshape(IRs,num_cells,num_stimulus)]; %add index to represent cell_no
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


end
%}