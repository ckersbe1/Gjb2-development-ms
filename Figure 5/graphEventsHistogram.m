function graphEventsHistogram(pkData)

%colors
    lt_org = [255, 166 , 38]/255;
    dk_org = [255, 120, 0]/255;
    lt_blue = [50, 175, 242]/255;
    dk_blue = [0, 13, 242]/255;
        Rpks = pkData((pkData(:,7)==2),4);
        Lpks = pkData((pkData(:,7)==1),2);
        hold off;
        binLim = [0 0.02:.05:.7 100];
        Rcounts= histcounts(Rpks,binLim);
        Lcounts =histcounts(Lpks,binLim);
        binY = [0 .0450:.05:.7];
        
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
            ylim([0 .8]);
            yticks([0 .2 .4 .6]);
            yticklabels({'0' '20' '40' '60'});
            box off;
            xlabel('# of Dominant Events','FontSize',8);
            ylabel('\DeltaF/F (%)','FontSize',8);
            axh = gca;
            figQuality(figh,axh,[1.8 1.2]);
        



end

