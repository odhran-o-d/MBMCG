function activity = probPropagate(postSyn, preSyn1, preSyn2, preSyn3, weights1, weights2, weights3)

% Weights become either 0 or 1, depending on weight. P(1|weight) = weight.
weights = [weights1; weights2; weights3];
%{
randMatrix = zeros(size(weights));
for i = [find(randMatrix)]'
    randMatrix(i) = rand(1);
end
%}
randMatrix = rand(size(weights));
randWeights = randMatrix < weights;


activity = [preSyn1(:); preSyn2(:); preSyn3(:)]' * randWeights;
activity = reshape(activity, size(postSyn));


end