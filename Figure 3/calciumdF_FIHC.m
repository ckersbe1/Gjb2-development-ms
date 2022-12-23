%% IHC calcium imaging analysis 
% 2/28/19 Calvin Kersbergen
 

%% user selects a movie file to measure

[fname pname] = uigetfile({'*.tif';'*.TIF';'*.tiff';'*.TIFF'},'select the still video tiff file');
cd(pname)
openFile = [pname fname];
[fname2 pname2] = uigetfile({'*.lsm'},'select the associated lsm file');
infoFile = [pname2 fname2];
info = lsminfo(infoFile);
imData = imread(openFile);

if strcmp(info.ScanInfo.SCAN_MODE,'Plan')
    numFrames = info.DimensionTime;
end
%% user selects ROIs around individual hair cells 
  
%show a z-project the stack using average value
info2 = imfinfo(openFile);

if info2(1,1).BitDepth == 16
    zproject = zeros(info2(1,1).Width,info2(1,1).Height,'uint16');
    imData = zeros(info2(1,1).Width,info2(1,1).Height,numFrames,'uint16');
elseif info2(1,1).BitDepth == 8
    zproject = zeros(info2(1,1).Width,info2(1,1).Height,'uint8');
    imData = zeros(info2(1,1).Width,info2(1,1).Height,numFrames,'uint8');
end

fprintf('projecting:  %s \n', fname)

for i = 1:numFrames
    imData(:,:,i) = imread(openFile,i);
end

zproject = mean(imData,3);
hold on
figure(1)
subplot(1,2,1)
imagesc(zproject)

% colormap gray
title('average z-projection')
xlim([0 info.DimensionX])
ylim([0 info.DimensionY])
axis image

hold off
% show a scrollable stack
currentFrame = imread(openFile,1);

figure(1)
subplot(1,2,2)
imagesc(currentFrame)
colormap gray
title('scrollable frames')
xlim([0 info.DimensionX])
ylim([0 info.DimensionY])
axis image
xlabel ('f-forward, b-back, s-skip forward, n-newbox, space-done');


fignum = gcf;
done = 0;
currentFrameNum = 1;
numROI = 0;

fprintf('\npress n to begin ROI selection using the mouse...\n  ')

% for selection of square ROIs 
while not(done)
    
    waitforbuttonpress
    pressed = get(fignum, 'CurrentCharacter');
    
    
    if pressed == ' ' % space for done w all ROIs
        done = 1;
    elseif pressed == 'f' % forward 1 frame
        if currentFrameNum < numFrames;
            currentFrameNum = currentFrameNum+1;
            currentFrame = imread(openFile,currentFrameNum);
        else
            beep
            display ('no more frames')
        end
        subplot(1,2,2), imagesc(currentFrame);
        title({fname;['frame:', num2str(currentFrameNum),'/', num2str(numFrames)]});
        axis image
        xlabel ('f-forward, b-back, s-skip forward, n-newbox, space-done');
    elseif pressed == 'b' % back 1 frame
        if currentFrameNum > 1
            currentFrameNum = currentFrameNum-1;
            currentFrame = imread(openFile,currentFrameNum);
        else
            beep
            display ('no more frames')
        end
        subplot(1,2,2), imagesc(currentFrame);
        title({fname;['frame:', num2str(currentFrameNum),'/', num2str(numFrames)]});
        axis image
        xlabel ('f-forward, b-back, s-skip forward, n-newbox, space-done');
    elseif pressed == 's' % skip 10 frames forward
        if currentFrameNum+10 <= numFrames;
            currentFrameNum = currentFrameNum+10;
            currentFrame = imread(openFile,currentFrameNum);
        else
            beep
            display ('no more frames')
        end
        subplot(1,2,2), imagesc(currentFrame);
        title({fname;['frame:', num2str(currentFrameNum),'/', num2str(numFrames)]});
        axis image
        xlabel ('f-forward, b-back, s-skip forward, n-newbox, space-done');
    elseif pressed == 'n'
        numROI = numROI+1;
        fprintf('\nselect an ROI using the mouse:  ')
        subplot(1,2,1)
        [freeMask freeX freeY] = roipoly;
        drawpolygon('Position',[freeX freeY],'FaceAlpha',0,'linewidth',1,'Color','m') %not working
  
        allROI{numROI} = freeMask;
        
        %draw selection on figure
%         subplot(1,2,1)
%         rectangle('Position',ROI,'EdgeColor','m');
%         text(ROI(1)-7,ROI(2)-7,['\color{magenta}' num2str(numROI)])
%         subplot(1,2,2)
%         rectangle('Position',ROI,'EdgeColor','m');
    else
        beep
        display ('not a valid key')
    end
end %loop while not done

%% cell-based dFoF analysis
maxFrame = length(imData);
fprintf('\nCalculating raw F...\n  ')

for i=1:maxFrame
    for j=1:numROI
        imFrame = imData(:,:,i);
        ROIF(i,j) = mean(imFrame(allROI{j}));
    end
end

%% plot all hair cell traces
if strcmp(info.ScanInfo.SCAN_MODE,'Plan')
    time = info.TimeStamps.TimeStamps; % in s
end

legendROI = cell(numROI,1);
for i = 1:numROI
    legendROI{i} = num2str(i);
end
ylabel('mean fluorescence intensity (a.u.)')
title([num2str(fname) ' (' num2str(numFrames) ' frames)'])
legend(legendROI)

figure(2)
if strcmp(info.ScanInfo.SCAN_MODE,'Plan')
    
    %check in case unequal length
    if length(time)>length(ROIF)
        time = time(1:length(ROIF));
    else
        ROIF = ROIF(1:length(time),:);
    end
    
    plot(time,ROIF)
    xlabel('time (s)')
end
save('raw frameIntensity_IHCCx268.mat')

%% Identify soma peaks from data, plot each trace with peaks

 pkThreshold = .2; % currently arbitrary
 pkMinHeight = .1; % currently arbitrary
 pkDistance = 5; %in frame, 5 ~= 2s  - currently arbitrary
 meanEventFreqMed = [];
 meanEventAmpMed = [];
 
sampRate = info.TimeStamps.AvgStep; 
allLocs = struct();
allPeaks = struct();
for i = 1:numROI
    ROIF(:,i) = smooth(ROIF(:,i)); % smoothing function applied to each ROI 
    figNum = ceil(i/6);
    figure(figNum*100)
    subplot(6,1,i-6*(figNum-1))
    baseline = median(ROIF(:,i));
    ROIdF(:,i) = (ROIF(:,i)-baseline)/baseline;
  % peak threshold - 
   [pks,locs,w] = findpeaks(ROIdF(:,i),'MinPeakProminence',pkThreshold,'MinPeakHeight',pkMinHeight,'MinPeakDistance',pkDistance,'Annotate','extents');
    hold on
    plot(time,ROIdF(:,i),'b')
    plot(locs/maxFrame*max(time),pks,'*r')    %frame number I believe
    
    ylabel(['ROI ' num2str(i)])
    allLocs(i).locs = locs;
    allPeaks(i).peaks = pks;
    meanEventFreqMed(i) = length(locs)/max(time)*60;
    meanEventAmpMed(i) = mean(pks);
    meanWidthMed(i) = mean(w)/(1/(max(time)/length(time)));
end
meanEventAmp = mean(meanEventAmpMed);
meanEventWidth = mean(meanWidthMed);
meanEventFreq = mean(meanEventFreqMed);

%% 

% plot all traces on raster
figure;
for i = 1:numROI
    plot(ROIdF(:,i)+1*(i-1),'k'); hold on;
end
%fiqQuality(gcf,gca,[3 3]);
[L W] = size(ROIdF);
% % correlation matrix - assess degree of spatial correlation between cell
% % bodies

Rcorr = corr(ROIdF);
hmo = HeatMap(Rcorr,'Colormap',parula,'Symmetric',false);


% % mean neuronal event frequency for all cells: 
% IHCFreqMed = mean(meanEventFreqMed);
% IHCAmpMed = mean(meanEventAmpMed);
% IHCWidthMed = mean(meanWidthMed);
% 

[ length1 width1 ] = size(Rcorr);

% correlation coefficients across cells

% 1 cell
for x = 2:length1-1
    ihcCorr1(x) = mean([Rcorr(x,x+1),Rcorr(x-1,x)']);
end
meanIHCCorr1 = mean(ihcCorr1);  

%2 cells
for x = 3:length1-2
    ihcCorr2(x) = mean([Rcorr(x,x+1:x+2),Rcorr(x-2:x-1,x)']);
end
meanIHCCorr2 = mean(ihcCorr2);  

% 3 cells
for x = 4:length1-3
    ihcCorr3(x) = mean([Rcorr(x,x+1:x+3),Rcorr(x-3:x-1,x)']);
end
meanIHCCorr3 = mean(ihcCorr3);  

% 4 cells
for x = 5:length1-4
    ihcCorr4(x) = mean([Rcorr(x,x+1:x+4),Rcorr(x-4:x-1,x)']);
end
meanIHCCorr4 = mean(ihcCorr4);  

% 5 cells
for x = 6:length1-5
    ihcCorr5(x) = mean([Rcorr(x,x+1:x+5),Rcorr(x-5:x-1,x)']);
end
meanIHCCorr5 = mean(ihcCorr5);    

% 6 cells
for x = 7:length1-6
    ihcCorr6(x) = mean([Rcorr(x,x+1:x+6),Rcorr(x-6:x-1,x)']);
end
meanIHCCorr6 = mean(ihcCorr6);    
% 7 cells
for x = 8:length1-7
    ihcCorr7(x) = mean([Rcorr(x,x+1:x+7),Rcorr(x-7:x-1,x)']);
end
meanIHCCorr7 = mean(ihcCorr7);    

% 8 cells
for x = 9:length1-8
    ihcCorr8(x) = mean([Rcorr(x,x+1:x+8),Rcorr(x-8:x-1,x)']);
end
meanIHCCorr8 = mean(ihcCorr8);   

% mean values not spread
%2 cells
for x = 3:length1-2
    ihcCorr22(x) = mean([Rcorr(x,x+2),Rcorr(x-2,x)']);
end
meanIHCCorr22 = mean(ihcCorr22);  

% 3 cells
for x = 4:length1-3
    ihcCorr32(x) = mean([Rcorr(x,x+3),Rcorr(x-3,x)']);
end
meanIHCCorr32 = mean(ihcCorr32);  

% 4 cells
for x = 5:length1-4
    ihcCorr42(x) = mean([Rcorr(x,x+4),Rcorr(x-4,x)']);
end
meanIHCCorr42 = mean(ihcCorr42);  

% 5 cells
for x = 6:length1-5
    ihcCorr52(x) = mean([Rcorr(x,x+5),Rcorr(x-5,x)']);
end
meanIHCCorr52 = mean(ihcCorr52);    

% 6 cells
for x = 7:length1-6
    ihcCorr62(x) = mean([Rcorr(x,x+6),Rcorr(x-6,x)']);
end
meanIHCCorr62 = mean(ihcCorr62);    
% 7 cells
for x = 8:length1-7
    ihcCorr72(x) = mean([Rcorr(x,x+7),Rcorr(x-7,x)']);
end
meanIHCCorr72 = mean(ihcCorr72);    

% 8 cells
for x = 9:length1-8
    ihcCorr82(x) = mean([Rcorr(x,x+8),Rcorr(x-8,x)']);
end
meanIHCCorr82 = mean(ihcCorr82);  

% scrambled data
tempROIdF = ROIdF;
idx = randperm(numROI);
for y = 1:numROI
    tempROIdF(:,y) = ROIdF(:,idx(y));
end

RcorrS = corr(tempROIdF);
hmo = HeatMap(RcorrS,'Colormap',parula,'Symmetric',false);

% 1 cell
for x = 2:length1-1
    ihcCorr1S(x) = mean([RcorrS(x,x+1),RcorrS(x-1,x)']);
end
meanIHCCorr1S = mean(ihcCorr1S);  

%2 cells
for x = 3:length1-2
    ihcCorr2S(x) = mean([RcorrS(x,x+2),RcorrS(x-2,x)']);
end
meanIHCCorr2S = mean(ihcCorr2S);  

% 3 cells
for x = 4:length1-3
    ihcCorr3S(x) = mean([RcorrS(x,x+3),RcorrS(x-3,x)']);
end
meanIHCCorr3S = mean(ihcCorr3S);  

% 4 cells
for x = 5:length1-4
    ihcCorr4S(x) = mean([RcorrS(x,x+4),RcorrS(x-4,x)']);
end
meanIHCCorr4S = mean(ihcCorr4S);  

% 5 cells
for x = 6:length1-5
    ihcCorr5S(x) = mean([RcorrS(x,x+5),RcorrS(x-5,x)']);
end
meanIHCCorr5S = mean(ihcCorr5S);    

% 6 cells
for x = 7:length1-6
    ihcCorr6S(x) = mean([RcorrS(x,x+6),RcorrS(x-6,x)']);
end
meanIHCCorr6S = mean(ihcCorr6S);    
% 7 cells
for x = 8:length1-7
    ihcCorr7S(x) = mean([RcorrS(x,x+7),RcorrS(x-7,x)']);
end
meanIHCCorr7S = mean(ihcCorr7S);    

% 8 cells
for x = 9:length1-8
    ihcCorr8S(x) = mean([RcorrS(x,x+8),RcorrS(x-8,x)']);
end
meanIHCCorr8S = mean(ihcCorr8S);  
%% number of IHCs active during a given ISC calcium event

% load ISCstruct from ISC calcium analysis 
ISCevents = load('20210614 exp439 mouse 6 prep 1 tecta cx26flfl gc3 movie 1 1x_ISCdata.mat');
eventStart = [ISCevents.ISCstruct.event.timeStart];
eventEnd = [ISCevents.ISCstruct.event.timeEnd];
numROI = length(allLocs);
for l = 1:length(allLocs)
    allLocs(l).flag = 0;
end
activeROI = struct();
numIHCActive = [];
for i = 1:length(eventStart) % how many ISC calcium events
    numIHCActive(i) = 0;
    activeROI(i).event = [];
    for j = 1:1:numROI
        for k = 1:length(allLocs(j).locs)
            if (eventStart(i) <= allLocs(j).locs(k)) && (allLocs(j).locs(k) <= eventEnd(i)) % IHC peak is between event start and 10 frames following event start
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
    
    for j = 1:1:numROI  
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
if overlapFlag(j) == 0
    numIHCActiveNoOver(j) = numIHCActive(j);
else
    numIHCActiveNoOver(j) = NaN;
end
end
%% Generate movie of hair cell peaks and activation


 %% Save data 
defaultDir = 'C:\Users\Bergles Lab\Desktop\Spontaneous activity in GJB2\IHC ISC Calcium Imaging\6K room and phys';
cd(defaultDir);

save([defaultDir '\IHCcalciumCx268.mat'],'ROIdF','meanEventFreq','meanEventWidth','meanEventAmp','numIHCActive','numIHCActiveNoOver','allLocs','allPeaks','meanIHCCorr1','meanIHCCorr2','meanIHCCorr3','meanIHCCorr4','meanIHCCorr5','meanIHCCorr6','meanIHCCorr7','meanIHCCorr8','meanIHCCorr22','meanIHCCorr32','meanIHCCorr42','meanIHCCorr52','meanIHCCorr62','meanIHCCorr72','meanIHCCorr82','meanIHCCorr1S','meanIHCCorr2S','meanIHCCorr3S','meanIHCCorr4S','meanIHCCorr5S','meanIHCCorr6S','meanIHCCorr7S','meanIHCCorr8S')



