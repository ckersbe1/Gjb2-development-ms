dname = 'C:\Destop\tmem16a\ISCs';
[fn dname] = uigetfile([dname '\*.tif']);

img = loadTif([dname fn],8);
[m,n,t] = size(img);
offset = 8;
%% 
img1 = double(img(:,:,1:end-offset));
img2 = double(img(:,:,1+offset:end));

imgSubt = img2-img1;
imgMean = mean(imgSubt,3);
imgSTD = std(imgSubt,1,3);
imgThrP = imgMean + 3*imgSTD;
imgThrN = imgMean - 3*imgSTD;
imgThr = imgSubt > imgThrP | imgSubt < imgThrN;
meanPlot = squeeze(mean(mean(imgThr,2),1));
%implay(imgThr);

%%
dirN = ['M:\Bergles Lab Data\Papers\P2ry1\Figure 1 - ISCs\Crenations\' 'VG3 KO\'];
dirN = dname;
[pathstr, name, ext] = fileparts([dname fn]);
% writeTif(single(imgThr),[dirN 'thr_' fn],32);
%% find peaks and area
figure; plot(meanPlot);
startPt = input('Where would you like to start measurement for std?');
endPt = input('Where would you like to end measurement for std?');
%if contains(fn,'MRS2') %%use same STD for both videos
    stdMP = 4 * std(meanPlot(startPt:endPt),1,1);
%end
figure; findpeaks(meanPlot,'MinPeakProminence',stdMP)
[pks, locs] = findpeaks(meanPlot,'MinPeakProminence',stdMP);
m = size(locs,1);
areas = [];
figure;

scalingFactor = 3.4^2; % 1 um2 = 5.8 pixels/micron on Travis rig, 3.6 pixels/micron on HC rig
                            % 3.4 PIXELS/MICRON ON Calvin rig, at 1X Zoom
                            % on camera
[x,y,t] = size(imgThr);
indexToKill = []; crenImage = zeros(x,y,'logical');
for i=1:m
    tempImg = imgThr(:,:,locs(i));
    tempImg = bwareaopen(tempImg,6);
    tempImg = imgaussfilt(double(tempImg),12);
    vals = tempImg(tempImg > 0);
    thr = prctile(vals,20);
    tempImg = tempImg > thr;
    tempImg = bwareaopen(tempImg,2500);
    imagesc([tempImg imgThr(:,:,locs(i))]);
    keep = input(['Keep Event ' num2str(locs(i)) ' ?']);
    if keep
        areas = [areas; bwarea(tempImg)/(scalingFactor)];
        crenImage(:,:,end+1) = tempImg;
    else
        indexToKill = [indexToKill; i];
    end
end

locs(indexToKill) = [];
pks(indexToKill) = [];

Crens.name = name;
Crens.locs = locs;
Crens.pks = pks;
Crens.stdStart = startPt;
Crens.stdEnd = endPt;
Crens.areas = areas;
Crens.meanPlot = meanPlot;
Crens.imgSTD = imgSTD;
Crens.stdMP = stdMP;
Crens.scalingFactor = scalingFactor;
Crens.crenationImg = crenImage;
save([dirN 'CrenationData_' name '.mat'],'Crens');

[name]



% %% Group rerun of analysis
% WTdir = 'M:\Bergles Lab Data\Projects\In Vivo Imaging and VG3 Paper\In Vitro Experiments\Crenations\WT Littermate\';
% VG3dir = 'M:\Bergles Lab Data\Projects\In Vivo Imaging and VG3 Paper\In Vitro Experiments\Crenations\VG3 KO\';
% 
% list = dir([WTdir 'thr*.tif']);
% list2 = dir([WTdir 'Crenation*.mat']);
% m = size(list,1);
% for i=1:m
%     imgThr = loadTif([WTdir list(i).name]); load([WTdir list2(i).name]);
%     meanPlot = squeeze(mean(mean(imgThr,2),1));
%     figure(1); plot(meanPlot);
%     %startPt = input('Where would you like to start measurement for std?');
%     %endPt = input('Where would you like to end measurement for std?');
%     %stdMP = 4 * std(meanPlot(startPt:endPt),1,1);
%     [pks, locs] = findpeaks(meanPlot,'MinPeakProminence',.005);
%     locs(pks > 0.075) = []; %%whole frame movements filtered out
%     pks(pks > 0.075)  = [];
%     m = size(locs,1);
%     areas = [];
%     
%     indexToKill = [];
%     n = size(Crens.locs);
%     areas = []; figure;
%     for j=1:n
%         tempImg = imgThr(:,:,Crens.locs(j));
%         tempImg = bwareaopen(tempImg,12);
%         tempImg = imgaussfilt(double(tempImg),12);
%         vals = tempImg(tempImg > 0);
%         thr = prctile(vals,20);
%         tempImg = tempImg > thr;
%         tempImg2 = tempImg;
%         tempImg = bwareaopen(tempImg,2500);
%         figure(2); imagesc([tempImg tempImg2 imgThr(:,:,Crens.locs(j))])
%         keep = input('Keep Event?'); 
%         if keep
%             areas = [areas; bwarea(tempImg)/(5.8^2)];
%         else
%             indexToKill = [indexToKill; i];
%         end
%         
%         areas = [areas; bwarea(tempImg)/(5.8^2)];
% 
%     end
%     pks(indexToKill) = [];
%     locs(indexToKill) = [];
%     Crens.pks = pks;
%     Crens.locs = locs;
%     Crens.areas = areas;
%     save([WTdir list2(i).name],'Crens');
%     
% end
% 
% %% VG3 group
% list = dir([VG3dir 'thr*.tif']);
% list2 = dir([VG3dir 'Crenation*.mat']);
% m = size(list,1);
% for i=1:m
%     imgThr = loadTif([VG3dir list(i).name]); load([VG3dir list2(i).name]);
%     meanPlot = squeeze(mean(mean(imgThr,2),1));
%     figure(1); plot(meanPlot);
%     %startPt = input('Where would you like to start measurement for std?');
%     %endPt = input('Where would you like to end measurement for std?');
%     %stdMP = 4 * std(meanPlot(startPt:endPt),1,1);
%     [pks, locs] = findpeaks(meanPlot,'MinPeakProminence',.005);
%     locs(pks > 0.075) = []; %%whole frame movements filtered out
%     pks(pks > 0.075)  = [];
%     m = size(locs,1);
%     areas = [];
%     
%     indexToKill = [];
%     n = size(Crens.locs);
%     areas = []; figure;
%     for j=1:n
%         tempImg = imgThr(:,:,Crens.locs(j));
%         tempImg = bwareaopen(tempImg,12);
%         tempImg = imgaussfilt(double(tempImg),12);
%         vals = tempImg(tempImg > 0);
%         thr = prctile(vals,20);
%         tempImg = tempImg > thr;
%         tempImg2 = tempImg;
%         tempImg = bwareaopen(tempImg,2500);
%         figure(2); imagesc([tempImg tempImg2 imgThr(:,:,Crens.locs(j))])
%         keep = input('Keep Event?'); 
%         if keep
%             areas = [areas; bwarea(tempImg)/(5.8^2)];
%         else
%             indexToKill = [indexToKill; i];
%         end
%         
%         areas = [areas; bwarea(tempImg)/(5.8^2)];
% 
%     end
%     pks(indexToKill) = [];
%     locs(indexToKill) = [];
%     Crens.pks = pks;
%     Crens.locs = locs;
%     Crens.areas = areas;
%     save([VG3dir list2(i).name],'Crens');
%     
% end
% 
% %% Group rerun of analysis with loaded everything
% WTdir = 'M:\Bergles Lab Data\Projects\In Vivo Imaging and VG3 Paper\In Vitro Experiments\Crenations\WT Littermate\';
% VG3dir = 'M:\Bergles Lab Data\Projects\In Vivo Imaging and VG3 Paper\In Vitro Experiments\Crenations\VG3 KO\';
% 
% list = dir([WTdir 'thr*.tif']);
% list2 = dir([WTdir 'Crenation*.mat']);
% m = size(list,1);
% for i=1:m
%     imgThr = loadTif([WTdir list(i).name]); load([WTdir list2(i).name]);
%     meanPlot = squeeze(mean(mean(imgThr,2),1));
%     Crens.meanPlot = meanPlot;
%     figure; plot(Crens.meanPlot);
%     [pks, locs] = findpeaks(meanPlot,'MinPeakProminence',0.005);
%     locs(pks > 0.075) = [];
%     pks(pks > 0.075)  = [];
%     m = size(locs,1);
%     areas = [];
%     [x,y,t] = size(imgThr);
%     indexToKill = [];
%     n = size(Crens.locs);
%     areas = []; 
%     for j=1:n
%         tempImg = imgThr(:,:,Crens.locs(j));
%         tempImg = bwareaopen(tempImg,12);
%         tempImg = imgaussfilt(double(tempImg),12);
%         vals = tempImg(tempImg > 0);
%         thr = prctile(vals,20);
%         tempImg = tempImg > thr;
%         tempImg2 = tempImg;
%         tempImg = bwareaopen(tempImg,2500);
%         %figure(2); imagesc([tempImg tempImg2 imgThr(:,:,Crens.locs(j))])
%         areas = [areas; bwarea(tempImg)/(5.8^2)];
% 
%     end
%     pks(indexToKill) = [];
%     locs(indexToKill) = [];
%     Crens.totLocs = locs;
%     Crens.areas = areas;
%     mean(areas)
%     save([WTdir list2(i).name],'Crens');
%     
% end
% 
% %% VG3 group
% list = dir([VG3dir 'thr*.tif']);
% list2 = dir([VG3dir 'Crenation*.mat']);
% m = size(list,1);
% for i=1:m
%     imgThr = loadTif([VG3dir list(i).name]); load([VG3dir list2(i).name]);
%     meanPlot = squeeze(mean(mean(imgThr,2),1));
%     Crens.meanPlot = meanPlot;
%     figure; plot(Crens.meanPlot);
%     [pks, locs] = findpeaks(meanPlot,'MinPeakProminence',.005);
%     locs(pks > 0.075) = [];
%     size(locs)
%     Crens.std
%     pks(pks > 0.075)  = [];
%     m = size(locs,1);
%     areas = [];
%     [x,y,t] = size(imgThr);
%     indexToKill = [];
%     n = size(Crens.locs);
%     areas = []; 
%     for j=1:n
%         tempImg = imgThr(:,:,Crens.locs(j));
%         tempImg = bwareaopen(tempImg,12);
%         tempImg = imgaussfilt(double(tempImg),12);
%         vals = tempImg(tempImg > 0);
%         thr = prctile(vals,20);
%         tempImg = tempImg > thr;
%         tempImg2 = tempImg;
%         tempImg = bwareaopen(tempImg,2500);
%         %figure(2); imagesc([tempImg tempImg2 imgThr(:,:,Crens.locs(j))])
%         areas = [areas; bwarea(tempImg)/(5.8^2)];
% 
%     end
%     pks(indexToKill) = [];
%     locs(indexToKill) = [];
%     Crens.totLocs = locs;
%     Crens.areas = areas;
%     save([VG3dir list2(i).name],'Crens');
%     
% end
