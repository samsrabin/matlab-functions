function outData = weighted_avg_byCover(inData , weights)
% Input arguments are matrices with columns corresponding to cover type.
% Weights are the fraction of land in each cover type... Will be normalized
% to add to 1. outData is a column vector.

if ~isequal(size(inData),size(weights)) || ~isempty(find(isnan(inData) | isnan(weights),1))
    error('inData and weights must be the same size and contain no NaNs.')
end

weights_sum = sum(weights,2) ;
weights_normed = nan(size(weights)) ;
for c = 1:size(weights_normed,2)
    weights_normed(:,c) = weights(:,c) ./ weights_sum ;
end

outData = sum(inData.*weights_normed,2) ;



end