function inhib_plasticity_experiment()

%% Setup

num_main =  [1 10];
num_input = [1 10];
num_inhib = [1 1];
steps = 10;
input_learning_rate = 1;
inhib_learning_rate = 0.5;
num_figs = 10;
input_regime = 'split_set';
subplot_rows = 4;
main_inhibition = 'None';
inhib_inhibition = 'Capped';

if num_figs > 20 || num_figs > steps
    error('Too Many Figs Requested')
end

main_layer = zeros(num_main);
switch input_regime
    case {'split_random', 'split_set'}
input_layer_one = zeros(num_input);
input_layer_two = zeros(num_input);
input_layer = [input_layer_one input_layer_two];
    case 'split_unbalanced'
        input_layer_one = zeros(num_input);
input_layer_two = zeros([1 round(0.5 * num_input(2))]);
input_layer = [input_layer_one input_layer_two];
    otherwise
        input_layer = zeros(num_input);
end
inhib_layer = zeros(num_inhib);
input2main = rand(numel(input_layer), numel(main_layer));
input2main = normalise(input2main, 1, true);
main2inhib = ones(numel(main_layer), numel(inhib_layer));
inhib2main = zeros(numel(inhib_layer), numel(main_layer));
inhibSyn_cap = -0.5;
switch input_regime
    case 'progressive_onehot'
        input_no = 0;
    case 'constant'
        input_no = randi(numel(input_layer));
    case 'split_set'
        input_no = {[5 5], [5 1], [5 5], [5 1], [5 5], [10 10]};
        steps = numel(input_no);
        num_figs = numel(input_no);
        case 'split_unbalanced'
        input_no = {[5 5], [5 1], [5 5], [5 1], [5 5], [10 3]};
        steps = numel(input_no);
        num_figs = numel(input_no);
end

%% Training
fig = figure();

for time = 1:steps
    subfigs = 0;
    
    switch input_regime
        case 'rnd_onehot'
            input_layer(randi(numel(input_layer))) = 1;
        case 'progressive_onehot'
            if displayperSteps(time, steps, numel(input_layer))
                input_no = input_no + 1;
            end
            input_layer(input_no) = 1;
        case 'constant'
            input_layer(input_no) = 1;
        case 'split_random'
            input_layer_one(:) = 0; input_layer_two(:) = 0;
            input_layer_one(randi(numel(input_layer_one))) = 1; input_layer_two(randi(numel(input_layer_two))) = 1;
            input_layer = [input_layer_one input_layer_two];
        case {'split_set', 'split_unbalanced'}
            if time > numel(input_no)
                break
            end
            input_layer_one(:) = 0; input_layer_two(:) = 0;
            input_layer_one(input_no{time}(1)) = 1; input_layer_two(input_no{time}(2)) = 1;
            input_layer = [input_layer_one input_layer_two];
        otherwise, error('Switch Error')
    end
    
    if displayperSteps(time, steps, num_figs)
        subplot(subplot_rows, num_figs, (time/steps)*num_figs+num_figs*subfigs);
        subfigs = subfigs + 1;
        bar(1:size(input_layer,2), input_layer); ylim([0 1])
        title(sprintf('Input @ t=%d', time));
    end
    
    % Update Main Layer
    main_layer = cellPropagate(main_layer, input_layer, [], [], input2main, [], []);
    switch main_inhibition
        case 'Divisive'
    main_layer = main_layer/max(main_layer(:));
        case 'Capped'
            main_layer(main_layer > 1) = 1;
        case 'None'
        otherwise
            error('Switch Error')
    end
    
    % Update Inhib Layer
    inhib_layer = cellPropagate(inhib_layer, main_layer, [], [], main2inhib, [], []);
    switch inhib_inhibition
        case 'Divisive'
    inhib_layer = inhib_layer/max(inhib_layer(:));
        case 'Capped'
            inhib_layer(inhib_layer > 1) = 1;
        case 'None'
        otherwise
            error('Switch Error')
    end
    
    if displayperSteps(time, steps, num_figs)
        subplot(subplot_rows, num_figs, (time/steps)*num_figs+num_figs*subfigs)
        subfigs = subfigs + 1;
        bar(1:size(main_layer,2), main_layer); ylim([0 1]);
        title(sprintf('Main Pre @ t=%d', time));
    end
    
    % Update Main Layer w/ Input + Inhib
    main_layer = cellPropagate(main_layer, input_layer, inhib_layer, [], input2main, inhib2main, []);
    [~, idx] = max(main_layer(:));
    main_layer(:) = 0; main_layer(idx) = 1;
    
    if displayperSteps(time, steps, num_figs)
        subplot(subplot_rows, num_figs, (time/steps)*num_figs+num_figs*subfigs)
        subfigs = subfigs + 1;
        bar(1:size(main_layer,2), main_layer); ylim([0 1])
        title(sprintf('Main Post @ t=%d', time));
    end
    
    % Update Synapses
    input2main = input2main + (input_learning_rate * input_layer(:) * main_layer(:)');
    input2main = normalise(input2main, 1, true);
    inhib2main = inhib2main - (inhib_learning_rate * inhib_layer(:) * main_layer(:)');
    inhib2main(inhib2main < inhibSyn_cap ) = inhibSyn_cap;
    
    if displayperSteps(time, steps, num_figs) && isequal(input_regime, 'constant')
        subplot(subplot_rows, num_figs, (time/steps)*num_figs+num_figs*subfigs)
        subfigs = subfigs + 1;
        bar(1:size(main_layer,2), input2main(input_no, :)); ylim([0 1])
        title(sprintf('Input2Main @ t=%d', time));
    end
    
    if displayperSteps(time, steps, num_figs)
        subplot(subplot_rows, num_figs, (time/steps)*num_figs+num_figs*subfigs)
        subfigs = subfigs + 1;
        bar(1:size(main_layer,2), inhib2main); ylim([-1 0])
        title(sprintf('Inhib2Main @ t=%d', time));
    end
    
    input_layer(:) = 0;
    main_layer(:) = 0;
    inhib_layer(:) = 0;
    
end

%figure(); bar(1:size(main_layer,2), inhib2main(:)');

end