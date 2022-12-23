function [groupStruct] = groupedActivity(SGNstruct, threshold)
%UNTITLED11 Summary of this function goes here
%   Detailed explanation goes here
    groupStruct = struct();
    for i = 1:size(SGNstruct,2)
        temp = reshape([SGNstruct(i).events.binary],[],300);
        temp = sum(temp,1);
        [pks,locs,w] = findpeaks(temp,1:size(temp,2),'MinPeakProminence', threshold);
        findpeaks(temp,1:size(temp,2),'MinPeakProminence', threshold)
        groupStruct(i).freq = size(pks,2)/(size(temp,2)/60);
        groupStruct(i).meanROIs = mean(pks);
    end
end

