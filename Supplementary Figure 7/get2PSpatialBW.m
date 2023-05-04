function [BWvector] = get2PSpatialBW(fname,perctile)

% determine spatial BW of detected, normalized events by percentile
    
for i = 1:size(fname.eventStat,2)
    tLoc = fname.eventStat(i).tloc;
        BWvector(i) = sum((fname.smdfof(:,tLoc)./max(fname.smdfof(:,tLoc)))>perctile);

end

