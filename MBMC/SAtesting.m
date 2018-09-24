function recallRates = SAtesting(test, weights, outputCells, sparseness, slope)

    % test = 0 includes both vis and grip, 1 is vis-only and 2 is grip-only
    test;
    
    recallRates=zeros(size(VisNet_firing,4), outputCells);
    
    % for each object
    for object = 1:size(VisNet_firing,4)
  
        % for each transform
        %for transform = 1:size(VisNet_firing,3)
        
            transform = 1; % DELETE
            
            visPattern = VisNet_firing(:,:,transform,object); % replace 3 with transform
            visPattern = visPattern(:)';
            
            if test == 0
                
                %creates an input pattern which concatenates input from the visual
                %and grip cells, associating each grip with three vis.
                
                inputPattern = [visPattern, gripPattern(object,:)];
                
                
            elseif test == 1
                inputPattern = [visPattern, zeros(1,(size(gripPattern,2)))];
                
            elseif test == 2
                
                inputPattern = [zeros(1,size(visPattern,2)),gripPattern(object,:)];
                
                %{
            if pattern<=3
                inputPattern = horzcat(zeros(1,size(visPattern,2)),gripPattern(1,:));
            elseif pattern<=6
                inputPattern = horzcat(zeros(1,size(visPattern,2)),gripPattern(2,:));
            else
                inputPattern = horzcat(zeros(1,size(visPattern,2)),gripPattern(3,:));
            end
                %}
            end

        noNaNweights=weights;
        noNaNweights(isnan(noNaNweights)) = 0;
        
        firingRates=dot(noNaNweights,(repmat(inputPattern',1,outputCells)));
        
        % calculate the effect of soft competition using a threshold
        % sigmoid transfer function. Sparseness between 0 and 100.
        %firingRates(:,1:(round(0.5*outputCells))) = softCompetition(sparseness, slope, firingRates(:,1:(round(0.5*outputCells))));
        %firingRates(:,round((0.5*outputCells)+1):end) = softCompetition(sparseness, slope, firingRates(:,round((0.5*outputCells)+1):end));
        firingRates = softCompetition(sparseness,slope, firingRates);
        
        recallRates(object, :)=firingRates';
        
        %end
    end
    
    %disp(recallRates)

end