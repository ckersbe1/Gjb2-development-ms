function [params] = playTonesV3(experimenter, varToVary, xMin, xMax, ...
     numFreqs, repeats, atten, scope, experimentName, p,...
     stimDur, stimInt, varargin)
%playTones Play a series of tones that is triggered by trigIn
%   Function to play tones and allows choice of which variable to vary:
%       varToVary:    'freqs'   change the carrier frequency
%                     'modFreq' change the modulation frequency
%               
%       xMin, xMax:   min and max values for that variable, log spacing
%       numFreqs:     number of unique values to  use
%       numRepeats:   number of times to repeat each value
%       atten:        attenuation (dB)
%       varargin:     N/A yet

%load circuit
if nargin < 10
    p = 1; %random
    stimDur = 1000;
    stimInt = 3500;
    %stimDur = 1200; %ms
    %stimInt = 3800; %ms
    %stimDur = 800; %ms
    %stimInt = 4200; %ms
end


switch scope
    case 'Axio'
        RP = TDTRP('C:\Users\Bergles Lab\Documents\MATLAB\changingTones_hardD1_acquire.rcx', 'RZ6');
    case 'Axio2'
        RP = TDTRP('C:\Users\Bergles Lab\Documents\MATLAB\changingTones_hardD1_acquire2.rcx', 'RZ6');
    case '2P'
        RP = TDTRP('C:\Users\Bergles Lab\Documents\MATLAB\changingTones2P_hardD1.rcx', 'RZ6');
     case '2P2'
        RP = TDTRP('C:\Users\Bergles Lab\Documents\MATLAB\changingTones2P_hardD12.rcx', 'RZ6');
    case '2P_soft'
        RP = TDTRP('C:\Users\Bergles Lab\Documents\MATLAB\changingTones2P_soft.rcx', 'RZ6');
    case 'ePhys'
        RP = TDTRP('C:\Users\Bergles Lab\Documents\MATLAB\changingTonesEphys.rcx', 'RZ6');
    otherwise
        disp('Choice of microscope is not defined. Please try another (Axio, 2P).');
end

freqToPlay = logspace(log10(xMin),log10(xMax),numFreqs);
if strcmp('ePhys',scope)||strcmp('Axio2',scope)
    freqs = reshape(freqToPlay.*ones(repeats,1), 1, repeats*numFreqs);
    atten = 0:atten/repeats:atten;
    atten = reshape(ones(1,numFreqs).*atten(1:(end-1))', 1, repeats*numFreqs);
    tmp = sortrows([randperm(repeats*numFreqs); freqs; atten]')';
    freqs = tmp(2,:);
    atten = tmp(3,:);
else
    for i = 1:repeats
        startInd = 1+(numFreqs*(i-1));
        endInd = startInd + numFreqs - 1;
        if p
            freqs(startInd:endInd) = freqToPlay(randperm(numFreqs));
        else
            freqs(startInd:endInd) = freqToPlay;
        end
    end
end

switch varToVary
    case 'freqs'
        SAMon = 1;
    case 'freqs2'
        SAMon = 0;      
end


freqs
atten

fs = RP.GetSFreq(); 
baselineDur = 5000; %ms first duration of silence, add 1s to accomodate delay of camera

%initialize paramaters structure and save
params = struct();
params.fs = fs;
params.numFreqs = numFreqs;
params.repeats = repeats;
params.freqs = freqs;
params.atten = atten;
params.baselineDur = baselineDur;
params.stimDur = stimDur;
params.stimInt = stimInt;
try
    saveParams(params, [experimentName '_' num2str(atten(1)) 'dB'], experimenter);
catch
    assignin(ws,'params_err',params);
    disp('Error while saving params. Variable was saved to workspace.');
end


calc = (stimDur + stimInt)*numFreqs*repeats + 2*baselineDur;
calc = calc/1000;

disp(['You need to acquire at least ' num2str(calc) ' seconds.']);
RP.WriteTagV('ldata',0,freqs);
RP.SetTagVal('stimDur', stimDur);
RP.SetTagVal('stimInt', stimInt);
RP.SetTagVal('sampRate',fs);
RP.SetTagVal('numFreqs',numFreqs*repeats);
RP.SetTagVal('numFreqsStore',numFreqs*repeats);

if strcmp('ePhys',scope)||strcmp('Axio2',scope)
    RP.SetTagVal('nTones',length(freqs));
    RP.WriteTagV('attA',0,[atten]);
else
    RP.SetTagVal('attA',atten);
end

% begin
%RP.SoftTrg(2); %reset

%software trigger for debugging
%RP.SoftTrg(1);

% begin acquiring
disp('Waiting for camera to start...');
while ~RP.GetTagVal('isRunning')
    pause(0.01);
end
disp('Capturing auditory scene....');

curindex = RP.GetTagVal('index');
%disp(['Current buffer index: ' num2str(curindex)]);

% wait for playback to end
timeRun = 1; counter = 0;
tic;
while RP.GetTagVal('isRunning') && timeRun
   pause(0.05);
    counter = counter + 0.05;
    if counter > calc
        timeRun = 0;
    end
end
toc;
disp(counter);
disp('Finished acquiring auditory landscape.');

% stop acquiring
RP.Halt;

% stop and reset
RP.Halt;

end

function saveParams(params, experimentName, experimenter)
saveDir = ['C:\Users\Bergles Lab\Desktop\Data\' experimenter '\'];
dateDir = datestr(date,'yymmdd');

if ~exist([saveDir dateDir])
    mkdir(saveDir, dateDir);
end

saveDir = [saveDir dateDir];
baseFn = [dateDir '_' experimentName '_'];
fExt = '.mat';
fileName = fullfile(saveDir, [baseFn, sprintf('%02i', 0), fExt]);

if exist(fileName,'file')
    %get number of files
    fDir = dir(fullfile(saveDir, [baseFn, '*', fExt]));
    fStr = sprintf('%s*', fDir.name);
    fNum = sscanf(fStr, [baseFn, '%d', fExt, '*']);
    newNum = max(fNum) + 1;
    fileName = fullfile(saveDir, [baseFn, sprintf('%02i', newNum), fExt]);
end
fileName
save(fileName, 'params');
disp('Params saved.');
end
