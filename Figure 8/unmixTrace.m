function data_unmixed = unmixTrace(F, soundData, framesToAnalyze)
        numCells = size(F,1);
        frames = soundData.stimOnFrame;
        attens = soundData.atten{1}
        numAttens = size(attens,2);
        numFreqs = size(unique(soundData.stimPlayedID),1);
        numRepeats = soundData.nRep;
        freqID = unique(soundData.stimPlayedID);
        data_unmixed = zeros(numCells,numFreqs,numAttens,numRepeats,framesToAnalyze);
        
        for cell = 1:numCells
            for freq = 1:numFreqs
                for atten = 1:numAttens
                    framesForStimAndLevel = frames(soundData.stimPlayedID==freqID(freq) & soundData.stimPlayedAtten==attens(atten));
                    startFrames = framesForStimAndLevel - 15;
                    for repeat = 1:numRepeats
                        data_unmixed(cell,freq,atten,repeat,:) = F(cell,startFrames(repeat):startFrames(repeat)+framesToAnalyze-1);
                    end
               end
            end
        end
end