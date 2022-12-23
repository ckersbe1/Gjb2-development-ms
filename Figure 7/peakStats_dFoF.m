function [peakStat, eventStat] = peakStats_dFoF(smLIC, peaksBinaryL, smRIC, peaksBinaryR)
%   simple peaks only analysis, not "events"
    LpeakAmps = [];
    LpeakLocs = [];
    peakLocs = find(peaksBinaryL);
    [r,c] = ind2sub(size(smLIC),peakLocs);
    for i=1:size(r,1)
        LpeakAmps = [LpeakAmps; smLIC(r(i),c(i))];
    end
    LpeakLocs = [r,c];
    
    RpeakAmps = [];
    RpeakLocs = [];
    peakLocs = find(peaksBinaryR);
    [r,c] = ind2sub(size(smRIC),peakLocs);
    for i=1:size(r,1)
        RpeakAmps = [RpeakAmps; smRIC(r(i),c(i))];
    end
    RpeakLocs = [r,c];
    peakStat = {[LpeakAmps, LpeakLocs], [RpeakAmps, RpeakLocs]};
    
    %event analysis (more complex)
    [leftEvents, biEvents, rightEvents]= eventCoordination(peaksBinaryL,peaksBinaryR);
    eventStat = eventStats(rightEvents, leftEvents, biEvents, smRIC, smLIC, peaksBinaryL, peaksBinaryR);
    
    plotTimeSeriesL(smLIC, smRIC, peaksBinaryL, peaksBinaryR, peakStat, eventStat)
end

function [leftEvents, biEvents, rightEvents] = eventCoordination(leftBinary, rightBinary)
    %initialize variables
    leftLabel = bwlabel(convolvePeaks(leftBinary));
    leftEventNum = max(leftLabel);
    rightLabel = bwlabel(convolvePeaks(rightBinary));
    
    leftEvents = zeros(size(leftLabel));
    biEvents = zeros(size(leftLabel));
    rightEvents = zeros(size(leftLabel));
   
    for i=1:leftEventNum
        leftIndices = find(leftLabel==i);        
        rightEvent = size(find(rightLabel(leftIndices)),2) > 1; % find any events that overlap with right events
        
        if rightEvent
            rightValue = rightLabel(leftIndices);
            rightValue(rightValue == 0) = NaN;
            rightValue = mode(rightValue); %%pick the right event with the most overlap in the case of two overlapping events
            uniqVals = unique(rightValue);
            if size(uniqVals,1) > 2
                preserveVal = uniqueVals(~(uniqVals == NaN | uniqVals == rightValue));
                preserveIndices = find(rightLabel == preserveVal);
                rightLabel(preserveIndices) = 600;
            end
            rightIndices = find(rightLabel==rightValue);
            biEvents(leftIndices) = 1;
            biEvents(rightIndices) = 1;
        end
    end

    leftEvents = (leftLabel - (500*biEvents)) > 0;
    rightEvents = (rightLabel - (500*biEvents)) > 0;
    
   
    leftEvents = bwlabel(leftEvents);
    LE1 = max(leftEvents);
    rightEvents = bwlabel(rightEvents);
    biEvents = bwlabel(biEvents);
    leftEvents = bwlabel(filtEvents(leftEvents));
    LE2 = max(leftEvents);
    %disp(['Left Events ' num2str(LE1) ' ' num2str(LE2)]);
    rightEvents = bwlabel(filtEvents(rightEvents));
    biEvents = bwlabel(filtEvents(biEvents));
    %figure;
    %imagesc([smLIC' leftEvents' biEvents' rightEvents' smRIC]);
     
end

function [convPeaks] = convolvePeaks(peaksBinary)
    oneDPeaks = sum(peaksBinary,1);
    convPeaks = oneDPeaks + conv(single(oneDPeaks > 0),ones(1,6),'same');
    convPeaks = convPeaks > 0;
end

function [windowStart, windowEnd] = getWindow(index, windowSize, size)
        if index - windowSize < 1
            windowStart = 1;
            windowEnd = index + windowSize;
        elseif index + windowSize > size
            windowStart = index - windowSize;
            windowEnd = size;
        else
            windowStart = index - windowSize;
            windowEnd = index + windowSize;
        end
end

function [eventStat] = eventStats(rightEvents, leftEvents, biEvents, smRIC, smLIC, leftBinary, rightBinary)
    
    eventClassification = {};
    leftOrRightDom = {};
    numPeaks = [];
    domAmp = [];
    maxLAmp = [];
    maxRAmp = [];
    xloc = [];
    tloc = [];
    hwx = [];
    hwt = [];
    integral = [];
    
    leftBinaryVal = smLIC .* leftBinary; %gives actual value for peaks
    rightBinaryVal = smRIC .* rightBinary;
    windowSize = 350;
    
    %for left events
    for i=1:max(leftEvents)
        indices = find(leftEvents == i);
        leftAmp = max(max(leftBinaryVal(:,indices)));
        peakLoc = find(leftBinaryVal == leftAmp);
        [r,c] = ind2sub(size(smLIC),peakLoc);
        
        if size(r) == 1
            numPeaks = [numPeaks; size(find(leftBinaryVal(:,indices)),1)]; 
            eventClassification = [eventClassification; 'Left'];
            leftOrRightDom = [leftOrRightDom; 'Left'];
            maxLAmp = [maxLAmp; leftAmp];
            maxRAmp = [maxRAmp; 0];
            domAmp = [domAmp; leftAmp];
            xloc = [xloc; r];
            tloc = [tloc; c];
            integral = [integral; trapz(smLIC(:,c))];

            [windowStart, windowEnd] = getWindow(indices(1), windowSize, size(smLIC,2));
            [pks,locs,w] = findpeaks(smLIC(r,windowStart:windowEnd),'WidthReference','halfprom');
            [pk2,locs2,w2] = findpeaks(smLIC(r,windowStart:windowEnd),'WidthReference','halfheight');
            if size(w,2) > size(w2,2)
                [m,n] = size(w2);
                zw2 = zeros(size(w));
                zw2(1:n) = w2;
                w2 = zw2;
            end
            w(w > w2) = w2(w > w2);
            index = find(pks == leftAmp);
            hwt = [hwt; w(index)];

            if numPeaks(end) == 1 && (xloc(end) > 60 && xloc(end) < 100);
                [pks,locs,w] = findpeaks(smLIC(:,c),'WidthReference','halfheight');
                index = find(pks == leftAmp);
                hwx = [hwx; w(index)];
            else
                hwx = [hwx; NaN];
            end   
        else
            leftEvents(leftEvents == i) = 0;
            disp('Left event rejected');
        end
    end
    leftEvents = bwlabel(leftEvents > 0);
    
     %for right events
    for i=1:max(rightEvents)
        indices = find(rightEvents == i);
        rightAmp = max(max(rightBinaryVal(:,indices)));
        peakLoc = find(rightBinaryVal == rightAmp);
        [r,c] = ind2sub(size(smRIC),peakLoc);
        
        if size(r) == 1
            numPeaks = [numPeaks; size(find(rightBinaryVal(:,indices)),1)]; 

            eventClassification = [eventClassification; 'Right'];
            leftOrRightDom = [leftOrRightDom; 'Right'];
            maxLAmp = [maxLAmp; 0];
            maxRAmp = [maxRAmp; rightAmp];
            domAmp = [domAmp; rightAmp];
            xloc = [xloc; r];
            tloc = [tloc; c];
            integral = [integral; trapz(smRIC(:,c))];

            [windowStart, windowEnd] = getWindow(indices(1), windowSize, size(smRIC,2));
            [pks,locs,w] = findpeaks(smRIC(r,windowStart:windowEnd),'WidthReference','halfprom');
            [pk2,locs2,w2] = findpeaks(smRIC(xloc(end),windowStart:windowEnd),'WidthReference','halfheight');
            if size(w,2) > size(w2,2)
                [m,n] = size(w2);
                zw2 = zeros(size(w));
                zw2(1:n) = w2;
                w2 = zw2;
            end
            w(w > w2) = w2(w > w2);
            index = find(pks == rightAmp);
            hwt = [hwt; w(index)];

            if numPeaks(end) == 1 && (xloc(end) > 25 && xloc(end) < 65);
                [pks,locs,w] = findpeaks(smRIC(:,c),'WidthReference','halfheight');
                index = find(pks == rightAmp);
                hwx = [hwx; w(index)];
            else
                hwx = [hwx; NaN];
            end   
        else
            rightEvents(rightEvents == i) = 0;
            disp('Right event rejected');
        end
    end
    rightEvents = bwlabel(rightEvents > 0);
    
    %for bi events
    for i=1:max(biEvents)
        indices = find(biEvents == i);
        rightAmp = max(max(rightBinaryVal(:,indices)));
        peakLoc = find(rightBinaryVal == rightAmp);
        [rr,rc] = ind2sub(size(smRIC),peakLoc);
        leftAmp = max(max(leftBinaryVal(:,indices)));
        peakLoc = find(leftBinaryVal == leftAmp);
        [lr,lc] = ind2sub(size(smLIC),peakLoc);
        
        eventClassification = [eventClassification; 'Bi'];
        maxLAmp = [maxLAmp; leftAmp];
        maxRAmp = [maxRAmp; rightAmp];
        
        if leftAmp > rightAmp
          leftOrRightDom = [leftOrRightDom; 'Left'];
          numPeaks = [numPeaks; size(find(leftBinaryVal(:,indices)),1)];
          xloc = [xloc; lr];
          tloc = [tloc; lc];
          integral = [integral; trapz(smLIC(:,lc))];
          smIC = smLIC;
          domAmp = [domAmp; leftAmp];
          leftInd = 60;
          rightInd = 100;
        else
           leftOrRightDom = [leftOrRightDom; 'Right'];
           numPeaks = [numPeaks; size(find(rightBinaryVal(:,indices)),1)];
           xloc = [xloc; rr];
           tloc = [tloc; rc];
           integral = [integral; trapz(smLIC(:,rc))];
           smIC = smRIC;
           domAmp = [domAmp; rightAmp];
           leftInd = 25;
           rightInd = 65;
        end
 
        [windowStart, windowEnd] = getWindow(indices(1), windowSize, size(smIC,2));
        [pks,locs,w] = findpeaks(smIC(xloc(end),windowStart:windowEnd),'WidthReference','halfprom');
        [pk2,locs2,w2] = findpeaks(smIC(xloc(end),windowStart:windowEnd),'WidthReference','halfheight');
        if size(w,2) > size(w2,2)
                [m,n] = size(w2);
                zw2 = zeros(size(w));
                zw2(1:n) = w2;
                w2 = zw2;
            end
        w(w > w2) = w2(w > w2);
        index = find(pks == domAmp(end));
        hwt = [hwt; w(index)];
        
        if numPeaks(end) == 1 && (xloc(end) > leftInd && xloc(end) < rightInd);
            [pks,locs,w] = findpeaks(smIC(:,tloc(end)),'WidthReference','halfheight');
            index = find(pks == domAmp(end));
            hwx = [hwx; w(index)];
        else
            hwx = [hwx; NaN];
        end   
    end
    
    totalEvents = max(rightEvents) + max(leftEvents) + max(biEvents);
    eventLabel = [1:1:totalEvents]';
    eventStat = table(eventLabel, eventClassification, leftOrRightDom, numPeaks, domAmp, maxLAmp, maxRAmp,xloc, tloc, hwt, hwx, integral);
end

function filt = filtEvents(events)
    for i=1:max(events)
        indices = find(events == i)';
        if(size(indices,1) < 3)
            events(indices) = 0;
            disp('event deleted');
        end
    end
    
    filt = events;
end

function corrmatrix = getCorr(smLIC, smRIC)
    corrmatrix = zeros(size(smLIC,1));
    for i=1:size(smLIC,1)
        lSignal = smLIC(i,:);
        for j=1:size(smRIC,1);
            rSignal = smRIC(j,:);
            temp = corrcoef(lSignal,rSignal);
            corrmatrix(i,j) = temp(1,2);
        end
    end
end

%problem is multiple levels of analysis, micro and macro, need to analysis
%types, one for "events", another for "peaks"
%function 
%peak based for general activity levels
%events!, halfwidth, number of peaks, frequency, amplitude
function plotTimeSeriesL(smLIC, smRIC, peaksBinaryL, peaksBinaryR, peakStat, eventStat)
    Llocs = find(peaksBinaryL);
    [Lr, Lc] = ind2sub(size(peaksBinaryL),Llocs);
    Rlocs = find(peaksBinaryR);
    [Rr, Rc] = ind2sub(size(peaksBinaryL),Rlocs);
    
    statsL = peakStat{1};
    statsR = peakStat{2};
    histoL = statsL(:,2);
    histoR = statsR(:,2);
    
    %get
    rightDomIndices = find(strcmp(eventStat.leftOrRightDom,'Right'));
    leftDomIndices = find(strcmp(eventStat.leftOrRightDom,'Left'));
    lhwx= eventStat.hwx(leftDomIndices)/2;
    lhwt= eventStat.hwt(leftDomIndices)/2;
    lx = eventStat.xloc(leftDomIndices);
    lt = eventStat.tloc(leftDomIndices);
    lhwxlinesx = [lx-lhwx lx+lhwx]';
    lhwxlinesy = [lt lt]';
    lhwtlinesx = [lx lx]';
    lhwtlinesy = [lt-lhwt lt+lhwt]';
    rhwx= eventStat.hwx(rightDomIndices)/2;
    rhwt= eventStat.hwt(rightDomIndices)/2;
    rx = eventStat.xloc(rightDomIndices);
    rt = eventStat.tloc(rightDomIndices);
    rhwxlinesx = [rx-rhwx rx+rhwx]';
    rhwxlinesy =[rt rt]';
    rhwtlinesx =[rx rx]';
    rhwtlinesy = [rt-rhwt rt+rhwt]';
    
    %single figure for movie
    p = figure('Position',[100 0 300 600]);
    set(p,'Color','black');
    colormap jet;
    pv = [.15 .3 .4 .65];
    subplot('Position',pv);
    imagesc(smLIC');
    caxis([0 0.8]);
    xlim([0 125]);
    ylim([000 6000]);
    hold on; 
    scatter(Lr, Lc,'MarkerEdgeColor','white','LineWidth',1);
    line(lhwxlinesx,lhwxlinesy,'Color','white');
    line(lhwtlinesx,lhwtlinesy,'Color','white');
    set(gca,'XTick',[],'XColor','white','YColor','white');
    %axis off;
    
    pv = [.58 .3 .4 .65];
    subplot('Position',pv);
    imagesc(smRIC');
    caxis([0 0.8]);
    xlim([0 125]);
    ylim([0000 6000]);
    hold on; 
    scatter(Rr, Rc,'MarkerEdgeColor','white','LineWidth',1);
    line(rhwxlinesx,rhwxlinesy,'Color','white');
    line(rhwtlinesx,rhwtlinesy,'Color','white');
    set(gca,'XTick',[],'XColor','white');
    set(gca,'YTick',[],'YColor','white');
    %axis off;
    
    pv = [.15 .1 .4 .15];
    subplot('Position',pv);
    histogram(histoL,25,'FaceColor','white','EdgeColor','White','FaceAlpha',1);
    set(gca,'Color','black');
    xlim([0 125]);
    ylim([0 30]);
    ylabel('# of Events');
    set(gca,'XColor','white','YColor','white');
    pv = [.58 .1 .4 .15];
    
     subplot('Position',pv,'Color','black');
     histogram(histoR,25,'FaceColor','white','EdgeColor','White','FaceAlpha',1);
     set(gca,'Color','black');
     xlim([0 125]);
     ylim([0 30]);
     set(gca,'XColor','white');
     set(gca,'YTick',[],'YColor','white');  
end
