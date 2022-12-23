function [BWvector] = getSpatialBWCentral(fname,perctile)

% determine spatial BW of detected, normalized events by percentile (only
% dominant events) 
k = 1;    
for i = 1:size(fname.eventStats,2)
    tLoc = fname.eventStats(i).tloc;
    if (strcmp(fname.eventStats(i).leftOrRightDom, 'Left') & (40 < [fname.eventStats(i).xloc] & [fname.eventStats(i).xloc] < 60))
       BWvector(k) = sum((fname.smLIC(:,tLoc)./max(fname.smLIC(:,tLoc)))>perctile);
       k = k + 1;
    elseif (strcmp(fname.eventStats(i).leftOrRightDom, 'Right') & (40 < [fname.eventStats(i).xloc] & [fname.eventStats(i).xloc] < 60))
        BWvector(k) = sum((fname.smRIC(:,tLoc)./max(fname.smRIC(:,tLoc)))>perctile);
        k = k + 1;
    else
    end

end

