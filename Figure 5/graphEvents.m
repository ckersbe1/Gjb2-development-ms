function graphEvents(pkData, filePath)
    LIC_big = pkData(pkData(:,7)==1,:);
    RIC_big = pkData(pkData(:,7)==2,:);
    lt_org = [255, 166 , 38]/255;
    dk_org = [255, 120, 0]/255;
    lt_blue = [50, 175, 242]/255;
    dk_blue = [0, 13, 242]/255;
    %figure;
        %plot(-LIC_big(:,2),-LIC_big(:,1),'o','Color','red','MarkerFaceColor','red');
        %hold on;
        %plot(LIC_big(:,4),-LIC_big(:,3),'o','Color','black');
        %plot(-RIC_big(:,2),-RIC_big(:,1),'o','Color','red');
        %plot(RIC_big(:,4),-RIC_big(:,3),'o','Color','black','MarkerFaceColor','black');
        %all points with lines
       % line([-pkData(:,2)'; zeros(size(pkData,1),1)'],[-pkData(:,1)'; -pkData(:,1)'],'Color','red');
        %line([zeros(size(pkData,1),1)'; pkData(:,4)'; ],[-pkData(:,3)'; -pkData(:,3)'],'Color','black');
        %only bigger events with lines
        %line([-LIC_big(:,2)'; zeros(size(LIC_big,1),1)'],[-LIC_big(:,1)'; -LIC_big(:,1)'],'Color','red');
        %line([zeros(size(RIC_big,1),1)'; RIC_big(:,4)'; ],[-RIC_big(:,3)'; -RIC_big(:,3)'],'Color','black');
   % savefig(filePath);
    
    %h = figure(3);
    h = figure;
    ax = gca;
        line([(-pkData(:,2))'; zeros(size(pkData,1),1)'],[-pkData(:,1)'; -pkData(:,1)'],'Color',lt_org);
        hold on;
        line([zeros(size(pkData,1),1)'; (pkData(:,4))'; ],[-pkData(:,3)'; -pkData(:,3)'],'Color',lt_blue);
        line([0 0]',[-6050 50]','Color','black');
        scatter(pkData((pkData(:,7)==2),4),-pkData((pkData(:,7)==2),3),pkData(pkData(:,7)==2,5)*200,dk_blue,'MarkerFaceColor', dk_blue);
        scatter(-pkData((pkData(:,7)==1),2),-pkData((pkData(:,7)==1),1),pkData(pkData(:,7)==1,5)*200,dk_org,'MarkerFaceColor', dk_org);
        set(h,'Position',[200,0,350,500]);
        ax.XLim = [-0.4 0.4];
        ax.YLim = [-6050 50];
        %plot(pkData((pkData(:,7)==2),4),-pkData((pkData(:,7)==2),3),'o','Color','black');
        %plot(-pkData((pkData(:,7)==1),2),-pkData((pkData(:,7)==1),1),'o','Color','red');
        
        %plot(find(pkData(:,7)==2),0,pkData(pkData(:,7)==2,5),'o','Color','black','MarkerFaceColor','black');
        %plot(find(pkData(:,7)==1),0,'o','Color','red','MarkerFaceColor','red');
        
        Rpks = pkData((pkData(:,7)==2),4);
        Lpks = pkData((pkData(:,7)==1),2);
        hold off;
        binLim = [0 0.02:.05:.35 100];
        Rcounts= histcounts(Rpks,binLim);
        Lcounts =histcounts(Lpks,binLim);
        binY = [0 .0450:.05:.35];
        
        figh = figure;
            h=barh(binY(2:end),Rcounts(2:end),.9);
            hold on;
            barh(binY(2:end),-Lcounts(2:end),.9,'FaceColor',lt_org,'EdgeColor','none');
             line([0 0],[0 0.4],'LineWidth',0.75,'Color',[0.6 0.6 0.6]);
            %barh(Lbins,-Lcounts,.9,'FaceColor',lt_org,'EdgeColor',lt_org);
            h.FaceColor = lt_blue;
            h.EdgeColor = 'none';
           
           xax_lim = [-60 60];
            xtick = [-60 -30 0 30 60];
            xticklabel = {'60' '30' '0' '30' '60'};
             xlim(xax_lim);
            xticks(xtick);
            xticklabels(xticklabel);
            ylim([0 .40]);
            yticks([0 .2 .4]);
            yticklabels({'0' '20' '40'});
            box off;
            xlabel('# of Dominant Events','FontSize',8);
            ylabel('\DeltaF/F (%)','FontSize',8);
            axh = gca;
            figQuality(figh,axh,[1.8 1.2]);
        
end
