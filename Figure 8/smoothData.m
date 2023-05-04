function smoothedData = smoothData(data, numSmooth)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
    if nargin < 2
        numSmooth = 5;
    end

    smoothedData = zeros(size(data));
    for i = 1:size(data,1)
        smoothedData(i,:) = smooth(data(i,:),numSmooth);
    end
end