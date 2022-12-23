function [numPks peakAmp positiveIndices] = getISCpeaks(file)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


[time1 numROI] = size(file.ISCstruct.rois);
time = [1:1:time1];
roiPeaks = [];

for x = 1:numROI
    medSig = median(file.ISCstruct.rois(:,x));
    stdSig = std(file.ISCstruct.rois(:,x),1);
    % very high treshold for activation
    pkThreshold = medSig + 3* stdSig;
    pkMinHeight = 0.1;
    pkDistance = 5; % 2 seconds
    [roiPks locs w] = findpeaks(file.ISCstruct.rois(:,x),'MinPeakProminence',pkThreshold,'MinPeakHeight',pkMinHeight,'MinPeakDistance',pkDistance,'Annotate','extents');
    % plot a couple to test accuracy
    %figure
    %plot(time, file.ISCstruct.rois(:,x),'b')
    %hold on
    % plot(locs,roiPks,'*r')
    roiPeaks = [roiPeaks roiPks'];
    numPks(x) = length(locs);
end
numPks;
peakAmp = mean(roiPeaks); 

% load image
%load image
[fn, dname] = uigetfile({'*.tif';'*.TIF';'*.tiff';'*.TIFF'});
ISCstruct2 = struct();
openFile = [dname fn];
numFrames = 1250;
for i = 1:numFrames
    img(:,:,i) = imread(openFile,i);
end
[fp,name,~] = fileparts([dname fn]);


%% Display image with grid overlapping
figure; imagesc(mean(img,3)); 
x = file.ISCstruct.rotateDegrees; % change input here
img = imrotate(img,x);
colormap gray
imshow(mean(img,3),[0 10000]); truesize;

%%
widthImg = size(img,2);
heightImg = size(img,1);
sizeSq = 10;
maxTime = 606.9686; % in seconds 
[indices,miniIndices] = getGrid(widthImg,heightImg,sizeSq);
roiIndices = file.ISCstruct.ISCmask.Position;
% Grids are organized top to bottom, left to right

positiveIndices = getPositiveGrid(indices,roiIndices);
[~,miniPosIndices] = ismember(positiveIndices,indices,'rows');

for i=1:size(positiveIndices,1)
    hold on;
    plot(positiveIndices(i,1:2:end),positiveIndices(i,2:2:end),'Color','g');
end

%imwrite(zproject, '274 control.tif');

