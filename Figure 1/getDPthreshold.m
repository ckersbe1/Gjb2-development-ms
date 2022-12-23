function [threshold] = getDPthreshold(freq, fname)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
% fname - x by y matrix of DPOAEs
[x y] = size(fname);
dbSPL = [90:-5:20];

for v = 1:y
if freq == 8
   DP(v) = max(fname(v).trace(110:140));
   noise(v) = median(fname(v).trace(110:140))+2*(std(fname(v).trace(1500:2000)));
elseif freq == 12
    DP(v) = max(fname(v).trace(160:200));
    noise(v) = median(fname(v).trace(160:200))+2*(std(fname(v).trace(1500:2000)));
elseif freq == 16
    DP(v) = max(fname(v).trace(230:260));
    noise(v) = median(fname(v).trace(230:260))+2*(std(fname(v).trace(1500:2000)));
elseif freq == 20
    DP(v) = max(fname(v).trace(295:325));
    noise(v) = median(fname(v).trace(295:325))+2*(std(fname(v).trace(1500:2000)));
elseif freq == 24
    DP(v) = max(fname(v).trace(355:385));
    noise(v) = median(fname(v).trace(355:385))+2*(std(fname(v).trace(1500:2000)));
end
end

figure
plot([fname(:).levelS2N],DP,'b')
hold on
plot([fname(:).levelS2N],noise,'r')
%plot([fname(:).levelS2N],noiseM,'r')
hold off

% plot waterfall
freq = [1:2048]*0.0477;
figure
hold on
rep = 2;
for x = 1:2:y
    if x == 1 
    plot(freq, fname(x).trace-150*(x-1),'k')
    else
    plot(freq, fname(x).trace-150*(x-rep),'k')
    rep = rep + 1;
    end
end
dim =[1.75,3];
xlim([0 40]);
xlabel('Frequency (kHz)');
ylabel('dB SPL');
handle = gcf;
figQuality(gcf,gca,dim);
yticks([-1050 -900 -750 -600 -450 -300 -150 0]);
yticklabels([20 30 40 50 60 70 80 90])
ylim([-1200 150])
hold off

flag = 0;
for v = 1:y
    if DP(v) <= noise(v) && flag == 0
        flag = 1;
        v
        if v == 1
            threshold = 95; % not detectable at 90 - not real threshold, but a placeholder
        else
            % linear interpolation
            slope = (DP(v)-DP(v-1))/(fname(v).levelS2N-fname(v-1).levelS2N);
             interPol = (mean(noise(:)) - (DP(v)))/slope; % using mean noise level            
             threshold = (fname(v).levelS2N) + interPol;
             if threshold > fname(v-1).levelS2N
                threshold = fname(v-1).levelS2N; %fail-safe in case of overestimate of threshold
             elseif threshold < fname(v).levelS2N
                  threshold = fname(v).levelS2N; %fail-safe in case of underestimate of threshold
             end
        end
    else
    end
    
end


