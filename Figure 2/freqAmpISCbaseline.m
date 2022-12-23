function [meanFreqISC,meanAmpISC,chargeTrans,peaks] = freqAmpISCbaseline(datafile,time)
% measure baseline frequency, amplitude of spontaneous inward currents in 
% Inner Supporting cells

dFilt = medfilt1(datafile,100);
time1 = time/60;
sd1 = 10;
[locs peaks] = peakfinder(dFilt,3*sd1,-10,-1); % whole cell supporting cells
 %picoamps
if isempty(peaks) == 1
    meanAmpISC = 0;
else
    meanAmpISC = mean(peaks);
end
meanFreqISC = length(locs)/max(time1); %frequency per minute
locs = locs/5000/60;
chargeTrans = max(abs((cumtrapz(time1,dFilt))/max(time1))); %integral of activity

figure
hold on
% assessment of peakfinding 
plot(time/60,dFilt,'k')
plot(locs,peaks,'r*')
figQuality(gcf,gca,[8  3])

peaks = (abs(peaks))';

end
