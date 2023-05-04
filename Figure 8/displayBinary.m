%% generate binary images of sound responses

[fname pname] = uigetfile({'*.mat';},'select matlab file of ROIs');
% load stimulation file and unmix
[fn2 dname2] = uigetfile(pname);

load([dname2 fn2]);
load([pname fname])
k = 1;
dFoF = [];
for x = 1:size(F,1)
    if iscell(x,1) == 1
        baseline = prctile((F(x,:)-0.7*Fneu(x,:)),40);
        dFoF(k,:) = smooth(((F(x,:)-0.7*Fneu(x,:))-baseline)./baseline,10);
        k = k + 1;
    else
    end
end

dFoF = dFoF';
toneDur = 300;% ms
frameRate = 15; 
before = 30; % frames before tone
numLevels = 4; % 0, 20, 40, 60 dB atten
nFreq = 9;
nCells = size(dFoF,2);
nTones = length(stimOnFrame);
nTonesperLevel = nTones/numLevels;

for x = 1:length(stimOnFrame) % 2 s before to 4 s after
    startTone(x) = stimOnFrame(x)-before;
    endTone(x) = stimOnFrame(x) + 3*before;
end

[attenSort, order] = sort(stimPlayedAtten);
startTone(:) = startTone(order);
endTone(:) = endTone(order);
stimPlayedID2(:) = stimPlayedID(order);

% 0 db atten unmixing
startTone0db = startTone(1:nTonesperLevel);
endTone0db = endTone(1:nTonesperLevel);
stimPlayed0db = stimPlayedID2(1:nTonesperLevel);
avgToneResp0db = struct();
[freqSort order2] = sort(stimPlayed0db);
startTone0dB2(:) = startTone0db(order2);
endTone0dB2(:) = endTone0db(order2);

% for z = 1:nCells
%     for x = 1:nFreq
%         toneResp = [];
%         for y = 1:nRep
%             toneResp(:,y) = [dFoF((startTone0dB2(5*(x-1)+y):endTone0dB2(5*(x-1)+y)),z)];
%         end
%         avgToneResp0db(x,z).cell = mean(toneResp,2);
%     end
% end
%% 

% unmix movie and generate averages 
% file = "F:\Calvin\Spontaneous activity in GJB2\2P AC sound
% P21\Data\220413_CJK\CJK507_mouse1_250um-018\suite2p\plane0\data.bin"; %
% cKO example 
file = 'F:\Calvin\Spontaneous activity in GJB2\2P AC sound P21\Data\220505 exp511 calvin cx26\CJK_mouse1_250_tonesexp511-018\suite2p\plane0\data.bin';
for x = 1:9
    for y = 1:nRep
        totalImg(:,:,:,y) = getFramesFromBinary(file,1024,1024,startTone0dB2(5*(x-1)+y),endTone0dB2(5*(x-1)+y));
    end
    avgToneImg0db{1,x} = mean(totalImg,4);
end

% plot 0db unmixed - to confirm
% figure
% hold on
% for z = 1:nCells
%         plot(avgToneResp0db(3,z).cell)
% end
%  ylim([0 15])
 

% show me the data! 
% concat = [];
% for i = 1:2
%    concat = [concat; avgToneImg0db{1,(4*(i-1)+1)} avgToneImg0db{1,(4*(i-1)+2)} avgToneImg0db{1,(4*(i-1)+3)} avgToneImg0db{1,(4*(i-1)+4)}];
% end
% h = implay(imresize(concat,0.1))
% h.Visual.ColorMap.UserRange = 1; h.Visual.ColorMap.UserRangeMin = 0; h.Visual.ColorMap.UserRangeMax = 1500;
 %% 

% show individual tones
% individual movies
rgb = [];
rgb(:,:,1,:) = avgToneImg0db{1,6}/1500;
h = implay(rgb);
%h.Visual.ColorMap.UserRange = 1; h.Visual.ColorMap.UserRangeMin = 0; h.Visual.ColorMap.UserRangeMax = 1000;
rgb(rgb > 1) = 0.99;
rgb(rgb < 0) = 0;
v = VideoWriter('24 khz 90 db cko2','Uncompressed AVI');
open(v);
writeVideo(v,rgb);
close(v);

%% unmix 20 db atten
%20 db atten unmixing
startTone20db = startTone(nTonesperLevel+1:1:nTonesperLevel*2);
endTone20db = endTone(nTonesperLevel+1:1:nTonesperLevel*2);
stimPlayed20db = stimPlayedID2(nTonesperLevel+1:1:nTonesperLevel*2);
avgToneResp20db = struct();
[freqSort order2] = sort(stimPlayed20db);
startTone20dB2(:) = startTone20db(order2);
endTone20dB2(:) = endTone20db(order2);
% for z = 1:nCells
%     for x = 1:nFreq
%         toneResp = [];
%         for y = 1:nRep
%             toneResp(:,y) = [dFoF((startTone20dB2(5*(x-1)+y):endTone20dB2(5*(x-1)+y)),z)];
%         end
%         avgToneResp20db(x,z).cell = mean(toneResp,2);
%     end
% end   

%   figure
% hold on
% for z = 1:nCells
%         plot(avgToneResp20db(5,z).cell)
% end
%  ylim([0 15])  


for x = 1:9
    for y = 1:nRep
        totalImg(:,:,:,y) = getFramesFromBinary(file,1024,1024,startTone20dB2(5*(x-1)+y),endTone20dB2(5*(x-1)+y));
    end
    avgToneImg20db{1,x} = mean(totalImg,4);
end
 
concat20 = [];
for i = 1:2
   concat20 = [concat20; avgToneImg20db{1,(4*(i-1)+1)} avgToneImg20db{1,(4*(i-1)+2)} avgToneImg20db{1,(4*(i-1)+3)} avgToneImg20db{1,(4*(i-1)+4)}];
end
h = implay(imresize(concat20,0.1))
h.Visual.ColorMap.UserRange = 1; h.Visual.ColorMap.UserRangeMin = 0; h.Visual.ColorMap.UserRangeMax = 1500;
 
%% single movies
rgb = [];
rgb(:,:,1,:) = avgToneImg20db{1,6}/1500;
h = implay(rgb);
%h.Visual.ColorMap.UserRange = 1; h.Visual.ColorMap.UserRangeMin = 0; h.Visual.ColorMap.UserRangeMax = 1000;
rgb(rgb > 1) = 0.99;
rgb(rgb < 0) = 0;
v = VideoWriter('24 khz 70 db con2','Uncompressed AVI');
open(v);
writeVideo(v,rgb);
close(v);

%% unmixing 40 dB atten

startTone40db = startTone((nTonesperLevel*2)+1:1:nTonesperLevel*3);
endTone40db = endTone((nTonesperLevel*2)+1:1:nTonesperLevel*3);
stimPlayed40db = stimPlayedID2((nTonesperLevel*2)+1:1:nTonesperLevel*3);
avgToneResp40db = struct();
[freqSort order2] = sort(stimPlayed40db);
startTone40dB2(:) = startTone40db(order2);
endTone40dB2(:) = endTone40db(order2);
for z = 1:nCells
    for x = 1:nFreq
        toneResp = [];
        for y = 1:nRep
            toneResp(:,y) = [dFoF((startTone40dB2(5*(x-1)+y):endTone40dB2(5*(x-1)+y)),z)];
        end
        avgToneResp40db(x,z).cell = mean(toneResp,2);
    end
end   

%   figure
% hold on
% for z = 1:nCells
%         plot(avgToneResp20db(5,z).cell)
% end
%  ylim([0 15])  


for x = 1:9
    for y = 1:nRep
        totalImg(:,:,:,y) = getFramesFromBinary(file,1024,1024,startTone40dB2(5*(x-1)+y),endTone40dB2(5*(x-1)+y));
    end
    avgToneImg40db{1,x} = mean(totalImg,4);
end
 
% concat20 = [];
% for i = 1:2
%    concat20 = [concat20; avgToneImg20db{1,(4*(i-1)+1)} avgToneImg20db{1,(4*(i-1)+2)} avgToneImg20db{1,(4*(i-1)+3)} avgToneImg20db{1,(4*(i-1)+4)}];
% end
% h = implay(imresize(concat20,0.1))
% h.Visual.ColorMap.UserRange = 1; h.Visual.ColorMap.UserRangeMin = 0; h.Visual.ColorMap.UserRangeMax = 1500;
%  

%% single movies
rgb = [];
rgb(:,:,1,:) = avgToneImg40db{1,6}/1500;
h = implay(rgb);
%h.Visual.ColorMap.UserRange = 1; h.Visual.ColorMap.UserRangeMin = 0; h.Visual.ColorMap.UserRangeMax = 1000;
rgb(rgb > 1) = 0.99;
rgb(rgb < 0) = 0;
v = VideoWriter('24 khz 50 db con2','Uncompressed AVI');
open(v);
writeVideo(v,rgb);
close(v);

%% unmixing 60 dB atten

startTone60db = startTone((nTonesperLevel*3)+1:1:nTonesperLevel*4);
endTone60db = endTone((nTonesperLevel*3)+1:1:nTonesperLevel*4);
stimPlayed60db = stimPlayedID2((nTonesperLevel*3)+1:1:nTonesperLevel*4);
avgToneResp60db = struct();
[freqSort order2] = sort(stimPlayed60db);
startTone60dB2(:) = startTone60db(order2);
endTone60dB2(:) = endTone60db(order2);
% for z = 1:nCells
%     for x = 1:nFreq
%         toneResp = [];
%         for y = 1:nRep
%             toneResp(:,y) = [dFoF((startTone60dB2(5*(x-1)+y):endTone60dB2(5*(x-1)+y)),z)];
%         end
%         avgToneResp60db(x,z).cell = mean(toneResp,2);
%     end
% end   

%   figure
% hold on
% for z = 1:nCells
%         plot(avgToneResp20db(5,z).cell)
% end
%  ylim([0 15])  


for x = 1:9
    for y = 1:nRep
        totalImg(:,:,:,y) = getFramesFromBinary(file,1024,1024,startTone60dB2(5*(x-1)+y),endTone60dB2(5*(x-1)+y));
    end
    avgToneImg60db{1,x} = mean(totalImg,4);
end
 %% single movies
rgb = [];
rgb(:,:,1,:) = avgToneImg60db{1,7}/1500;
h = implay(rgb);
%h.Visual.ColorMap.UserRange = 1; h.Visual.ColorMap.UserRangeMin = 0; h.Visual.ColorMap.UserRangeMax = 1000;
rgb(rgb > 1) = 0.99;
rgb(rgb < 0) = 0;
v = VideoWriter('32 khz 30 db con2','Uncompressed AVI');
open(v);
writeVideo(v,rgb);
close(v);