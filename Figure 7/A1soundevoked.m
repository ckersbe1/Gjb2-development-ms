%[fname, dname] = uigetfile('M:\Bergles Lab Data\Projects\In vivo imaging\*.tif','Multiselect','on');
[fname, dname] = uigetfile('M:\Bergles Lab Data\Projects\In vivo imaging\*.tif','Multiselect','on');

[~,~,ext] = fileparts([dname, fname]);

%%tif performance 
if strcmp(ext,'.tif') 
    tic;
    img = loadTif([dname fname],16);
    toc;
elseif strcmp(ext,'.czi')
    tic;
    img = bfLoadTif([dname fname]);
    img = imrotate(img,180);
    toc;
else
    disp('Invalid image format.')
end

%%
toneImg = {};
imgorig = img;
img = normalizeImg(img,10,1);

%% Slow trigger
offset = 8;

%% load params
[fn2 dname2] = uigetfile(dname);
load([dname2 fn2]);
starttone = (params.baselineDur)/100; %frames 50frames, 5s
toneISI = params.stimInt/100; %frames - 35 frames, 3.5s
toneDur = params.stimDur/100; %frames -10 frames, 1s
timeBetweenStart = toneISI + toneDur;
before = 10; %frames before tone to analyze
[freqSort, order] = sort(params.freqs);
toneImg = {};
for i = 1:params.repeats
    for j = 1:params.numFreqs
       startImg = offset + starttone + timeBetweenStart*(j-1) + params.numFreqs * timeBetweenStart * (i-1) - before
       endImg = startImg + timeBetweenStart + before;
       toneImg{i,j} = img(:,:,startImg:endImg);
    end

    %sort order based on random ordering of frequencies presented
    startInd = 1 + (i-1)*params.numFreqs;
    endInd = startInd + params.numFreqs - 1;
    [freqSort, order] = sort(params.freqs(startInd:endInd));
    toneImg(i,:) = toneImg(i,order);
end

avgToneImg = {};
totalImg = [];
[mm,nn,tt] = size(toneImg{1,1});
ACsig = [];
 [ACmask] = getACmask(img);
 leftInd = find(ACmask);
for i = 1:params.numFreqs
    totalImg = zeros(mm,nn,tt,params.repeats);
    for j = 1:params.repeats
        wimg = toneImg{j,i};
        totalImg(:,:,:,j) = wimg;
        for k = 1:size(wimg,3)
            tempImg = wimg(:,:,k);
            ACsig(j,k,i) = mean(tempImg(leftInd));
        end
    end
    avgToneImg{1,i} = mean(totalImg,4);
end

% total fluorescence trace with time 
[mm,nn,tt] = size(img);
 [ACmask] = getACmask(img);
 leftInd = find(ACmask);
avgTrace = zeros(1,tt);
for k = 1:tt
    tempImg2 = img(:,:,k);
    avgTrace(k) = mean(tempImg2(leftInd));
end
figure;
% plot([1:tt],avgTrace)
% ylim([-0.1 1.25])
% xlim([750 1750])
% figQuality(gcf,gcf,[3,1.25])
%%stop
%makes Brady-bunch style splaying of images versus frequency presented
concat = [];
for i = 1:4
   concat = [concat; avgToneImg{1,(4*(i-1)+1)} avgToneImg{1,(4*(i-1)+2)} avgToneImg{1,(4*(i-1)+3)} avgToneImg{1,(4*(i-1)+4)}];
end
implay(concat)

%Single tone responses
%% 
% avgTones = [];
% for i = 1:13
%     avgTones(:,:,:,i) = avgToneImg{1,i};
% end
% a = avgTones(:,:,5:40,1);
% b = avgTones(:,:,5:40,4);
% c = avgTones(:,:,5:40,7);
% d = avgTones(:,:,5:40,10);
%  e = avgTones(:,:,5:40,13);
% %  f = avgTones(:,:,5:40,11);
% %   g = avgTones(:,:,5:40,13);
% % 
% rgb = [];
% rgb(:,:,1,:) = a;
% %implay(rgb);
% rgb(rgb > 1) = 0.99;
% rgb(rgb < 0) = 0;
% v = VideoWriter('3khz.avi','Uncompressed AVI');
% open(v);
% writeVideo(v,rgb);
% close(v);
% 
% rgb = [];
% rgb(:,:,1,:) = b;
% %implay(rgb);
% rgb(rgb > 1) = 0.99;
% rgb(rgb < 0) = 0;
% v = VideoWriter('6khz.avi','Uncompressed AVI');
% open(v);
% writeVideo(v,rgb);
% close(v);
% 
% rgb = [];
% rgb(:,:,1,:) = c;
% %implay(rgb);
% rgb(rgb > 1) = 0.99;
% rgb(rgb < 0) = 0;
% v = VideoWriter('12khz.avi','Uncompressed AVI');
% open(v);
% writeVideo(v,rgb);
% close(v);
% 
% rgb = [];
% rgb(:,:,1,:) = d;
% %implay(rgb);
% rgb(rgb > 1) = 0.99;
% rgb(rgb < 0) = 0;
% v = VideoWriter('24khz.avi','Uncompressed AVI');
% open(v);
% writeVideo(v,rgb);
% close(v);
% 
% rgb = [];
% rgb(:,:,1,:) = e;
% %implay(rgb);
% rgb(rgb > 1) = 0.99;
% rgb(rgb < 0) = 0;
% v = VideoWriter('48khz.avi','Uncompressed AVI');
% open(v);
% writeVideo(v,rgb);
% close(v);

% rgb = [];
% rgb(:,:,1,:) = f;
% %implay(rgb);
% rgb(rgb > 1) = 0.99;
% rgb(rgb < 0) = 0;
% v = VideoWriter('30khz.avi','Uncompressed AVI');
% open(v);
% writeVideo(v,rgb);
% close(v);
% 
% rgb = [];
% rgb(:,:,1,:) = g;
% %implay(rgb);
% rgb(rgb > 1) = 0.99;
% rgb(rgb < 0) = 0;
% v = VideoWriter('48khz.avi','Uncompressed AVI');
% open(v);
% writeVideo(v,rgb);
% close(v);
%% 

% Thresholding of evoked responses
% % 
 [ACmask] = getACmask2(img);
 leftInd = find(ACmask);
 % try fixed threshold, variable for frequency
 freqThreshP16 = [0.125 0.125 0.125 0.125 0.12 0.175 0.15 0.175 0.15 0.2 0.15 0.15 0.15 0.15 0.15 0.15]; %optimized for 379_3, 
 % ok for middle freq 369_5, 368_1 (try MOCO to clean up), 
 % not perfect for 416, but that one is tough. Good enough. 
 % fails for 368_3 - too low. 
 
 freqThreshP14 = [0.175 0.15 0.125 0.125 0.2 0.20 0.2 0.175 0.175 0.175 0.2 0.2 0.2 0.15 0.15 0.15]; % ?? 
% good for 418_1, 409_1, a little low for 418_3, high for 432_3, but only modest
% adjustments helped a lot


% can't use adaptive thresholding with MOCO - throws off

for i = 1:16
   % subplot(4,4,i)
    wimg = avgToneImg{1,i};
     for j = 1:size(wimg,3)
         tempImg = wimg(:,:,j);
        % avgAC(i,j) = mean(tempImg(leftInd));
     end
    %imagesc(mean(wimg(:,:,15:25),3));
    %colormap('default');
   % caxis([-0.1 .3]);
   B = wiener2(mean(wimg(:,:,15:25),3), [7 7]); % local filter
   %thresHold = graythresh(B); 
   %baseline = wiener2(mean(wimg(:,:,1:10),3)); %pre-sound image
   %thres = nanmean(baseline(leftInd));
   thres = max(max(B));
   
   C = im2bw(B, freqThreshP14(i)); % hard threshold? 0.2 worked well for controls 
   %C = adaptthresh(B, 0.05); 
   figure %shows raw image next to automatic thresholding image
    subplot(1,2,1)
    imagesc(mean(wimg(:,:,15:25),3));
    caxis([-0.1 .4]);
    title('raw image')
    subplot(1,2,2)
    imshow (C)
    activeToneArea(i) = mean(C(leftInd));
end

defaultDir = 'F:\Calvin\Spontaneous activity in GJB2\Widefield AC sound evoked\444_2 flfl';
save([defaultDir '\444_2_0dBActiveArea.mat'],'activeToneArea')

%% 

%  figure;
% lt_org = [255, 166 , 38]/255;
% dk_org = [255, 120, 0]/255;
% lt_blue = [50, 175, 242]/255;
% dk_blue = [0, 13, 242]/255;
% 
% 
%  for i = 1:16
%      subplot(4,4,i)
%     wimg = avgToneImg{1,i};
%     for j = 1:size(wimg,3)
%         tempImg = wimg(:,:,j);
%         % avgAC(i,j) = mean(tempImg(leftInd));
%     end
%         imagesc(mean(wimg(:,:,15:25),3));
%     colormap('default');
%    caxis([-0.1 .3]);
%  end
%  
%   [ACmask] = getACmask(img);
%  leftInd = find(ACmask);
%  for i = 1:16
%     wimg = avgToneImg{1,i};
%     for j = 1:size(wimg,3)
%         tempImg = wimg(:,:,j);
%          avgAC(i,j) = mean(tempImg(leftInd));
%     end
%  end
% % % save mean dFoF responses for whole AC ROI
% defaultDir = 'F:\Calvin\Spontaneous activity in GJB2\Widefield AC sound evoked\471_2 tecta flfl';
% save([defaultDir '\471_2_10dB.mat'],'avgAC')
% % 
% % % dFoF ROI responses to pure tones
% % 
% % 
% figure
% for i = 1:16
%     
%     subplot(1,16,i);
%     plot(avgAC(i,:),'Color',lt_blue,'LineWidth',2);
%     ylim([0 0.4])
% end
% 
% copyACsig = ACsig;
% for j = 1:size(ACsig,1)
%     copyACsig(j,:,:) = copyACsig(j,:,:) - (j) * 0.4;
% end
% 
% % % plot individual traces
% lt_org = [255, 166 , 38]/255;
% dk_org = [255, 120, 0]/255;
% lt_blue = [50, 175, 242]/255;
% dk_blue = [0, 13, 242]/255;
% sorted = sort(params.freqs);
% fig = figure;
% for i = 1:16
%     subplot(1,16,i);
%     plot(copyACsig(:,:,i)','Color','k');
%     hold on;
%     %plot(copySigR(:,:,i)','Color',lt_blue); 
%     plot(avgAC(i,:),'Color',lt_blue,'LineWidth',2);
%     ylim([-10*.4-.1 0.5]);
%     xlim([0 60]);
%     patch([10 10 20 20], [1 -6 -6 1],'k','EdgeColor','none','FaceAlpha',0.2);
%     yticklabels('');
%     title([sprintf('%0.3f',sorted(i*params.repeats)/1000) ' kHz']);
%     axis off;
% end
% 
% fig.Units = 'inches';
% fig.Position = [2 2 12 8];

%% 
% for i = 1:13 
%     subplot(4,4,i)
%     wimg = avgToneImg{1,i};
%     imagesc(mean(wimg(:,:,12:22),3));
%     caxis([-0.1 .3]);
% end
% 
% % A1 upper axis
% x1 = input('Rotate? (degrees)');
% i = 1; % 3 kHz
% wimg = avgToneImg{1,i};
% maxProj1 = mean(wimg(:,:,12:22),3);
% i = 11; % 30 khz %13
% wimg = avgToneImg{1,i};
% maxProj2 = mean(wimg(:,:,12:22),3);
% maxProj2 = maxProj2(:,:,1);
% maxProjMean = (maxProj1+maxProj2)./2;
% rotateMaxProj1 = imrotate(maxProj1, x1);
% rotateMaxProj2 = imrotate(maxProj2, x1);
% rotateMaxProjMean = imrotate(maxProjMean, x1);
% figure
% subplot(1,3,1)
% h_im = imagesc(rotateMaxProj1);
% subplot(1,3,2)
% h_im = imagesc(rotateMaxProj2);
% subplot(1,3,3)
% h_im = imagesc(rotateMaxProjMean);
% caxis([-0.1 0.4]);
% AC1 = imrect(gca,[100,100,25,450]);
% setResizable(AC1,0);
% wait(AC1);
% pos = getPosition(AC1);
% pos = int16(round(pos));
% 
% for i = 1:11 %1:13 % 30 kHz = 11
%     wimg = avgToneImg{1,i};
%     maxProj= max(wimg(:,:,12:22),[],3);
%     rotateMaxProj = imrotate(maxProj, x1);
%     AC1rect = rotateMaxProj(pos(2):pos(2)+pos(4)-1,pos(1):pos(1)+pos(3)-1,:);
%     meanAC1(i).profileraw = squeeze(mean(AC1rect,2));
%     meanAC1(i).profilenorm = meanAC1(i).profileraw - min(meanAC1(i).profileraw); % normalization
%     subplot(4,4,i)
%     plot(meanAC1(i).profileraw)
%     ylim([0 0.4])
% end

% save profiles 
%defaultDir = 'F:\Calvin\Spontaneous activity in GJB2\Widefield AC sound evoked\';
%save([defaultDir '452_1_0dBprofile3khz.mat'],'meanAC1','x1')