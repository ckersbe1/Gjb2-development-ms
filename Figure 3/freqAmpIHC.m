function [meanFreqIHC meanAmpIHC maxAmp chargeTrans peaks] = freqAmpIHC(datafile,time)
% determine frequency and amplitude of spontaneous IHC events

dFilt = medfilt1(datafile,250);
sd1 = 2;
time1 = time/60;
[locs peaks] = peakfinder(dFilt,3*sd1,-5,-1); % whole cell IHCs peakfinder
locs = locs/5000/60;
meanAmpIHC = mean(peaks); %picoamps overall
meanFreqIHC = length(locs)/max(time/60); %frequency per minute overall
maxAmp = max(abs(peaks));
chargeTrans = max(abs((cumtrapz(time1,dFilt))/max(time1))); %integral of activity

figure
hold on
% assessment of peakfinding 
plot(time/60,dFilt,'k')
plot(locs,peaks,'r*')
figQuality(gcf,gca,[8  3])

% preA = [];
% preF = 0;
% postF = 0;
% postA = [];
% i1 = 1;
% i2 = 1;
%      for x = 1:length(locs)
%          if locs(x)>(drugTime-10) && locs(x) < drugTime % pre drug
%              preF = preF + 1;
%              preA(i1) = peaks(x);
%              i1 = i1 + 1;
%          elseif locs(x) >= drugTime && locs(x)<drugTime + 10 % post drug
%              postF = postF + 1;
%              postA(i2) = peaks(x);
%              i2 = i2 + 1;
%          end
%      end
% 
%      preFreq = preF/10; %events per minute
%      postFreq = postF/10; %events per minute
%      preAmp = mean(preA); %pA
%      if isempty(postA) == 1
%          postA = [0];
%      end
%      postAmp = mean(postA); %pA
peaks = (abs(peaks))';
end

