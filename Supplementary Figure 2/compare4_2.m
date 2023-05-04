function [h, p, handle] = compare4_2(group1, group2, group3, group4, conditions, ylbl, dim, markSz, color1, color2)
       
       if nargin < 11
           color1 = 'k';
           color2 = 'r';
       end
       if nargin < 10
           meanMarkSize = 20;
           markSize = 20;
       else
           markSize = markSz(1);
           meanMarkSize = markSz(2);
       end
       if size(group1,2) > size(group1,1)
           group1 = group1';
           group2 = group2';
           group3 = group3';
           group4 = group4';
           %group5 = group5';
           %group6 = group6';
       end
       
       m = size(group1,1);
       m2 = size(group2,1);
       m3 = size(group3,1);
       m4 = size(group4,1);
      % m5 = size(group5,1);
     %  m6 = size(group6,1);
       
       l_grey = [0.7 0.7 0.7];
       
       mean1 = nanmean(group1,1);
       std1 = std(group1,1);
       mean2 = nanmean(group2,1);
       std2 = std(group2,1);
       mean3 = nanmean(group3,1);
       std3 = std(group3,1);
       mean4 = nanmean(group4,1);
       std4 = std(group4,1);
      % mean5 = nanmean(group5,1);
      % std5 = std(group5,1);
      % mean6 = nanmean(group6,1);
      % std6 = std(group6,1);
%        
       
       h = figure;
       scatter(0.6*ones(m,1), group1,markSize,l_grey,'filled','jitter','on', 'jitterAmount',0.15);
       hold on;
       scatter(1*ones(m2,1), group2,markSize,l_grey,'filled','jitter','on', 'jitterAmount',0.15);
       scatter(1.6*ones(m3,1), group3,markSize,l_grey,'filled','jitter','on', 'jitterAmount',0.15);
       scatter(2*ones(m4,1), group4,markSize,l_grey,'filled','jitter','on', 'jitterAmount',0.15);
      % scatter(2.6*ones(m5,1), group5,markSize,l_grey,'filled','jitter','on', 'jitterAmount',0.15);
      % scatter(3*ones(m6,1), group6,markSize,l_grey,'filled','jitter','on', 'jitterAmount',0.15);
      % plot([1*ones(m,1) 2*ones(m2,1)]',[group1 group2]','Color',l_grey); % for lines
       %plot([3.5*ones(m3,1) 4.5*ones(m4,1)]',[group3 group4]','Color',l_grey); % for lines
      % plot([6*ones(m5,1) 7*ones(m6,1)]',[group5 group6]','Color',l_grey); % for lines
       
       errorbar([0.6], mean1, std1,'LineStyle', 'none','LineWidth',2,'Color',color1,'CapSize',0,'Marker','.','MarkerSize',meanMarkSize);
       errorbar([1], mean2, std2,'LineStyle', 'none','LineWidth',2,'Color',color2,'CapSize',0,'Marker','.','MarkerSize',meanMarkSize);
       errorbar([1.6], mean3, std3,'LineStyle', 'none','LineWidth',2,'Color',color1,'CapSize',0,'Marker','.','MarkerSize',meanMarkSize);
       errorbar([2], mean4, std4,'LineStyle', 'none','LineWidth',2,'Color',color2,'CapSize',0,'Marker','.','MarkerSize',meanMarkSize);
       %errorbar([2.6], mean5, std5,'LineStyle', 'none','LineWidth',2,'Color',color1,'CapSize',0,'Marker','.','MarkerSize',meanMarkSize);
      % errorbar([3], mean6, std6,'LineStyle', 'none','LineWidth',2,'Color',color2,'CapSize',0,'Marker','.','MarkerSize',meanMarkSize);
       xlim([0.25 2.25]);
       ylim([0 inf])
       xticks([0.6 1 1.6 2]);
       xtickangle([45])
       xticklabels(conditions);
       ylabel(ylbl);
       %[h,p] = ttest2(group1,group2);
      % pt(5) = p;
      % disp(p);
      
%     %  h1 = kstest(group1);
%        h2 = kstest(group2);
%        
%        if h1 == 1 || h2 == 1
%            disp ('not normal')
%            [h p] = ranksum(group1,group2);
%          pt(5) = p;
%         disp(h);
%        else
%         [h,p] = ttest2(group1,group2);
%         pt(5) = p;
%         disp(h);
%        end
%        
%         h1 = kstest(group3);
%        h2 = kstest(group4);
%        
%        if h1 == 1 || h2 == 1
%            disp ('not normal')
%            [h p] = ranksum(group3,group4);
%          pt(5) = p;
%         disp(h);
%        else
%         [h,p] = ttest2(group3,group4);
%         pt(5) = p;
%         disp(h);
%        end
%        
%         h1 = kstest(group5);
%        h2 = kstest(group6);
%        
%        if h1 == 1 || h2 == 1
%            disp ('not normal')
%            [h p] = ranksum(group5,group6);
%          pt(5) = p;
%         disp(h);
%        else
%         [h,p] = ttest2(group5,group6);
%         pt(5) = p;
%         disp(h);
%        end
     
       handle = gcf;
       figQuality(gcf,gca,dim);
end
