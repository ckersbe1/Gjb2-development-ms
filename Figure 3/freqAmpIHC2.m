function [preFreq, postFreq, preAmp, postAmp] = freqAmpIHC2(datafile,time,drugTime)
% determine frequency and amplitude of spontaneous IHC events

dFilt = medfilt1(datafile,250);
sd1 = 2;
time1 = time/60;
[locs peaks] = peakfinder(dFilt,3*sd1,-5,-1); % whole cell IHCs peakfinder
locs = locs/5000/60;
%meanAmpIHC = mean(peaks); %picoamps overall
%meanFreqIHC = length(locs)/max(time/60); %frequency per minute overall
%maxAmp = max(abs(peaks));
%chargeTrans = max(abs((cumtrapz(time1,dFilt))/max(time1))); %integral of activity

figure
hold on
% assessment of peakfinding 
plot(time./60,dFilt,'k')
plot(locs,peaks,'r*')
figQuality(gcf,gca,[8  3])

preA = [];
preF = 0;
postF = 0;
postA = [];
i1 = 1;
i2 = 1;
     for x = 1:length(locs)
         if locs(x)>(drugTime- 5) && locs(x) < drugTime % pre drug
             preF = preF + 1;
             preA(i1) = peaks(x);
             i1 = i1 + 1;
         elseif locs(x) >= drugTime && locs(x)<drugTime + 5 % post drug
             postF = postF + 1;
             postA(i2) = peaks(x);
             i2 = i2 + 1;
         end
     end

     preFreq = preF/5; %events per minute
     postFreq = postF/5; %events per minute
     preAmp = mean(preA); %pA
     if isempty(postA) == 1
         postA = [NaN];
     end
     postAmp = mean(postA); %pA

     % charge transfer analysis still not working
%drugTime = drugTime*5000*60;  

%preCharge = max(abs((cumtrapz(time1((drugTime-300000):drugTime),dFilt((drugTime-300000):drugTime)))/(5*300000))); % 5 minutes pre
%postCharge = max(abs((cumtrapz(time1(drugTime:(drugTime+300000)),dFilt(drugTime:(drugTime+300000))))/(5*300000))); %5 minutes post

%peaks = (abs(peaks))';
end

