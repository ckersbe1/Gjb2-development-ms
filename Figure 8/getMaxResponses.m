function [maxResponses, averageResponses] = getMaxResponses(wdir)
%GETMAXRESPONSES Summary of this function goes here
%   Detailed explanation goes here
    sounddata = loadSoundFile(wdir)
    Fall = loadFs(wdir);
    F = subtractNeuropil(Fall);
    Fsmooth = smoothData(F);
    unmixedData = unmixTrace(Fsmooth,sounddata,60); %returns a cells x freq x atten x repeat x frames matrix
    normFs = normalizeData(unmixedData);
    averageResponses = squeeze(mean(normFs,4)); %4th dimension is the repeats
    maxResponses = max(averageResponses(:,:,:,24:32),[],4);
end

