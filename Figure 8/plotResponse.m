function plotResponse(avg_response, cellNum)
% plot individual cell FRAs

    if nargin < 2
        cellNum = 1; %the cell number to plot
    end

    [numFreq, numAtten] = size(avg_response,[2,3])
    for k = 1:length(cellNum)
    count = 1;
    figure;
    for i = 1:numAtten
        for j = 1:numFreq
            subplot(numAtten,numFreq,count);
           % plot(squeeze(all_responses(cellNum,j,i,:,:))','Color',[0.7 0.7 0.7],'LineWidth',1);
           % hold on; 
            plot(squeeze(avg_response(cellNum(k),j,i,:)),'k','LineWidth',2);
            ylim([-2,6]);
            count = count + 1;
            patch([15 15 20 20], [-2 6 6 -2],'k','EdgeColor','none','FaceAlpha',0.2);
        end
    end
    end
end