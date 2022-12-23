%% ISC grid analysis heat maps

%load image
[fn, dname] = uigetfile({'*.tif';'*.TIF';'*.tiff';'*.TIFF'});
ISCstruct2 = struct();
openFile = [dname fn];
numFrames = 1250;
for i = 1:numFrames
    img(:,:,i) = imread(openFile,i);
end
[fp,name,~] = fileparts([dname fn]);

%%
figure; imagesc(mean(img,3)); 
x = ISCstruct.rotateDegrees; % change input here
img = imrotate(img,x);
imagesc(mean(img,3)); truesize;

%%
widthImg = size(img,2);
heightImg = size(img,1);
sizeSq = 10;
maxTime = 606.9686; % in seconds 
[indices,miniIndices] = getGrid(widthImg,heightImg,sizeSq);
roiIndices = ISCstruct.ISCmask.Position;
% Grids are organized top to bottom, left to right

positiveIndices = getPositiveGrid(indices,roiIndices);
[~,miniPosIndices] = ismember(positiveIndices,indices,'rows');

for i=1:size(positiveIndices,1)
    hold on;
    plot(positiveIndices(i,1:2:end),positiveIndices(i,2:2:end),'Color','g');
end

saveas(gcf,[fp '\' name '_gridImage.bmp'])
%%
%bleachCorrect
img = bleachCorrect(img,1);
[rois fo img2] = normalizeGridImg(img,10,positiveIndices);
zproject = mean(img2,[],3);
figure
imagesc(zproject)
zproject = im2uint16(zproject);
imwrite(zproject, '274 control.tif');
%saveas(gcf,[fp '\' name '_dFoFMIP.bmp'])

[t,n] = size(rois);
medSig = median(rois);
stdSig = std(rois,1);
roiThr = rois > medSig + 3*stdSig;



