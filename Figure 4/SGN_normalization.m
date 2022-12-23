%% SGN calcium analysis with image normalization

%load image
[fn, dname] = uigetfile({'*.tif';'*.TIF';'*.tiff';'*.TIFF'});
SGNstruct = struct();
openFile = [dname fn];
numFrames = 2100;
for i = 1:numFrames
    img(:,:,i) = imread(openFile,i);
end
[fp,name,~] = fileparts([dname fn]);
%% normalize image
img = bleachCorrect(img,1);
[dFoF Fo] = normalizeImg(img,10);
%% select ROIs
hold on
figure(1)
subplot(1,2,1)
imagesc(mean(img,3));


% colormap gray
title('average z-projection')
xlim([0 425.1])
ylim([0 425.1])
axis image
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

SGNstruct.rois = allROI;
%% 

fprintf('\nCalculating raw F...\n  ')
maxFrame = numFrames;
for i=1:maxFrame
    for j=1:numROI
        imFrame = dFoF(:,:,i);
        ROIdF(i,j) = mean(imFrame(allROI{j}));
    end
end

%% Peak detection

 pkThreshold =  1; % currently arbitrary
 pkMinHeight = 1; % currently arbitrary
 pkDistance = 5; %in frame, 5 ~= 1s  - currently arbitrary
 meanEventFreqMed = [];
 meanEventAmpMed = [];
 
sampRate = 0.5; 
time = [1:maxFrame]*sampRate;
for i = 1:numROI
   %smooth and background adjust
    ROIdF(:,i) = smooth(msbackadj([1:maxFrame]',ROIdF(:,i),'WindowSize',45,'StepSize',45));
    figNum = ceil(i/6);
    figure(figNum*100)
    subplot(6,1,i-6*(figNum-1))
    % peak detection
   [pksBase,locsBase,wBase] = findpeaks(ROIdF(1:1200,i),'MinPeakProminence',pkThreshold,'MinPeakHeight',pkMinHeight,'MinPeakDistance',pkDistance,'Annotate','extents');
    hold on
     plot(time,ROIdF(:,i),'b')
        plot(locsBase*sampRate,pksBase,'*r') 
    % end
     ylabel(['ROI ' num2str(i)])
     % Baseline data
     meanEventFreq(i) = length(locsBase)/1200*60;
     meanEventAmp(i) = mean(pksBase);
     meanWidth(i) = mean(wBase)/(1/(max(time)/length(time)));
     
    % all data for NBQX
    [pks,locs,w] = findpeaks(ROIdF(:,i),'MinPeakProminence',pkThreshold,'MinPeakHeight',pkMinHeight,'MinPeakDistance',pkDistance,'Annotate','extents');
 plot(time,ROIdF(:,i),'b')
        plot(locs/maxFrame*max(time),pks,'*r')    %frame number I believe
end

meanFreq = mean(meanEventFreq);
meanAmp = mean(meanEventAmp);
meanWid = mean(meanWidth);
 
 drugOn = 1400; % Frame of NBQX wash on
 highKon = 1950; % frame of high K+ on
 preF = 0;
 postF = 0;
 
 for x = 1:length(locs)
     if locs(x) <= drugOn
         preF = preF + 1;
     elseif locs(x) > drugOn && locs(x) < highKon
         postF = postF + 1;
     end
 end
 
meanFreqPre = preF/(drugOn*sampRate)*60;
meanFreqPost = postF/((highKon-drugOn)*sampRate)*60; 

SGNstruct.meanFreqPre = meanFreqPre;
SGNstruct.meanFreqPost = meanFreqPost;
SGNstruct.ROIdF = ROIdF;

 %% Save data 
defaultDir = 'C:\Users\Bergles Lab\Desktop\Spontaneous activity in GJB2\SGN calcium imaging';
cd(defaultDir);

[fp,name,~] = fileparts([dname fn]);
save([fp '\' name '_SGNdata.mat'],'SGNstruct');


