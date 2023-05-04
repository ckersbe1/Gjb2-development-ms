function plotSingleTrace(avg_response,cellNums,color1,atten,freq)
% plot single averaged trace for a given frequency
%   Detailed explanation goes here
   if nargin < 2
        cellNum = 1; %the cell number to plot
    end

    averagedResponse = mean(avg_response(cellNums,:,:,:),1);
    %figure;
    count = 1;
    for i = atten
        for j = freq
            %subplot(numAtten,numFreq,count);
           % plot(squeeze(avg_response(cellNums,j,i,:,:))','Color',[0.7 0.7 0.7],'LineWidth',1);
            hold on; 
            patch([15 15 20 20], [-2 6 6 -2],'k','EdgeColor','none','FaceAlpha',0.2);
            plot(squeeze(averagedResponse(1,j,i,:)),'Color',color1,'LineWidth',2);
           

            ylim([-0.3,3]);
            count = count + 1;
        end
    end





end