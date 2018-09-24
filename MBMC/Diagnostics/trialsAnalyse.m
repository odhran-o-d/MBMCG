function output = trialsAnalyse(data, datatype, draw_figure)

if draw_figure
    figure();
end

switch datatype
    case 'resultMat'
        num_Y = 0;
        num_N = 0;
        
        for i = 1:numel(data)
            switch data(i)
                case 'Y'
                    num_Y = num_Y + 1;
                case 'N'
                    num_N = num_N + 1;
                otherwise
                    error('Strange Result Value')
            end
        end
        
        percent_Y = num_Y / (num_Y + num_N) * 100;
        percent_N = num_N / (num_Y + num_N) * 100;
        
        %assert((percent_Y + percent_N) == 100)
        
        if draw_figure
            %{
            b = bar([num_Y num_N; NaN NaN], 'stacked');
            
            %xticks(1);
            %xticklabels('Success Rate')
            %}
            
            b = bar([percent_Y percent_N]);
            xticklabels({'Success Rate', 'Failure Rate'});
        end
        
        assert(~isnan(percent_Y) && ~isnan(percent_N))
        output = [percent_Y, percent_N];
        
    case 'percentageTable'
        
        data = sortrows(data, 1);
        if draw_figure
            b = bar([data(:,2) 100-data(:, 2)], 'stacked');
            xticklabels(data(:,1));
            xlabel('Exploration Time / steps')
        end
        
        b(1).FaceColor = [0 1 0];
        b(2).FaceColor = [1 0 0];
        
        legend('Success %', 'Failure %')
        
    otherwise
        error('Invalid Data Type Specified')
end

if draw_figure
    
    ylabel('% Trials')
    
end

end