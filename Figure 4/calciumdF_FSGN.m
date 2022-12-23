%% SGN calcium imaging analysis 
% 1/13/20 Calvin Kersbergen
 

%% user selects a movie file to measure

[fname pname] = uigetfile({'*.tif';'*.TIF';'*.tiff';'*.TIFF'},'select the still video tiff file');
cd(pname)
openFile = [pname fname];
%[fname2 pname2] = uigetfile({'*.lsm'},'select the associated lsm file');
%infoFile = [pname2 fname2];
%info = lsminfo(infoFile);
imData = imread(openFile);
SGNstruct = struct();

%if strcmp(info.ScanInfo.SCAN_MODE,'Plan')
    numFrames = 2100;
%end
%% user selects ROIs around individual neurons

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
xlim([0 425.1])
ylim([0 425.1])
axis image

hold off
% show a scrollable stack
currentFrame = imread(openFile,1);

figure(1)
subplot(1,2,2)
imagesc(currentFrame)
%colormap gray
title('scrollable frames')
xlim([0 425.1])
ylim([0 425.1])
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
imData = bleachCorrect(imData,1);

for i=1:maxFrame
    for j=1:numROI
        imFrame = imData(:,:,i);
        ROIF(i,j) = mean(imFrame(allROI{j}));
    end
end

%% plot all raw SGN traces
%if strcmp(info.ScanInfo.SCAN_MODE,'Plan')
    time = [0:0.5:1049.5]; % in s
%end

legendROI = cell(numROI,1);
for i = 1:numROI
    legendROI{i} = num2str(i);
end
ylabel('mean fluorescence intensity (a.u.)')
title([num2str(fname) ' (' num2str(numFrames) ' frames)'])
legend(legendROI)

figure(2)
%if strcmp(info.ScanInfo.SCAN_MODE,'Plan')
    
    %check in case unequal length
    if length(time)>length(ROIF)
        time = time(1:length(ROIF));
    else
        ROIF = ROIF(1:length(time),:);
    end
    
    plot(time,ROIF)
    xlabel('time (s)')


%% Identify soma peaks from data, plot each trace with peaks

 pkThreshold = .15; % currently arbitrary
 pkMinHeight = .15; % currently arbitrary
 pkDistance = 5; %in frame, 5 ~= 1s  - currently arbitrary
 meanEventFreq = [];
 meanEventAmp = [];
 meanWidth = [];
 numROI = size(ROIF,2);
sampRate = 0.5; 
drugOn = 1400; % Frame of MRS wash on
highKon = 1950; % frame of high K+ on
 preF = 0;
 postF = 0;
 ROIdF = [];
 maxFrame = 2100;
 time = [1:1:2100];
for i = 1:numROI
   % figNum = ceil(i/6);
   % figure(figNum*100)
   % subplot(6,1,i-6*(figNum-1))
    baseline = median(ROIF(:,i));
    ROIdF(:,i) = (ROIF(:,i)-baseline)/baseline;
   ROIdF(:,i) = smooth(ROIdF(:,i));
  % peak threshold - baseline measurements pre-drug
     [pksBase,locsBase,wBase] = findpeaks(ROIdF(1:1200,i),'MinPeakProminence',pkThreshold,'MinPeakHeight',pkMinHeight,'MinPeakDistance',pkDistance,'Annotate','extents');
     hold on
     %plot(time,ROIdF(:,i),'b')
     %plot(locsBase*sampRate,pksBase,'*r')
     meanEventFreq(i) = length(locsBase)/(1200*sampRate)*60; % ten minutes baseline
     meanEventAmp(i) = mean(pksBase);
     meanWidth(i) = (mean(wBase))*sampRate;
        hold off
     % all events with drug
   [pks,locs,w] = findpeaks(ROIdF(:,i),'MinPeakProminence',pkThreshold,'MinPeakHeight',pkMinHeight,'MinPeakDistance',pkDistance,'Annotate','extents');
   figure 
   hold on
        plot(time,ROIdF(:,i),'b')
        plot(locs/maxFrame*max(time),pks,'*r')    %frame number I believe
    % end
     plot(time,ROIdF(:,i),'b')
     plot(locs/maxFrame*max(time),pks,'*r')    %frame number I believe
     ylabel(['ROI ' num2str(i)])
     hold off
 preF = 0;
 postF = 0;
 for x = 1:length(locs)
     if locs(x) <= drugOn
         preF = preF + 1;
     elseif locs(x) > drugOn && locs(x) < highKon
         postF = postF + 1;
     end
 end
 preFcell(i) = preF;
 postFcell(i) = postF;
end
meanFreq = mean(meanEventFreq);
meanAmp = nanmean(meanEventAmp);
meanWid = nanmean(meanWidth); 

meanFreqPre = mean(preFcell)/(drugOn*sampRate)*60;
meanFreqPost = mean(postFcell)/((highKon-drugOn)*sampRate)*60; 

SGNstruct.meanFreq = meanFreq;
SGNstruct.meanAmp = meanAmp;
SGNstruct.meanWid = meanWid;
SGNstruct.meanFreqPre = meanFreqPre;
SGNstruct.meanFreqPost = meanFreqPost;
SGNstruct.ROIdF = ROIdF;
SGNstruct.ROIF = ROIF;
SGNstruct.ROIs = allROI;
%% 
% plot all traces on raster
figure;
for i = 1:numROI
    plot(ROIdF(:,i)+1*(i-1),'k'); hold on;
end
%fiqQuality(gcf,gca,[3 3]);

 %% Save data 
defaultDir = 'F:\Calvin\Spontaneous activity in GJB2\SGN calcium imaging';
cd(defaultDir);

[fp,name,~] = fileparts([pname fname]);
save([fp '\' name '_SGNdata.mat'],'SGNstruct');



