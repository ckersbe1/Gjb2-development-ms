%% OHC spatial analysis

% load z projection
[fname pname] = uigetfile({'*.tif';'*.TIF';'*.tiff';'*.TIFF'},'select the still video tiff file');
cd(pname)
openFile = [pname fname];
imData = imread(openFile);

% threshold, binarize, identify cell centroids 
rawImage = imData;
B = wiener2(rawImage, [7 7]);
thresHold = graythresh(B); 
C = im2bw(B, thresHold); 

hold on

figure %shows raw image next to automatic thresholding image
subplot(1,2,1)
imshow(rawImage)
title('raw image')
subplot(1,2,2)
imshow (C)
title('thresholded image')
hold off   

xlabel('is this thresholding good? g = good, f = fail')

fprintf ('\n is this thresholding good? g = good, f = fail \n')
done = 0;
done1 = 0;
fignum = gcf;
while not(done)
    waitforbuttonpress
    pressed1 = get(fignum, 'CurrentCharacter');
    if pressed1 == 'g' %automatic thresholding is good, advances to counts
        fprintf( '\n automatic thresholding selected \n')
        done = 1;
    elseif pressed1 == 'f' %automatic thresholding failed, need manual thresholding and estimation of cell size
        
        thresholdLow = 0.3;
        while not(done1)
        fprintf(' \n manual thresholding selected \n')
        B1 = B;
        %manual thresholding
        figure;
        imshow(B)
        xlabel('adjust contrast. press any key once complete')
        hfig = imcontrast; %opens window to adjust contrast
        fprintf('\n press any button once complete \n')
        waitforbuttonpress
        
        window_min = str2double(get(findobj(hfig, 'tag', 'window min edit'), 'String')); %saves low threshold
        window_max = str2double(get(findobj(hfig, 'tag', 'window max edit'), 'String')); %saves high threshold
        Cnew = imadjust(B1,[window_min/255 window_max/255],[0 1]); % converts from 0-255 to 0-1
        thresHold2 = adaptthresh(Cnew,0.1); %thresholding algorithm
        Cnew = imbinarize(Cnew, thresHold2); %binarizes
        %convert modified image to workable form
        
        subplot(1,3,1) %plots raw, automatic, and manual side by side 
        imshow(rawImage)
        title('raw image')
        subplot(1,3,2)
        imshow(C)
        title('automatic threshold')
        subplot(1,3,3)
        imshow(Cnew)
        title('manual threshold')
        xlabel('Is this threshold better? Press "y" if good, "n" to repeat')
        
        fprintf('\n Is this threshold better? Press any button to advance \n')
        fignum1 = gcf;
        waitforbuttonpress
        pressed2 = get(fignum1, 'CurrentCharacter');
            if pressed2 == 'y' %thresholding good, advances to counts
                done1 = 1;
                lowThresh =  window_min %displays thresholds used to user
                highThresh = window_max %displays thresholds used to user
            elseif pressed2 == 'n' %thresholding not good, loops until user is satisfied
            
                done1 = 0;
            end
        
        end
        
        done = 1;
        C = Cnew;
    end
end

close all
imshow(C)


% Apply mask just over OHC region
  [freeMask freeX freeY] = roipoly;
  drawpolygon('Position',[freeX freeY],'FaceAlpha',0,'linewidth',1,'Color','m') 

  C(~freeMask) = 0;
  figure
  imshow(C)
  
% find cells, get centroid data
[B,L,N] = bwboundaries(C,'noholes'); % determines boundaries of cells B = boundary
imgStats = regionprops(C,'area','Centroid'); % gives center and area of each enclosed boundary
hold on
% remove areas < 50 - not cells
nCells = 0;
imgStats2 = struct();
for k = 1:length(B)
    if imgStats(k).Area < 50
        B{k} = NaN;
        imgStats(k).Centroid = NaN;
    else
        plot(imgStats(k).Centroid(1), imgStats(k).Centroid(2),'r+')
        nCells = nCells + 1;
        imgStats2(nCells).Centroid = imgStats(k).Centroid;
        imgStats2(nCells).Area = imgStats(k).Area;
    end
end
hold off

% are there any missing cells? select approximate centroid of missing cells
[x y] = getpts(gcf);
for n = 1:length(x) 
    imgStats2(nCells+n).Centroid = [x(n),y(n)];
    imgStats2(nCells+n).Area = NaN;
   % plot(x(n), y(n),'g+')
end

% number of lost "cells" = length(x) 
% generate random cell loss pattern, measure NN euclidean distance

rCells = round(rand(1,length(x))*nCells);
rCen = struct();
% get centroids of random cells 
for n = 1:length(rCells)
    rCen(n).Centroid = imgStats2(rCells(n)).Centroid;
   % plot(rCen(n).Centroid(1), rCen(n).Centroid(2),'b+')
end

% minimum euclidean distance (pixels) between lost cells
% sqrt((x2-x1)^2 + (y2-y1)^2)
distMin = [];
for k = 1:length(x)
    for n = 1:length(x)
        distMin(k,n) = sqrt((x(n)-x(k))^2+(y(n)-y(k))^2);
    end
end
    
% minimum distance between random cells
distMinRand = [];
for k = 1:length(rCen)
    for n = 1:length(rCen)
        distMinRand(k,n) = sqrt((rCen(n).Centroid(1)-rCen(k).Centroid(1))^2+(rCen(n).Centroid(2)-rCen(k).Centroid(2))^2);
    end
end

% minumum distance between points for rand and actual lost cells
distMin(distMin == 0) = NaN;
distMinRand(distMinRand == 0) = NaN;

minReal = min((distMin),[],1)
minRand = min((distMinRand),[],1)
% adjust pixels to microns ?!?

[fp,name,~] = fileparts([pname fname]);
save([fp '\' name '_randomized'],'minReal','minRand');


% representative img

figure
imshow(C) 
hold on
for k = 1:nCells
    plot(imgStats2(k).Centroid(1), imgStats2(k).Centroid(2),'r+')
end
for n = 1:length(rCells)
    plot(rCen(n).Centroid(1), rCen(n).Centroid(2),'b+')
end
for n = 1:length(x)
    plot(x(n), y(n),'g+')
end
hold off


       