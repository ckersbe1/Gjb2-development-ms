function plotMultiCellAvg(avg_response,cellNums,color1)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    if nargin < 2
        cellNum = 1; %the cell number to plot
    end

    averagedResponse = mean(avg_response(cellNums,:,:,:),1);
    figure;
    count = 1
    [numFreq, numAtten] = size(avg_response,[2,3])
    for i = 1:numAtten
        for j = 1:numFreq
            subplot(numAtten,numFreq,count);
            plot(squeeze(avg_response(cellNums,j,i,:,:))','Color',[0.7 0.7 0.7],'LineWidth',1);
            hold on; 
            plot(squeeze(averagedResponse(1,j,i,:)),'Color',color1,'LineWidth',2);
            patch([15 15 20 20], [-2 6 6 -2],'k','EdgeColor','none','FaceAlpha',0.2);

            ylim([-3,4]);
            count = count + 1;
        end
    end
end