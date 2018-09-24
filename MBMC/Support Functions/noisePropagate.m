function activity = noisePropagate(noiseFactor, postSyn, preSyn1, preSyn2, preSyn3, weights1, weights2, weights3)

% Try to reduce need for concatenation.


%activity = dot(([repmat(preSyn1(:),[1,numel(postSyn)]); repmat(preSyn2(:),[1,numel(postSyn)]); repmat(preSyn3(:),[1,numel(postSyn)])]  ), [weights1; weights2; weights3]);
activity = [preSyn1(:); preSyn2(:); preSyn3(:)]' * [weights1; weights2; weights3];
activity = reshape(activity, size(postSyn));

noise = (rand(size(activity))-.5) * noiseFactor * 2;
activity = activity + noise;
activity(activity<0) = 0;

end