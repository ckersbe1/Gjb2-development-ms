function normFs = normalizeData(unmixed_data, numBaseline)
%NORMALIZEDATA Summary of this function goes here
%   Detailed explanation goes here
    if nargin < 2
        numBaseline = 15;
    end
    cutoffF = 200;
    baselines = mean(unmixed_data(:,:,:,:,1:numBaseline),5);
    denom = baselines;
    denom(baselines < cutoffF) = cutoffF;

    normFs = (unmixed_data - baselines) ./denom;
end

