function [ avgDP20 avgDP24] = separateTonesDP2(fname)
% Separate single tones file by frequency for threshold analysis and plot

avgDP20 = struct();
avgDP24 = struct();

stimNum = 30; % tones x levels
i = 1;
j = 1;
k = 1;
m = 1;
n = 1;
for x = 1:stimNum
       if x <= 15
        avgDP20(m).trace = fname(x).trace;
        avgDP20(m).level = fname(x).level;
        avgDP20(m).freq = fname(x).freq;
        avgDP20(m).levelS2N = fname(x).levelS2N;
        m = m + 1;
       elseif x <= 30
        avgDP24(n).trace = fname(x).trace;
        avgDP24(n).level = fname(x).level;
        avgDP24(n).freq = fname(x).freq;
        avgDP24(n).levelS2N = fname(x).levelS2N;
        n = n + 1;
    end
end
end

