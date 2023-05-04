function [figh, h, p] = compare2(group1, group2, conditions, ylbl, dim, markSz, color1, color2)
      
       if nargin < 7
           color1 = 'k';
           color2 = 'r';
       end
       if nargin < 6
           meanMarkSize = 20;
           markSize = 20;
       else
           markSize = markSz(1);
           meanMarkSize = markSz(2);
       end

       m = size(group1',1);
       m2 = size(group2',1);
       l_grey = [0.7 0.7 0.7];
       
       mean1 = nanmean(group1',1);
       std1 = std(group1',1);
       mean2 = nanmean(group2',1);
       std2 = std(group2',1);
       
       figh = figure;
       scatter(1*ones(m,1), group1',markSize,l_grey,'filled','jitter','on', 'jitterAmount',0.2);
       hold on;
       % plot([1*ones(m,1) 2*ones(m2,1)]',[group1' group2']','Color',l_grey); % for lines
       scatter(2*ones(m2,1), group2',markSize,l_grey,'filled','jitter','on', 'jitterAmount',0.2);
       errorbar([1], mean1, std1,'LineStyle', 'none','LineWidth',1,'Color',color1,'CapSize',0,'Marker','.','MarkerSize',meanMarkSize);
       errorbar([2], mean2, std2,'LineStyle', 'none','LineWidth',1,'Color',color2,'CapSize',0,'Marker','.','MarkerSize',meanMarkSize);
       xlim([0.25 2.75]);
       ylim([0 inf])
       xticks([1 2]);
       xticklabels(conditions);
       xtickangle(45);
       ylabel(ylbl);
      
       % normalcy and statistical testing
       h1 = lillietest(group1);
       h2 = lillietest(group2);
       
       % 4 comparisons 
       
       if h1 == 1 || h2 == 1
           disp ('not normal')
           [h p] = ranksum(group1,group2);
         pt(5) = p;
        disp(h);
       else
        [h,p] = ttest2(group1,group2,'Vartype','unequal');
        pt(5) = p;
        disp(h);
       end

       figQuality(gcf,gca,dim);
       
end

