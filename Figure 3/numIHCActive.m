%% number of IHCs active during a given ISC calcium event

% allLocs is a struct of size {#ROI,1} that contains the peak locations for
% each ROI

% allROI is number of ROI

% load ISCstruct from ISC calcium analysis 
ISCevents = load('20190815 exp270 mouse 3 tecta-cre cx26flfl gcamp3 movie 2 prep 1 1x_ISCdata.mat');
eventStart = [ISCevents.ISCstruct.event.timeStart];
eventEnd = [ISCevents.ISCstruct.event.timeEnd];
for l = 1:length(allLocs)
    allLocs(l).flag = 0;
end
activeROI = struct();

for i = 1:length(eventStart) % how many ISC calcium events
    numIHCActive(i) = 0;
    activeROI(i).event = [];
    for j = 1:length(allROI)
        for k = 1:length(allLocs(j).locs)
            if (eventStart(i) <= allLocs(j).locs(k)) && (allLocs(j).locs(k) <= eventEnd(i)) % IHC peak is between event start and event end
                if allLocs(j).flag ~= 2                         % was this ROI active during last event?
                    numIHCActive(i) = numIHCActive(i) + 1; % was not active - adds to count for that event
                    activeROI(i).event = [activeROI(i).event j];
                    allLocs(j).flag = 1; % sets flag for upcoming event
                end

            end
        end
    end
    
    % are there overlapping temporal windows of ISC events? 
    eventWind = [eventStart(i):1:eventEnd(i)];
    if i < length(eventStart)
        nextEventWind = [eventStart(i+1):1:eventEnd(i+1)];
    else 
        nextEventWind = [0];
    end
    
    if i > 1
        pastEventWind = [eventStart(i-1):1:eventEnd(i-1)];
    else 
        pastEventWind = [0];
    end
    
    for j = 1:length(allROI)  
       if isempty(intersect(eventWind,nextEventWind)) == 0 % check to see if overlap with next event - if yes, then set flags
           overlapFlag(i) = 1; 
           if allLocs(j).flag == 1
                allLocs(j).flag = 2;
            elseif allLocs(j).flag == 2
                 if isempty(intersect(eventWind,pastEventWind)) == 1 % past event overlapped as well? 
                        allLocs(j).flag = 0; % reset flags if no overlap with past event
                 else
                     % leave flag as 2 if there is overlap with past event
                     pastOverlapFlag(i) = 1;
                 end
           end
       elseif isempty(intersect(eventWind,nextEventWind)) == 1 % no temporal overlap with next event
           allLocs(j).flag = 0; % reset all flags
           overlapFlag(i) = 0;
           pastOverlapFlag(i) = 0;
       end
    end

end

for j = 1:length(numIHCActive)
if numIHCActive(j) == 0
    numIHCActive(j) = NaN;
end
end