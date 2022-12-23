[fn dname] = uigetfile({'*.tif';'*.TIF';'*.tiff';'*.TIFF'});
img = loadTif([dname fn], 16);
[pathStr, name, ext] = fileparts([dname fn]);

%%
toneImg = {};
imgorig = img;
img = normalizeImg(img,10,1);
[LICmask, RICmask,ctxmask] = getROImasks(img);
leftInd = find(LICmask);
rightInd = find(RICmask); 

%% load params
[fn2 dname2] = uigetfile(dname);
load([dname2 fn2]);
offset = 0;
starttone = params.baselineDur/100; %frames %fixed bug here
toneISI = params.stimInt/100; %frames
toneDur = params.stimDur/100; %frames
timeBetweenStart = toneISI + toneDur;
before = 10; %frames before tone to analyze

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
LICsig = [];
RICsig = [];
for i = 1:params.numFreqs
    totalImg = zeros(mm,nn,tt,params.repeats);
    for j = 1:params.repeats
        wimg = toneImg{j,i};
        totalImg(:,:,:,j) = wimg;
        for k = 1:size(wimg,3)
            tempImg = wimg(:,:,k);
            LICsig(j,k,i) = mean(tempImg(leftInd));
            RICsig(j,k,i) = mean(tempImg(rightInd));
        end
    end
    avgToneImg{1,i} = mean(totalImg,4);
end
%%stop
%makes Brady-bunch style splaying of images versus frequency presented
concat = [];
for i = 1:4
   concat = [concat; avgToneImg{1,(4*(i-1)+1)} avgToneImg{1,(4*(i-1)+2)} avgToneImg{1,(4*(i-1)+3)} avgToneImg{1,(4*(i-1)+4)}];
end
implay(concat)




%% plot trace data data
figure;
for i = 1:16
    subplot(1,16,i)
    wimg = avgToneImg{1,i};
    for j = 1:size(wimg,3)
        tempImg = wimg(:,:,j);
        avgLIC(i,j) = mean(tempImg(leftInd));
        avgRIC(i,j) = mean(tempImg(rightInd));
    end
    imagesc(mean(wimg(:,:,15:20),3));
    %colormap(gfb);
    caxis([-0.1 0.75]);
end
% 
% save mean dFoF responses for whole IC ROI
%defaultDir = 'F:\Calvin\Spontaneous activity in GJB2\Widefield IC sound evoked\339_5 flfl';
%save([defaultDir '\339_5_60db.mat'],'LICsig','RICsig','avgRIC','avgLIC')

%%single traces tones
copySigR = RICsig;
copySigL = LICsig;
for j = 1:size(RICsig,1)
    copySigR(j,:,:) = copySigR(j,:,:) - (j) * 0.4;
    copySigL(j,:,:) = copySigL(j,:,:) - (j) * 0.4;
end

lt_org = [255, 166 , 38]/255;
dk_org = [255, 120, 0]/255;
lt_blue = [50, 175, 242]/255;
dk_blue = [0, 13, 242]/255;
sorted = sort(params.freqs);
% fig = figure;
% for i = 1:16
%     subplot(1,16,i);
%     plot(copySigL(:,:,i)','Color',lt_org);
%     hold on;
%     plot(copySigR(:,:,i)','Color',lt_blue); 
%     plot(avgLIC(i,:),'Color',lt_org,'LineWidth',2);
%     plot(avgRIC(i,:),'Color',lt_blue,'LineWidth',2);
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

% calvin plot 
figure
for i = 1:16
    
    subplot(1,16,i);
    plot(avgLIC(i,:),'Color',lt_org,'LineWidth',2);
    hold on
    plot(avgRIC(i,:),'Color',lt_blue,'LineWidth',2);
    ylim([0 0.3])
end
% %% evoked bandwidth analysis
% 
% % for each freq, display img of evoked response, draw line, measure
% 
% %% image display 
% % % 
avgTones = [];
for i = 1:16
    avgTones(:,:,:,i) = avgToneImg{1,i};
end
a = avgTones(:,:,5:40,1);
b = avgTones(:,:,5:40,4);
c = avgTones(:,:,5:40,7);
d = avgTones(:,:,5:40,10);
e = avgTones(:,:,5:40,13);
f = avgTones(:,:,5:40,6);
g = avgTones(:,:,5:40,8);
rgb = [];
rgb(:,:,1,:) = a;

rgb(rgb > 1) = 0.99;
rgb(rgb < 0) = 0;
v = VideoWriter('3.avi','Uncompressed AVI');
open(v);
writeVideo(v,rgb);
close(v);

rgb = [];
rgb(:,:,1,:) = f;

rgb(rgb > 1) = 0.99;
rgb(rgb < 0) = 0;
v = VideoWriter('9_5.avi','Uncompressed AVI');
open(v);
writeVideo(v,rgb);
close(v);


rgb = [];
rgb(:,:,1,:) = b;
%implay(rgb);
rgb(rgb > 1) = 0.99;
rgb(rgb < 0) = 0;
v = VideoWriter('6.avi','Uncompressed AVI');
open(v);
writeVideo(v,rgb);
close(v);

rgb = [];
rgb(:,:,1,:) = c;
%implay(rgb);
rgb(rgb > 1) = 0.99;
rgb(rgb < 0) = 0;
v = VideoWriter('12.avi','Uncompressed AVI');
open(v);
writeVideo(v,rgb);
close(v);

rgb = [];
rgb(:,:,1,:) = d;

rgb(rgb > 1) = 0.99;
rgb(rgb < 0) = 0;
v = VideoWriter('24.avi','Uncompressed AVI');
open(v);
writeVideo(v,rgb);
close(v);

rgb = [];
rgb(:,:,1,:) = e;

rgb(rgb > 1) = 0.99;
rgb(rgb < 0) = 0;
v = VideoWriter('48.avi','Uncompressed AVI');
open(v);
writeVideo(v,rgb);
close(v);

rgb = [];
rgb(:,:,1,:) = g;

rgb(rgb > 1) = 0.99;
rgb(rgb < 0) = 0;
v = VideoWriter('15.avi','Uncompressed AVI');
open(v);
writeVideo(v,rgb);
close(v);

%% spatial analysis

% align to 6 kHz at 0dB atten
% Display all freq responses
% figure;
% for i = 1:16
%     subplot(4,4,i)
%     wimg = avgToneImg{1,i};
%     imagesc(mean(wimg(:,:,12:22),3));
%     caxis([-0.1 .3]);
% end
% 
% x = input('Rotate? (degrees)');
% i = 1;
% wimg = avgToneImg{1,i};
% maxProj = mean(wimg(:,:,12:22),3);
% rotateMaxProj = imrotate(maxProj, x);
% figure
% h_im = imagesc(rotateMaxProj);
% %colormap gfb;
% caxis([-0.1 0.4]);
% LIC = imrect(gca,[100,100,25,250]);
% setResizable(LIC,0);
% wait(LIC);
% pos = getPosition(LIC);
% pos = int16(round(pos));
% meanLIC = struct();
% for i = 1:12
%     wimg = avgToneImg{1,i};
%     maxProj= max(wimg(:,:,12:22),[],3);
%    % imagesc(maxProj)
%     rotateMaxProj = imrotate(maxProj, x);
%     LICrect = rotateMaxProj(pos(2):pos(2)+pos(4)-1,pos(1):pos(1)+pos(3)-1,:);
%     meanLIC(i).profileraw = squeeze(mean(LICrect,2));
%     meanLIC(i).profilenorm = meanLIC(i).profileraw - min(meanLIC(i).profileraw); % normalization
%     subplot(3,4,i)
%     plot(meanLIC(i).profileraw)
%     ylim([0 0.4])
% end
% 
% %save profile 
% defaultDir = 'F:\Calvin\Spontaneous activity in GJB2\Widefield IC sound evoked\350_2 tecta flfl\';
%  save([defaultDir '350_2_0dBprofilecenter.mat'],'meanLIC')





