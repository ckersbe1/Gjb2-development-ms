function [res] = plotIVDisplay(datafile,time,color)
% plot current steps
figure
hold on
for x = 10:1:14
    plot(time,datafile(:,2,x),color)
end
figQuality(gcf,gca,[1.25  2])


