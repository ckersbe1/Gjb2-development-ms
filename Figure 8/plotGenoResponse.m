function plotGenoResponse(avg_responses,genos)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    if nargin < 2
        cellNum = 1; %the cell number to plot
    end
    figure;
    count = 1
    control = squeeze(mean(avg_responses(genos==0,:,:,:),1));
    ko = squeeze(mean(avg_responses(genos==1,:,:,:),1));
    [numFreq, numAtten] = size(avg_responses,[2,3])
    for i = 1:numAtten
        for j = 1:numFreq
            subplot(numAtten,numFreq,count);
            plot(squeeze(control(j,i,:)),'Color','k','LineWidth',1); hold on;
            plot(squeeze(ko(j,i,:)),'Color','r','LineWidth',1);
            count = count + 1
            ylim([-.1,0.5])
        end
    end
end