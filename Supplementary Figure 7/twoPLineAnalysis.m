%% 2P line analysis
% CJK 2022


%load image
[fn, dname] = uigetfile({'*.tif';'*.TIF';'*.tiff';'*.TIFF'});
ICstruct = struct();
openFile = [dname fn];
numFrames = 2000;
for i = 1:numFrames
    img(:,:,i) = imread(openFile,i);
end
[fp,name,~] = fileparts([dname fn]);

% normalize image
%bleachCorrect
img = bleachCorrect(img,1);
% img2 = normalizeImg(img,10,1);
%%
% generate average line scan 
figure; imagesc(mean(img,3)); % show z-projection
x = input('Rotate? (degrees)')
ICstruct.rotateDegrees = x;
img3 = imrotate(img,x);

%% 

% line (square) within image
figure
imagesc(img3(:,:,721)); truesize;
   RIC = imrect(gca,[0,0,50,300]);
   setResizable(RIC,0);
    wait(RIC);
    pos = getPosition(RIC);
    pos = int16(round(pos));
    RICmov = img3(pos(2):pos(2)+pos(4)-1,pos(1):pos(1)+pos(3)-1,:);
 meanIC = squeeze(mean(RICmov,2));
 %% 

 % get dFoF profile
 baseline = prctile(meanIC,20,2);
 dfof = (meanIC - baseline)./baseline;
smdfof = double(imgaussfilt(dfof,3));

[peaksBinary] = getSpatialPeaks(smdfof,1);
    peakAmps = [];
    peakLocs = [];
    [r,c] = find(peaksBinary);
    peakLocs = [r,c];
    for i=1:size(r,1)
        peakAmps = [peakAmps; smdfof(r(i),c(i))];
    end
    eventStat = struct('maxAmp', [],'xloc', [], 'tloc', [], 'integral', [],'integralnorm', []);
    index = 1;
for index=1:length(peakLocs)
    eventStat(index).maxAmp = peakAmps(index);
    eventStat(index).xloc = r(index);
    eventStat(index).tloc = c(index);
    eventStat(index).integral = trapz(smdfof(:,c(index)));
    eventStat(index).integralnorm = trapz(smdfof(:,c(index))./max(smdfof(:,c(index))));
end
    
%% save
dname = 'F:\Calvin\Spontaneous activity in GJB2\2P IC spont\analysis';
save([dname '\spatialAnalysisLine.mat'],'eventStat','smdfof'); 
    
