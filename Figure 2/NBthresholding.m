%% analysis of NB spatial spread

% load max z projection of NB
[fname pname] = uigetfile({'*.tif';'*.TIF';'*.tiff';'*.TIFF'},'select the still video tiff file');
cd(pname)
openFile = [pname fname];
imData = imread(openFile);

% select negative background as threshold
rawImage = imData;
%rawImage = rgb2gray(rawImage);
B = wiener2(rawImage, [3 3]);
imshow(B) 

% draw line, get profile
lineProf = improfile;

C = imbinarize(B); % otsu's method

figure %shows raw image next to automatic thresholding image
subplot(1,2,1)
imshow(rawImage)
title('raw image')
subplot(1,2,2)
imshow (C)
title('thresholded image')

% measure % area positive

scale = 340.08/1024;

pixelArea = sum(sum(C)) * scale^2

[fp,name,~] = fileparts([pname fname]);
%save([fp '\' name '_thresholds'],'pixelArea','lineProf');