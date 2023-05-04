function [p, handle] = compare4(group1, group2, group3, group4, conditions, ylbl, dim, markSz, color1, color2)
       
       if nargin < 9
           color1 = 'k';
           color2 = 'k';
       end
       if nargin < 8
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
          % group5 = group5';
           %group6 = group6';
       end
       
       m = size(group1,1);
       m2 = size(group2,1);
       m3 = size(group3,1);
       m4 = size(group4,1);
      % m5 = size(group5,1);
      % m6 = size(group6,1);
       
       l_grey = [0.7 0.7 0.7];
       
       mean1 = nanmean(group1,1);
       std1 = std(group1,1);
       mean2 = nanmean(group2,1);
       std2 = std(group2,1);
       mean3 = nanmean(group3,1);
       std3 = std(group3,1);
       mean4 = nanmean(group4,1);
       std4 = std(group4,1);
     %  mean5 = nanmean(group5,1);
      % std5 = std(group5,1);
      % mean6 = nanmean(group6,1);
      % std6 = std(group6,1);
%        
       
      % h = figure;
       %scatter(1*ones(m,1), group1,markSize,l_grey,'filled');
       %hold on;
       %scatter(2*ones(m2,1), group2,markSize,l_grey,'filled');
       %scatter(3*ones(m3,1), group3,markSize,l_grey,'filled');
       %scatter(4*ones(m4,1), group4,markSize,l_grey,'filled');
      % plot([1*ones(m,1) 2*ones(m2,1)]',[group1 group2]','Color',l_grey); % for lines
      % plot([2*ones(m3,1) 3*ones(m4,1)]',[group3 group4]','Color',l_grey); % for lines
      % plot([6*ones(m5,1) 7*ones(m6,1)]',[group5 group6]','Color',l_grey); % for lines
       
       errorbar([0.5], mean1, std1,'LineStyle', 'none','LineWidth',2,'Color',color1,'CapSize',0,'Marker','.','MarkerSize',meanMarkSize);
       hold on
       errorbar([1.5], mean2, std2,'LineStyle', 'none','LineWidth',2,'Color',color1,'CapSize',0,'Marker','.','MarkerSize',meanMarkSize);
       errorbar([2.5], mean3, std3,'LineStyle', 'none','LineWidth',2,'Color',color1,'CapSize',0,'Marker','.','MarkerSize',meanMarkSize);
       errorbar([3.5], mean4, std4,'LineStyle', 'none','LineWidth',2,'Color',color1,'CapSize',0,'Marker','.','MarkerSize',meanMarkSize);
       plot([0.5 1.5]',[mean1 mean2]','Color',color1);
       plot([1.5 2.5]',[mean2 mean3]','Color',color1);
       plot([2.5 3.5]',[mean3 mean4]','Color',color1);
       
      % errorbar([2.75], mean5, std5,'LineStyle', 'none','LineWidth',2,'Color',color1,'CapSize',0,'Marker','.','MarkerSize',meanMarkSize);
      % errorbar([3], mean6, std6,'LineStyle', 'none','LineWidth',2,'Color',color2,'CapSize',0,'Marker','.','MarkerSize',meanMarkSize);
      
      xlim([0.25 4]);
       ylim([0 inf])
       xticks([0.5 1.5 2.5 3.5]);
      % xtickangle([0])
       xticklabels(conditions);
       ylabel(ylbl);
       %[h,p] = ttest2(group1,group2);
      % pt(5) = p;
      % disp(p);


     
       handle = gcf;
       figQuality(gcf,gca,dim);
end
