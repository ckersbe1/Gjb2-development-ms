function [avgDP8 avgDP12 avgDP16 avgDP20 avgDP24] = separateTonesDP(fname)
% Separate single tones file by frequency for threshold analysis and plot

avgDP8 = struct();
avgDP12 = struct();
avgDP16 = struct();
avgDP20 = struct();
avgDP24 = struct();

stimNum = 75; % tones x levels
i = 1;
j = 1;
k = 1;
m = 1;
n = 1;
for x = 1:stimNum
    if x <= 15
        avgDP8(i).trace = fname(x).trace;
        avgDP8(i).level = fname(x).level;
        avgDP8(i).freq = fname(x).freq;
        avgDP8(i).levelS2N = fname(x).levelS2N;
        i = i + 1;
    elseif x <= 30
        avgDP12(j).trace = fname(x).trace;
        avgDP12(j).level = fname(x).level;
        avgDP12(j).freq = fname(x).freq;
        avgDP12(j).levelS2N = fname(x).levelS2N;
        j = j + 1;
    elseif x <= 45
        avgDP16(k).trace = fname(x).trace;
        avgDP16(k).level = fname(x).level;
        avgDP16(k).freq = fname(x).freq;
        avgDP16(k).levelS2N = fname(x).levelS2N;
        k = k + 1;
    elseif x <= 60
        avgDP20(m).trace = fname(x).trace;
        avgDP20(m).level = fname(x).level;
        avgDP20(m).freq = fname(x).freq;
        avgDP20(m).levelS2N = fname(x).levelS2N;
        m = m + 1;
     elseif x <= 75
        avgDP24(n).trace = fname(x).trace;
        avgDP24(n).level = fname(x).level;
        avgDP24(n).freq = fname(x).freq;
        avgDP24(n).levelS2N = fname(x).levelS2N;
        n = n + 1;
    end
end
end

