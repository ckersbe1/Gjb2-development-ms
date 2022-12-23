function [events areas] = getCalciumAreas(imgThr, locs, scalingFactor)
% Measure areas of calcium transients in ISCs from whole field peak
% analysis
%   Detailed explanation goes here
    [m,n,T] = size(imgThr);
    events = zeros(m,n,size(locs,1),'logical');
    areas = [];
    for i = 1:size(locs,1)
        tempImg = imgThr(:,:,locs(i));
        tempImg = bwareaopen(tempImg,1500);
        tempImg = imgaussfilt(double(tempImg),12);
        vals = tempImg(tempImg > 0);
        thr = prctile(vals,70);
        tempImg = tempImg > thr;
        tempImg = bwareaopen(tempImg,2500);
        events(:,:,i) = tempImg;
        if bwarea(tempImg) > 0
            areas = [areas; bwarea(tempImg)/(scalingFactor)];
        else 
            areas = [areas; NaN];
        end
    end

end
