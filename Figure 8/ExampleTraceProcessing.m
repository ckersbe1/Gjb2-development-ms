

%dir = uigetdir("Z:\Naomi\2P Data Done\220304\")
%%load relevant data
wdir = "Z:\Naomi\2P Data Done\220304\map_toe2-016"
sounddata = loadSoundFile(wdir)
Fall = loadFs(wdir);
F = subtractNeuropil(Fall);
Fsmooth = smoothData(F);
unmixedData = unmixTrace(Fsmooth,sounddata,60); %returns a cells x freq x atten x repeat x frames matrix

normFs = normalizeData(unmixedData);

%%
averageResponses = squeeze(mean(normFs,4)); %4th dimension is the repeats
size(averageResponses)

%%
%plot response for an individual neuron
plotResponse(averageResponses,normFs, 15)

%%
maxResponse = max(averageResponses(:,:,:,25:35),[],4);
figure;
imagesc(squeeze(mean(maxResponse,1))');

%%
plotResponse(mean(averageResponses,1),normFs, 1)