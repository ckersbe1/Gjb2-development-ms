function [avgDP] = loadDPOAE(fname)
% Load ASCII DPOAE file 
defaultDir = 'F:\Calvin\Spontaneous activity in GJB2\DPOAEs';
cd(defaultDir);

DPrecord = readcell(fname);

avgDP = struct();
% stim is 90-20 dB in 5 dB step 

stimNum = 75;

for i = 1:stimNum
    if i == 1
    avgDP(i).trace = [DPrecord{(30*i):(30*i+2047)}]+120;
    avgDP(i).level = DPrecord(22);
    avgDP(i).freq = DPrecord(23);
    avgDP(i).levelS2N = 90;
    else
    avgDP(i).trace = [DPrecord{(30+2065*(i-1)):(12+2065*(i))}]+120;
    avgDP(i).level = DPrecord(22+2065*(i-1));
    avgDP(i).freq = DPrecord(23+2065*(i-1));
     if i <= 15
    avgDP(i).levelS2N = 90-(5*(i-1));
    elseif i <= 30
    avgDP(i).levelS2N = 90-(5*(i-16));
    elseif i <= 45
    avgDP(i).levelS2N = 90-(5*(i-31));
    elseif i <= 60
    avgDP(i).levelS2N = 90-(5*(i-46));
    else
    avgDP(i).levelS2N = 90-(5*(i-61));
    end
    end
    
end

% to convert dB SPL (properly)
%20 * log([10^(dBV/20)] / .05 + 93.9
