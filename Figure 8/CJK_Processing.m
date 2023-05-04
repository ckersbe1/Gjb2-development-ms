addpath("MATLAB Functions\")

test = dir("Data\**\Fall.mat")
expDirs = getExpDirs(test)
data = struct()

for i = 1:size(expDirs,2)
    data(i).dir = expDirs{i};
    [maxResponses, averageResponses] = getMaxResponses(expDirs{i});
    [numC, numF, numA] = size(maxResponses);
    data(i).maxResponse = maxResponses;
    data(i).averageResponses = averageResponses;
    data(i).maxResponseReshape = reshape(maxResponses,numC,numF*numA)
    switch i
        case {1,3,5}
            data(i).genoKO = ones(numC,1);
        case {2,4,6}
            data(i).genoKO = zeros(numC,1);
    end
     switch i
        case {1}
            data(i).mouse = ones(numC,1);
        case {2}
            data(i).mouse = ones(numC,1)*2;
        case {3}
            data(i).mouse = ones(numC,1)*3;
        case {4}
            data(i).mouse = ones(numC,1)*4;
        case {5}
            data(i).mouse = ones(numC,1)*5;
        case {6}
            data(i).mouse = ones(numC,1)*6;
    end


end

%%
[~,score] = pca(vertcat(data.maxResponseReshape));
genos = vertcat(data.genoKO)

control = score(genos==0,:);
ko = score(genos==1,:);
%% 

%3d plot
figure;
scatter3(ko(:,1),ko(:,2),ko(:,3),5,'.','r'); hold on;
scatter3(control(:,1),control(:,2),control(:,3),5,'.','k');
xlim([-2 6])
ylim([-6 6])
zlim([-3 5])
exportgraphics(gcf,'vectorfig.pdf','ContentType','vector')
%%
%2d plot
figure;
scatter(ko(:,1),ko(:,2),20,'.','r'); hold on;
scatter(control(:,1),control(:,2),20,'.','k');
xlim([-4 12])
ylim([-8 10])

%% interesting things
cellNums = find(score(:,1) <-2);
avg_response = vertcat(data.averageResponses);
plotMultiCellAvg(avg_response,cellNums)

%% All cells 
cellNums = find(score(:,1) > -1.5 & score(:,1) < -0.5 & score(:,2) < 0 & score(:,2) > -1 & genos == 1);
avg_response = vertcat(data.averageResponses);
plotMultiCellAvg(avg_response,cellNums)

%%
plotGenoResponse(avg_response,genos)

%% %quantify maximum evoked amplitude and get BF
max_response = vertcat(data.maxResponse);
%plotResponse(avg_response,10)
mouse_num = vertcat(data.mouse);
cellNums = find(genos == 1 & mouse_num == 5);
count = 1;
minAmpLevel = 0.75;
maxAmpcKO = []; maxFrcKO = [];
for cell = 1:length(cellNums)
        [tempAmp tempLevel] = max(max(max_response(cellNums(cell),:,:)));
        [tempAmp tempFr] = max(max(permute(max_response(cellNums(cell),:,:),[1 3 2])));
        maxFrAll(cellNums(cell)) = tempFr;
        maxAmpAll(cellNums(cell)) = tempAmp;
        maxLevelAll(cellNums(cell)) = tempLevel;
        if sum(sum(max_response(cellNums(cell),:,:)>minAmpLevel)) >= 2 && (tempLevel == 1 || tempLevel == 2)
            maxAmpcKO(count) = tempAmp; maxFrcKO(count) = tempFr;
            count = count + 1;
        end
end
figure;
s = swarmchart(maxFrcKO,maxAmpcKO,5,'r','filled')
s.XJitterWidth = 0.8;
figQuality(gcf,gca,[1.75 1.75])
maxAmpcon = []; maxFrcon = [];
cellNums = find(genos == 0 & mouse_num == 6);
count = 1;
for cell = 1:length(cellNums)
        [tempAmp tempLevel] = max(max(max_response(cellNums(cell),:,:)));
        [tempAmp tempFr] = max(max(permute(max_response(cellNums(cell),:,:),[1 3 2])));
       maxFrAll(cellNums(cell)) = tempFr;
        maxAmpAll(cellNums(cell)) = tempAmp;
        maxLevelAll(cellNums(cell)) = tempLevel;
        if sum(sum(max_response(cellNums(cell),:,:)>minAmpLevel)) >= 2 && (tempLevel == 1 || tempLevel == 2)
            maxAmpcon(count) = tempAmp; maxFrcon(count) = tempFr;
            count = count + 1;
        end
end
figure
s = swarmchart(maxFrcon,maxAmpcon,5,'k','filled')
s.XJitterWidth = 0.8;
figQuality(gcf,gca,[1.75 1.75])

%% 
% histogram of BF distribution

% all cells
binLim = [1:1:10];
bfcon1nm = histcounts(maxFrcon,binLim,'Normalization','probability');
bfcon1 = histcounts(maxFrcon,binLim);
bfcon2nm = histcounts(maxFrcon,binLim,'Normalization','probability');
bfcon2 = histcounts(maxFrcon,binLim);
bfcon3nm = histcounts(maxFrcon,binLim,'Normalization','probability');
bfcon3 = histcounts(maxFrcon,binLim);
%bfcon2 = histcounts(bestFcon2,binLim,'Normalization','probability');
%bfcon3 = histcounts(bestFcon3,binLim,'Normalization','probability');
bfcko1nm = histcounts(maxFrcKO,binLim,'Normalization','probability');
bfcko1 = histcounts(maxFrcKO,binLim);
bfcko2nm = histcounts(maxFrcKO,binLim,'Normalization','probability');
bfcko2 = histcounts(maxFrcKO,binLim);
bfcko3nm = histcounts(maxFrcKO,binLim,'Normalization','probability');
bfcko3 = histcounts(maxFrcKO,binLim);
%%
meanbfcon = mean([bfcon1;bfcon2;bfcon3],1);
meanbfcko = mean([bfcko1;bfcko2;bfcko3],1);
stdbfcon = std([bfcon1;bfcon2;bfcon3],1)/sqrt(3);
stdbfcko = std([bfcko1;bfcko2;bfcko3],1)/sqrt(3);
binLim2 = [1.5:1:9.5];
figure;
%binY = log10([0 3:1:24]);
h1 = histogram('BinCounts', meanbfcon, 'BinEdges', binLim,'FaceAlpha',0.6, 'FaceColor','k','EdgeAlpha',0); hold on;
h2 = histogram('BinCounts', meanbfcko, 'BinEdges',binLim ,'FaceAlpha',0.6,'FaceColor','r','EdgeAlpha',0); hold on;
errorbar(binLim2,meanbfcon,stdbfcon,'vertical','linestyle','none','LineWidth',1.5,'Color','k','CapSize',0);
errorbar(binLim2,meanbfcko,stdbfcko,'vertical','linestyle','none','LineWidth',1.5,'Color','r','CapSize',0);
%ylim([0 0.4]);
%yticks([0:0.1:1]);
ylim([0 250]);
xlim([0 10.5]);
xticks(1.5:2:9.5);
%xtickangle([45]);
%set(gca, 'xscale','log')
xticklabels({'4','8','16','32','64'})
xlabel('Best frequency (kHz)');
ylabel('Number of cells');
figQuality(gcf,gca,[1.8 1.8])
%print(gcf,'-dpdf')
exportgraphics(gcf,'BFdist.pdf','ContentType','vector')


% normalized
meanbfcon = mean([bfcon1nm;bfcon2nm;bfcon3nm],1);
meanbfcko = mean([bfcko1nm;bfcko2nm;bfcko3nm],1);
stdbfcon = std([bfcon1nm;bfcon2nm;bfcon3nm],1)/sqrt(3);
stdbfcko = std([bfcko1nm;bfcko2nm;bfcko3nm],1)/sqrt(3);
binLim2 = [1.5:1:9.5];
figure;
%binY = log10([0 3:1:24]);
h1 = histogram('BinCounts', meanbfcon, 'BinEdges', binLim,'FaceAlpha',0.6, 'FaceColor','k','EdgeAlpha',0); hold on;
h2 = histogram('BinCounts', meanbfcko, 'BinEdges',binLim ,'FaceAlpha',0.6,'FaceColor','r','EdgeAlpha',0); hold on;
errorbar(binLim2,meanbfcon,stdbfcon,'vertical','linestyle','none','LineWidth',1.5,'Color','k','CapSize',0);
errorbar(binLim2,meanbfcko,stdbfcko,'vertical','linestyle','none','LineWidth',1.5,'Color','r','CapSize',0);
ylim([0 0.4]);
yticks([0:0.1:1]);
xlim([0 11]);
xticks(1:2:9);
%xtickangle([45]);
%set(gca, 'xscale','log')
xticklabels({'4','8','16','32','64'})
xlabel('Best frequency (kHz)');
ylabel('Probability');
figQuality(gcf,gca,[1.8 1.8])
%print(gcf,'-dpdf')
exportgraphics(gcf,'BFdistNorm.pdf','ContentType','vector')

bfAllcon = [maxFrcon];
bfAllcko = [maxFrcKO];
length(bfAllcon)
length(bfAllcko)
% CDF
figure
h1 = cdfplot(bfAllcko);
hold on
h2 = cdfplot(bfAllcon);
h1.Color = 'r';
h2.Color = 'k';
h1.LineWidth = 1;
h2.LineWidth = 1;
xlabel('best freq distribution');
ylabel('CDF');
xlim([0 9])
%xticks([0 1 2 3 4])
figQuality(gcf,gca,[1.75 2])

[h p] = kstest2(bfAllcon,bfAllcko);
p


%%
% get means by BF, traces by BF

% 4 kHz
cellNum1con = find(maxFrcon == 1);
    maxAmp4con = maxAmpcon(cellNum1con);
    medianAmp4con = median(maxAmp4con); stdAmp4con = std(maxAmp4con);
cellNum1cko = find(maxFrcKO == 1);
    maxAmp4cKO = maxAmpcKO(cellNum1cko);
    medianAmp4cKO = median(maxAmp4cKO); stdAmp4cKO = std(maxAmp4cKO);
       h1 = lillietest(maxAmp4con);
       h2 = lillietest(maxAmp4cKO);
       
       if h1 == 1 || h2 == 1
           disp ('not normal')
           [p h] = ranksum(maxAmp4con,maxAmp4cKO);
       else
        [h,p] = ttest2(maxAmp4con,maxAmp4cKO);
        pt(5) = p;
        
       end
        disp(p);
        disp(h);
% 6 kHz
cellNum2con = find(maxFrcon == 2);
    maxAmp6con = maxAmpcon(cellNum2con);
    medianAmp6con = median(maxAmp6con); stdAmp4con = std(maxAmp6con);
cellNum2cko = find(maxFrcKO == 2);
    maxAmp6cKO = maxAmpcKO(cellNum2cko);
    medianAmp6cKO = median(maxAmp6cKO); stdAmp6cKO = std(maxAmp6cKO);
       h1 = lillietest(maxAmp6con);
       h2 = lillietest(maxAmp6cKO);
       
       if h1 == 1 || h2 == 1
           disp ('not normal')
           [p h] = ranksum(maxAmp6con,maxAmp6cKO);
       else
        [h,p] = ttest2(maxAmp6con,maxAmp6cKO);
        pt(5) = p;
        
       end
        disp(p);
        disp(h);
% 8 kHz
cellNum3con = find(maxFrcon == 3);
    maxAmp8con = maxAmpcon(cellNum3con);
    medianAmp8con = median(maxAmp8con); stdAmp8con = std(maxAmp8con);
cellNum3cko = find(maxFrcKO == 3);
    maxAmp8cKO = maxAmpcKO(cellNum3cko);
    medianAmp8cKO = median(maxAmp8cKO); stdAmp8cKO = std(maxAmp8cKO);
       h1 = lillietest(maxAmp8con);
       h2 = lillietest(maxAmp8cKO);
       
       if h1 == 1 || h2 == 1
           disp ('not normal')
           [p h] = ranksum(maxAmp8con,maxAmp8cKO);
       else
        [h,p] = ttest2(maxAmp8con,maxAmp8cKO);
        pt(5) = p;
        
       end
        disp(p);
        disp(h);


% 12 kHz
cellNum4con = find(maxFrcon == 4);
    maxAmp12con = maxAmpcon(cellNum4con);
    medianAmp12con = median(maxAmp12con); stdAmp12con = std(maxAmp12con);
cellNum4cko = find(maxFrcKO == 4);
    maxAmp12cKO = maxAmpcKO(cellNum4cko);
    medianAmp12cKO = median(maxAmp12cKO); stdAmp12cKO = std(maxAmp12cKO);
       h1 = lillietest(maxAmp12con);
       h2 = lillietest(maxAmp12cKO);
       
       if h1 == 1 || h2 == 1
           disp ('not normal')
           [p h] = ranksum(maxAmp12con,maxAmp12cKO);
       else
        [h,p] = ttest2(maxAmp12con,maxAmp12cKO);
        pt(5) = p;
        
       end
        disp(p);
        disp(h);

% 16 kHz
cellNum5con = find(maxFrcon == 5);
    maxAmp16con = maxAmpcon(cellNum5con);
    medianAmp16con = median(maxAmp16con); stdAmp16con = std(maxAmp16con);
cellNum5cko = find(maxFrcKO == 5);
    maxAmp16cKO = maxAmpcKO(cellNum5cko);
    medianAmp16cKO = median(maxAmp16cKO); stdAmp16cKO = std(maxAmp16cKO);
       h1 = lillietest(maxAmp16con);
       h2 = lillietest(maxAmp16cKO);
       
       if h1 == 1 || h2 == 1
           disp ('not normal')
           [p h] = ranksum(maxAmp16con,maxAmp16cKO);
       else
        [h,p] = ttest2(maxAmp16con,maxAmp16cKO);
        pt(5) = p;
        
       end
        disp(p);
        disp(h);

% 24 kHz
cellNum6con = find(maxFrcon == 6);
    maxAmp24con = maxAmpcon(cellNum6con);
    medianAmp24con = median(maxAmp24con); stdAmp24con = std(maxAmp24con);
cellNum6cko = find(maxFrcKO == 6);
    maxAmp24cKO = maxAmpcKO(cellNum6cko);
    medianAmp24cKO = median(maxAmp24cKO); stdAmp24cKO = std(maxAmp24cKO);
       h1 = lillietest(maxAmp24con);
       h2 = lillietest(maxAmp24cKO);
       
       if h1 == 1 || h2 == 1
           disp ('not normal')
           [p h] = ranksum(maxAmp24con,maxAmp24cKO);
       else
        [h,p] = ttest2(maxAmp24con,maxAmp24cKO);
        pt(5) = p;
        
       end
        disp(p);
        disp(h);

% 32 kHz
cellNum7con = find(maxFrcon == 7);
    maxAmp32con = maxAmpcon(cellNum7con);
    medianAmp32con = median(maxAmp32con); stdAmp32con = std(maxAmp32con);
cellNum7cko = find(maxFrcKO == 7);
    maxAmp32cKO = maxAmpcKO(cellNum7cko);
    medianAmp32cKO = median(maxAmp32cKO); stdAmp32cKO = std(maxAmp32cKO);
       h1 = lillietest(maxAmp32con);
       h2 = lillietest(maxAmp32cKO);
       
       if h1 == 1 || h2 == 1
           disp ('not normal')
           [p h] = ranksum(maxAmp32con,maxAmp32cKO);
       else
        [h,p] = ttest2(maxAmp32con,maxAmp32cKO);
        pt(5) = p;
        
       end
        disp(p);
        disp(h);
% 48 kHz
cellNum8con = find(maxFrcon == 8);
    maxAmp48con = maxAmpcon(cellNum8con);
    medianAmp48con = median(maxAmp48con); stdAmp48con = std(maxAmp48con);
cellNum8cko = find(maxFrcKO == 8);
    maxAmp48cKO = maxAmpcKO(cellNum8cko);
    medianAmp48cKO = median(maxAmp48cKO); stdAmp48cKO = std(maxAmp48cKO);
       h1 = lillietest(maxAmp32con);
       h2 = lillietest(maxAmp32cKO);
       
       if h1 == 1 || h2 == 1
           disp ('not normal')
           [p h] = ranksum(maxAmp48con,maxAmp48cKO);
       else
        [h,p] = ttest2(maxAmp48con,maxAmp48cKO);
        pt(5) = p;
        
       end
        disp(p);
        disp(h);


%% 

% swarmchart side by side
maxFrcon2 = (maxFrcon).*2-1;
maxFrcKO2 = (maxFrcKO).*2;

meanMarkSize = 15;
color1 = 'k';
% full swarm
figure
s = swarmchart(maxFrcon2,maxAmpcon,3,'k','filled')
s.XJitterWidth = 0.8;
hold on
s1 = swarmchart(maxFrcKO2,maxAmpcKO,3,'r','filled')
s1.XJitterWidth = 0.8;
plot([0.5 1.5], [medianAmp4con medianAmp4con],'k','LineWidth',2)
plot([1.5 2.5], [medianAmp4cKO medianAmp4cKO],'r','LineWidth',2)
plot([2.5 3.5], [medianAmp6con medianAmp6con],'k','LineWidth',2)
plot([3.5 4.5], [medianAmp6cKO medianAmp6cKO],'r','LineWidth',2)
plot([4.5 5.5], [medianAmp8con medianAmp8con],'k','LineWidth',2)
plot([5.5 6.5], [medianAmp8cKO medianAmp8cKO],'r','LineWidth',2)
plot([6.5 7.5], [medianAmp12con medianAmp12con],'k','LineWidth',2)
plot([7.5 8.5], [medianAmp12cKO medianAmp12cKO],'r','LineWidth',2)
plot([8.5 9.5], [medianAmp16con medianAmp16con],'k','LineWidth',2)
plot([9.5 10.5], [medianAmp16cKO medianAmp16cKO],'r','LineWidth',2)
plot([10.5 11.5], [medianAmp24con medianAmp24con],'k','LineWidth',2)
plot([11.5 12.5], [medianAmp24cKO medianAmp24cKO],'r','LineWidth',2)
plot([12.5 13.5], [medianAmp32con medianAmp32con],'k','LineWidth',2)
plot([13.5 14.5], [medianAmp32cKO medianAmp32cKO],'r','LineWidth',2)
plot([14.5 15.5], [medianAmp48con medianAmp48con],'k','LineWidth',2)
plot([15.5 16.5], [medianAmp48cKO medianAmp48cKO],'r','LineWidth',2)

%% plot mean trace 24 kHz
avg_response = vertcat(data.averageResponses);
%cellNums = find(maxFrAll' == 6 & genos == 0 & maxAmpAll' > minAmpLevel);
%plotMultiCellAvg(avg_response,cellNums,'k')

%cellNumscko = find(maxFrAll' == 6 & genos == 1 & maxAmpAll' > minAmpLevel);
%plotMultiCellAvg(avg_response,cellNumscko,'r')

% overlay average response
% figure;
% plotSingleTrace(avg_response,cellNums,'k',1,6)
% hold on
% plotSingleTrace(avg_response,cellNumscko,'r',1,6)
% figQuality(gcf,gca,[0.75 1.5])
% print(gcf,'-dpdf')
% exportgraphics(gcf,'vectorfig.pdf','ContentType','vector')
BFminAmpLevel = 1;
% plot all mean responses - all freqs
for i = 1:9
cellNums = find(maxFrAll' == i & genos == 0 & maxAmpAll' > BFminAmpLevel);
cellNumscko = find(maxFrAll' == i & genos == 1 & maxAmpAll' > BFminAmpLevel);
subplot(1,9,i)
plotSingleTrace(avg_response,cellNums,'k',1,i)
hold on
plotSingleTrace(avg_response,cellNumscko,'r',1,i)
figQuality(gcf,gca,[0.75 1.5])
end
figQuality(gcf,gca,[4.5  1])
%exportgraphics(gcf,'BFampsmin1.pdf','ContentType','vector')

%% 
% tuning analysis - bandwidth
freqsFile = logspace(log10(4000),log10(64000),9);
octFreqsFile  = log2(freqsFile)-log2(min(freqsFile));
minAmpLeveltuning = 1; % at least 1 file > 1
minAmpLevel = 0.75; % at least 2 > 0.75
bandWgauscon = []; bandWgauscko = [];
%     % fit gaussian to max amplitudes by level
cellNums = find(genos == 0 & maxAmpAll' > minAmpLeveltuning);
count = 1;

cellQualcon = [];
for x = 1:length(cellNums)
    if sum(sum(max_response(cellNums(x),:,:)>minAmpLevel)) >= 2
        
        cellQualcon(x) = 1;
         try
         f = fit(octFreqsFile.',max_response(cellNums(x),:,1).','gauss1'); 
         bandWgauscon(count) = 2.355*f.c1;
         
    % figure
    % plot(f,octFreqsFile,max_response(cellNums(x),:,1))
            if bandWgauscon(count) > 4 || bandWgauscon(count) == 0 % failure of gaussian estimate
                bandWgauscon(count) = NaN;
            end
        catch
      fprintf('error encountered index:%d\n', x)
      bandWgauscon(x) = NaN;
         end 
         count = count + 1;
    else
        cellQualcon(x) = 0;
    end
    % figure
     %plot(f,octFreqsFile,max_response(1,:,1))
end
cellNumscko = find(genos == 1 & maxAmpAll' > minAmpLeveltuning);
count = 1;
cellQualcko = [];
for x = 1:length(cellNumscko)
    if sum(sum(max_response(cellNumscko(x),:,:)>minAmpLevel)) >= 2
        
    try
     f = fit(octFreqsFile.',max_response(cellNumscko(x),:,1).','gauss1'); 
     bandWgauscko(count) = 2.355*f.c1;
     cellQualcko(x) = 1;
    % figure
    % plot(f,octFreqsFile,max_response(cellNumscko(x),:,1))
     if bandWgauscko(count) > 4 || bandWgauscko(count) == 0 % failure of gaussian estimate
         bandWgauscko(count) = NaN;
     end

    catch
      fprintf('error encountered index:%d\n', x)
      bandWgauscko(x) = NaN;
    end
    count = count + 1;
    else
        cellQualcko(x) = 0;
    end
    
end


%% 

for x = 1:length(bandWgauscko)
    if bandWgauscko(x) == 0
        bandWgauscko(x) = NaN;
    end
end
for x = 1:length(bandWgauscon)
    if bandWgauscon(x) == 0
        bandWgauscon(x) = NaN;
    end
end


bandWgauscon2 = rmmissing(bandWgauscon);
bandWgauscko2 = rmmissing(bandWgauscko);


length(bandWgauscon2)
length(bandWgauscko2)
% CDF
figure
h1 = cdfplot(bandWgauscko2);
hold on
h2 = cdfplot(bandWgauscon2);
h1.Color = 'r';
h2.Color = 'k';
h1.LineWidth = 1;
h2.LineWidth = 1;
xlabel('Bandwidth @ 90dB (Octaves)');
ylabel('CDF');
xlim([0 4])
xticks([0 1 2 3 4])
figQuality(gcf,gca,[1.75 1.9])

[h p] = kstest2(bandWgauscon2,bandWgauscko2);
p

%% display individual FRAs (selected from cdf)

%plotResponse(avg_response,cellNumscko(8))




%% bandwidth by postive responses (amplitude > 1) 
minAmpBW = 0.75;
for x = 1:length(cellNums)
    respvec = (max_response(cellNums(x),:,1)>minAmpBW);
    if sum(respvec) == 0
            bandWcon(x) = NaN;
    else
        for i = 1:9
            if respvec(i) == 1
                bandWOct(i) = octFreqsFile(i);
            else
                bandWOct(i) = NaN;
            end
        end
        bandWcon(x) = max(bandWOct)-min(bandWOct);
        if bandWcon(x) == 0
            bandWcon(x) = NaN;
        end
    end
end

for x = 1:length(cellNumscko)
    respvec = (max_response(cellNumscko(x),:,1)>minAmpBW);
    if sum(respvec) == 0
            bandWcko(x) = NaN;
    else
        for i = 1:9
            if respvec(i) == 1
                bandWOct(i) = octFreqsFile(i);
            else
                bandWOct(i) = NaN;
            end
        end
        bandWcko(x) = max(bandWOct)-min(bandWOct);
          if bandWcko(x) == 0
            bandWcko(x) = NaN;
        end
    end
end

bandWcon2 = rmmissing(bandWcon);
bandWcko2 = rmmissing(bandWcko);

length(bandWcon2)
length(bandWcko2)
% CDF
figure
h1 = cdfplot(bandWcko2);
hold on
h2 = cdfplot(bandWcon2);
h1.Color = 'r';
h2.Color = 'k';
h1.LineWidth = 1;
h2.LineWidth = 1;
xlabel('Max bandwidth (Octaves)');
ylabel('CDF');
xlim([0 4])
xticks([0 2 4])
figQuality(gcf,gca,[1.75 2])

[h p] = kstest2(bandWcon2,bandWcko2);
p



%% FRA 
freqInterval = 0.5;
minAmpFRA = 0.75;
FRAcon = [];
for x = 1:length(cellNums)
    FRAcon(x) = sum(sum(max_response(cellNums(x),:,:)>minAmpFRA))*freqInterval;
    if FRAcon(x) == 0 || FRAcon(x) == 0.5
            FRAcon(x) = NaN;
    end
end
FRAcko = [];
for x = 1:length(cellNumscko)
    FRAcko(x) = sum(sum(max_response(cellNumscko(x),:,:)>minAmpFRA))*freqInterval;
    if FRAcko(x) == 0 || FRAcko(x) == 0.5
            FRAcko(x) = NaN;
    end
end

FRAcon2 = rmmissing(FRAcon);
FRAcko2 = rmmissing(FRAcko);

length(FRAcon2)
length(FRAcko2)
% CDF
figure
h1 = cdfplot(FRAcko2);
hold on
h2 = cdfplot(FRAcon2);
h1.Color = 'r';
h2.Color = 'k';
h1.LineWidth = 1;
h2.LineWidth = 1;
xlabel('FRA (Octaves)');
ylabel('CDF');
xlim([0 9])
xticks([0 3 6 9])
figQuality(gcf,gca,[1.75 1.75])

[h p] = kstest2(FRAcon2,FRAcko2);
p
find(FRAcko > 2)

%plotResponse(avg_response,cellNumscko(746)) %cKO
%exportgraphics(gcf,'ckoExpFRA2.pdf','ContentType','vector')
%plotResponse(avg_response,cellNumscko(find(FRAcko>2))) 
find(FRAcon > 2)
plotResponse(avg_response,cellNums(find(FRAcon>2))) 
plotResponse(avg_response,cellNums(825)) %con
exportgraphics(gcf,'conExpFRA5.pdf','ContentType','vector')
%% Display individual cell FRAs (selected from PCA) 
cellNums = find(score(:,1) > 3 & score(:,1) < 10  & score(:,2) <8 & score(:,2) > -4 & genos == 0);
%plotMultiCellAvg(avg_response,cellNums)
numToShow = 50; % randomly select 50 FRAs to display
n = size(cellNums,1);
temp = randperm(n)';
temp = sort(temp(1:numToShow));
plotResponse(avg_response,temp)

% cell 3695 is a tone off low f control
%plotResponse(avg_response,3470)

%% 