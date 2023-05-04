function [res] = plotIV(datafile,time)
% plot current steps
figure
hold on
for x = 1:18
    plot(time,datafile(:,2,x))
end
figQuality(gcf,gca,[4  4])


%plot IV curve end
% ISC
figure
hold on
v = [-150:10:20];
for x = 1:18
    i(x) = datafile(3200,2,x);
end

scatter(v,i,'filled','k')
figQuality(gcf,gca,[4  4])

%calculate resistance 1/slope

slope = diff(i(8:10)./1E12)./diff(v(8:10)./1000);
res = 1/(mean(slope))/1E6; % measured in megaohms

end


