function [posIndices] = getPositiveGrid(gridIndices,roiIndices)
%g Returns indices of all boxes contained within the outline 
%   Detailed explanation goes here
    indx = gridIndices(:,1:2:end);
    indy = gridIndices(:,2:2:end);
    [m,n] = size(indx);
    indx = reshape(indx,m*n,1);
    indy = reshape(indy,m*n,1);

    test1 = inpolygon(indx,indy,roiIndices(:,1),roiIndices(:,2));
    test1 = reshape(test1,m,n);
    test1 = sum(test1,2) == 4; %all points must be contained within the polygon outline
    posIndices = gridIndices(test1,:);
end

